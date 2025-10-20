//
//  FavoriteAlbumView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI
import SwiftData

struct FavoriteAlbumView: View {
    
    @Environment(\.modelContext) var context
    @Query(sort: \Favorite.dateAdded) var favorites : [Favorite]
    
  
    
    @State private var isShowingItemSheet = false
    
    @State private var favoriteToEdit: Favorite?
    
    @State  private var errorMessage: String?
    
    
    var body: some View {
      
        NavigationStack{
            List{
                if favorites.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Tap '+' to create your first favorite album.")
                    )
                } else {
                    ForEach(vm.items) { favorite in
                        Button {
                            favoriteToEdit = favorite
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(favorite.name).font(.headline)
                                Text(favorite.artist).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        Task { await vm.remove(at: offsets) }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("Add", systemImage: "plus") { isShowingItemSheet = true }
            }
            // Carga inicial desde el API
            .task { await vm.load() }


            .sheet(isPresented: $isShowingItemSheet) {
                AddFavoriteSheet { name, artist, favSong, done, comm, text in
                    Task {
                        await vm.add(name: name,
                                     artist: artist,
                                     favoriteSong: favSong,
                                     listenCompleted: done,
                                     commented: comm,
                                     comment: text)
                    }
                }
            }
            // Edición
            .sheet(item: $favoriteToEdit) { item in
                UpdateFavoriteSheet(item: item) { name, artist, favSong, done, comm, text in
                    Task {
                        await vm.edit(item: item,
                                      name: name,
                                      artist: artist,
                                      favoriteSong: favSong,
                                      listenCompleted: done,
                                      commented: comm,
                                      comment: text)
                    }
                }
            }
            // Mensajes de error (desde vm.userMessage o locales)
            .onChange(of: vm.userMessage) { _, newValue in
                errorMessage = newValue
            }
            .alert("Error",
                   isPresented: .constant(errorMessage != nil),
                   presenting: errorMessage) { _ in
                Button("OK", role: .cancel) { errorMessage = nil; vm.userMessage = nil }
            } message: { msg in
                Text(msg)
            }
        }
    }
}

#Preview {
    FavoriteAlbumView()
}