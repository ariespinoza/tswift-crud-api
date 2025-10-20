//
//  Album.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//


import Foundation

struct Album : Identifiable, Decodable {
    var id = UUID()
    var name : String
    var imageName : [String]
    var releaseDate : String
    var trackList: [String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageName
        case releaseDate
        case trackList
    }
    
}

struct AlbumsResponse: Decodable {
    let count: Int
    let items: [Album]
}
