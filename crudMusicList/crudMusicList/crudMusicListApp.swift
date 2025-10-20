//
//  crudMusicListApp.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI
import SwiftData

@main
struct crudMusicListApp: App {
    var body: some Scene {
        WindowGroup {
            FavoriteAlbumView()
        }
        .modelContainer(for: [Favorite.self])
        
    }
}
