//
//  ContentView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

//
struct ContentView: View {
    var body: some View {
        
        TabView {
            
            FavoriteAlbumView()
                .tabItem {
                   Label("Favorites", systemImage: "star")
               }
            
            ArtistBiographyView()
                .tabItem {
                    Label("Artist", systemImage: "person.fill")
                }
            
            AlbumsTabView()
                .tabItem {
                    Label("Albums", systemImage: "music.note.list")
            }
        }
        
        
    }
}
#Preview {
    ContentView()
    
}
