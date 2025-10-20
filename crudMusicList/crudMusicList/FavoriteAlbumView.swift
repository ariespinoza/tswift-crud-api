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
                    ForEach(favorites) { favorite in
                        Text(favorite.name)
                            .onTapGesture {
                                favoriteToEdit = favorite
                            }
                        
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            context.delete(favorites[index])
                        }
                        do {
                            try context.save()  // Save with error handling
                        } catch {
                            errorMessage = "Failed to delete the album: \(error.localizedDescription)"  // Show error message
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingItemSheet) {
                AddFavoritesSheet()
            }
            .sheet(item: $favoriteToEdit){ favorite in
                UpdateFavoriteSheet(favorite: favorite)
            }
            .toolbar{
                Button("Add", systemImage: "plus"){
                    isShowingItemSheet = true
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in Button("OK", role: .cancel) { errorMessage = nil }
            } message: { msg in
                Text(msg)
            }
        }
    }
}

#Preview {
    FavoriteAlbumView()
        .modelContainer(for: [Favorite.self], inMemory: true)

}
