//
//  UpdateFavoritesSheet.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//


import SwiftUI
import SwiftData

struct UpdateFavoriteSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var artist: String
    @State private var favoriteSong: String
    @State private var listenCompleted: Bool
    @State private var commented: Bool
    @State private var comment: String

    let onUpdate: (_ name: String?, _ artist: String?, _ favoriteSong: String?, _ listenCompleted: Bool?, _ commented: Bool?, _ comment: String?) -> Void

    init(item: Favorite,
         onUpdate: @escaping (_ name: String?, _ artist: String?, _ favoriteSong: String?, _ listenCompleted: Bool?, _ commented: Bool?, _ comment: String?) -> Void) {
        _name = State(initialValue: item.name)
        _artist = State(initialValue: item.artist)
        _favoriteSong = State(initialValue: item.favoriteSong ?? "")
        _listenCompleted = State(initialValue: item.listenCompleted)
        _commented = State(initialValue: item.commented)
        _comment = State(initialValue: item.comment ?? "")
        self.onUpdate = onUpdate
    }

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
            .navigationTitle("Editar favorito")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        onUpdate(name, artist,
                                 favoriteSong.isEmpty ? nil : favoriteSong,
                                 listenCompleted, commented,
                                 comment.isEmpty ? nil : comment)
                        dismiss()
                    }.disabled(name.isEmpty || artist.isEmpty)
                }
            }
        }
    }
}

#Preview {
    //UpdateTravelGoalSheet(travelGoal: TravelGoal(name: "Chiapas", dateAdded: .now, visited: false))
}
