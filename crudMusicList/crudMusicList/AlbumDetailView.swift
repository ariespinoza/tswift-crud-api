//
//  AlbumDetailView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @State private var currentImageIndex = 0 //Estado de índice para el swipe de las imagenes de la portada

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                
                if !album.imageName.isEmpty {
                    TabView(selection: $currentImageIndex) {
                        ForEach(Array(album.imageName.enumerated()), id: \.offset) { i, name in
                            Image(name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 325, height: 325)
                                .onTapGesture {
                                    guard album.imageName.count > 1 else { return }
                                    withAnimation(.easeInOut) {
                                        currentImageIndex = (currentImageIndex + 1) % album.imageName.count
                                    }
                                }
                                .tag(i)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .automatic))
                    .frame(height: 340)
                } else {
                    //Alternativa para evitar crahses si no hay imágenes
                    Image(systemName: "photo")
                        .resizable().scaledToFit()
                        .frame(width: 325, height: 325)
                        .foregroundStyle(.secondary)
                }

                //Clean Code: se combina el uso de textos normales y en negrita para mostrar importancia en títulos y jerarquía
                (Text("Album Name: ").fontWeight(.bold) + Text(album.name))
                (Text("Release Date: ").fontWeight(.bold) + Text(album.releaseDate))

                Text("Tracklist").fontWeight(.bold)
                Text(album.trackList.joined(separator: "\n"))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //Resetea el índice para evitar valores inválidos
            if currentImageIndex >= album.imageName.count { currentImageIndex = 0 }
        }
    }
}


#Preview{
    AlbumDetailView(album: Album(name: "Fearless", imageName: ["Fearless", "FearlessTV"], releaseDate: "November 11, 2008", trackList: ["Fearless", "Fifteen", "Love Story", "Hey Stephen", "White Horse", "You Belong With Me", "Breathe (feat. Colbie Caillat)", "Tell Me Why", "You’re Not Sorry", "The Way I Loved You", "Forever & Always", "The Best Day", "Change"]))
}


