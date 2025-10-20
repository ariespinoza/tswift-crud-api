//
//  AddFavoritesSheet.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//


import SwiftUI

struct AddFavoritesSheet: View {
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var artist = ""
    @State private var favoriteSong = ""
    @State private var listenCompleted = false
    @State private var commented = false
    @State private var comment = ""

    /// callback hacia el ViewModel
    let onSave: (_ name: String,
                 _ artist: String,
                 _ favoriteSong: String?,
                 _ listenCompleted: Bool,
                 _ commented: Bool,
                 _ comment: String?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Álbum") {
                    TextField("Nombre", text: $name)
                    TextField("Artista", text: $artist)
                    TextField("Canción favorita", text: $favoriteSong)
                }
                Section("Estado") {
                    Toggle("Escucha completada", isOn: $listenCompleted)
                    Toggle("Comentado", isOn: $commented)
                    TextField("Comentario", text: $comment, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nuevo favorito")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onSave(
                            name,
                            artist,
                            favoriteSong.isEmpty ? nil : favoriteSong,
                            listenCompleted,
                            commented,
                            comment.isEmpty ? nil : comment
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || artist.isEmpty)
                }
            }
        }
    }
}

#Preview {
   AddFavoritesSheet()
}
