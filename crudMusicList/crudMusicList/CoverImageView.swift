//
//  CoverImageView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

struct CoverImageView: View {
    let album: Album
    var body: some View {
        if let first = album.imageName.first, UIImage(named: first) != nil {
            Image(first)
                .resizable()
                .scaledToFill()
            
            //Si no encuentra un nombre de imagen válido
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
        }
    }
}
