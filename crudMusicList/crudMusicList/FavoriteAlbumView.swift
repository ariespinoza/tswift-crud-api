//
//  FavoriteAlbumView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

struct FavoriteAlbumView: View {

    @State private var vm = FavoritesViewModel()

    @State private var isShowingItemSheet = false
    @State private var favoriteToEdit: Favorite?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Cargando…")
                } else if vm.items.isEmpty {
                    ContentUnavailableView(
                        "No favorites yet",
                        systemImage: "heart",
                        description: Text("Tap '+' to create your first favorite album.")
                    )
                } else {
                    List {
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
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)

            .task { await vm.load() }

            .sheet(isPresented: $isShowingItemSheet) {
                // Usa el nombre real de tu sheet: AddFavoritesSheet o AddFavoriteSheet
                AddFavoritesSheet { name, artist, favSong, done, comm, text in
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

            .onChange(of: vm.userMessage) { _, newValue in errorMessage = newValue }
            .alert("Error",
                   isPresented: .constant(errorMessage != nil),
                   presenting: errorMessage) { _ in
                Button("OK", role: .cancel) { errorMessage = nil; vm.userMessage = nil }
            } message: { msg in Text(msg) }

            .toolbar {
                Button("Add", systemImage: "plus") { isShowingItemSheet = true }
            }
        }
    }
}

#Preview {
    FavoriteAlbumView()
}
