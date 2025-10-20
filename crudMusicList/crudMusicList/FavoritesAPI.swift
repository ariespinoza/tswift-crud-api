

import Foundation

final class FavoritesAPI {
    private let base = URL(string: APIConfig.baseURL)!
    private let dec = JSONDecoder()
    private let enc = JSONEncoder()
    private let session: URLSession

    init(session: URLSession = .shared) { // <-- NUEVO
        self.session = session
    }

    func list() async throws -> [Favorite] {
        let url = base.appendingPathComponent("favorites")
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try dec.decode([Favorite].self, from: data)
    }

    func create(name: String,
                artist: String,
                favoriteSong: String?,
                listenCompleted: Bool,
                commented: Bool,
                comment: String?) async throws -> Favorite {
        let url = base.appendingPathComponent("favorites")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "name": name,
            "artist": artist,
            "listenCompleted": listenCompleted,
            "commented": commented
        ]
        if let favoriteSong { body["favoriteSong"] = favoriteSong }
        if let comment { body["comment"] = comment }

        req.httpBody = try JSONSerialization.data(withJSONObject: body)
         let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try dec.decode(Favorite.self, from: data)
    }

    func update(id: Int,
                name: String? = nil,
                artist: String? = nil,
                favoriteSong: String? = nil,
                listenCompleted: Bool? = nil,
                commented: Bool? = nil,
                comment: String? = nil) async throws -> Favorite {
        let url = base.appendingPathComponent("favorites/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [:]
        if let name, !name.isEmpty { body["name"] = name }
        if let artist, !artist.isEmpty { body["artist"] = artist }
        if let favoriteSong { body["favoriteSong"] = favoriteSong }
        if let listenCompleted { body["listenCompleted"] = listenCompleted }
        if let commented { body["commented"] = commented }
        if let comment { body["comment"] = comment }

        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, resp) = try await session.data(for: req)   
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try dec.decode(Favorite.self, from: data)
    }

    func delete(id: Int) async throws {
        let url = base.appendingPathComponent("favorites/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        let (_, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
