import Foundation
import Observation

@Observable
@MainActor
final class FavoritesViewModel {
    private let api = FavoritesAPI()

    var items: [Favorite] = []
    var isLoading = false
    var userMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            items = try await api.list()
            userMessage = nil
        } catch {
            userMessage = "No se pudieron cargar los favoritos."
            print("Error load:", error)
        }
    }

    func add(name: String,
             artist: String,
             favoriteSong: String?,
             listenCompleted: Bool,
             commented: Bool,
             comment: String?) async {
        do {
            let created = try await api.create(name: name,
                                               artist: artist,
                                               favoriteSong: favoriteSong,
                                               listenCompleted: listenCompleted,
                                               commented: commented,
                                               comment: comment)
            items.append(created)
        } catch {
            userMessage = "No se pudo crear el favorito."
        }
    }

    func edit(item: Favorite,
              name: String? = nil,
              artist: String? = nil,
              favoriteSong: String? = nil,
              listenCompleted: Bool? = nil,
              commented: Bool? = nil,
              comment: String? = nil) async {
        guard let id = item.id else { return }
        do {
            let updated = try await api.update(id: id,
                                               name: name,
                                               artist: artist,
                                               favoriteSong: favoriteSong,
                                               listenCompleted: listenCompleted,
                                               commented: commented,
                                               comment: comment)
            if let idx = items.firstIndex(where: { $0.id == id }) {
                items[idx] = updated
            }
        } catch {
            userMessage = "No se pudo actualizar."
            print("Error edit:", error)
        }
    }

    func remove(at offsets: IndexSet) async {
        for idx in offsets {
            if let id = items[idx].id {
                do { try await api.delete(id: id) }
                catch { userMessage = "No se pudo eliminar."; return }
            }
        }
        items.remove(atOffsets: offsets)
    }
}
