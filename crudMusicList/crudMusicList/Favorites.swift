//
//  Favorites.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import Foundation
import SwiftData

@Model
class Favorite {
    var name: String
    var artist: String
    var dateAdded : Date
    var favoriteSong : String
    var listenCompleted : Bool
    var commented : Bool
    var comment : String
    
    init(name: String, artist: String, dateAdded: Date, favoriteSong: String, listenCompleted: Bool, commented: Bool, comment: String) {
        self.name = name
        self.artist = artist
        self.dateAdded = dateAdded
        self.favoriteSong = favoriteSong
        self.listenCompleted = listenCompleted
        self.commented = commented
        self.comment = comment
    }
    
    static func isValidName(_ name: String) -> Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

}
