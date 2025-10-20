//
//  crudMusicListTests.swift
//  crudMusicListTests
//
//  Created by Emmy Molina Palma on 1/10/25.
//

import Testing
import Foundation
@testable import crudMusicList

// MARK: - Mock URLProtocol

final class MockURLProtocol: URLProtocol {
    // ruta (o método+ruta) -> handler
    static var handlers: [(URLRequest) -> (Int, Data)] = []

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.handlers.first else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let (status, data) = handler(request)
        let resp = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
        client?.urlProtocol(self, didReceive: resp, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

func makeMockSession() -> URLSession {
    let cfg = URLSessionConfiguration.ephemeral
    cfg.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: cfg)
}

// MARK: - Helpers

private func jsonData(_ obj: Any) -> Data {
    try! JSONSerialization.data(withJSONObject: obj, options: [.withoutEscapingSlashes])
}

// MARK: - Tests

struct crudMusicListTests {

    // Test 1: nombre no vacío
    @Test
    func validateNonEmptyName() async throws {
        let name = "  "
        #expect(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // Test 2: decodificación de /albums (array plano)
    @Test
    func decodeAlbumsArray() async throws {
        let sample: [[String: Any]] = [
            [
                "id": 1,
                "name": "Taylor Swift",
                "imageName": ["Debut"],
                "releaseDate": "October 24, 2006",
                "trackList": ["Tim McGraw", "Our Song"]
            ]
        ]
        let data = jsonData(sample)
        let albums = try JSONDecoder().decode([Album].self, from: data)
        #expect(albums.count == 1)
        #expect(albums.first?.name == "Taylor Swift")
        #expect(albums.first?.trackList.count == 2)
    }

    // Test 3: FavoritesAPI.list
    @Test
    func favorites_list_returns_items() async throws {
        MockURLProtocol.handlers = [ { _ in
            let sample: [[String: Any]] = [
                ["id": 1, "name": "1989", "artist": "Taylor Swift",
                 "dateAdded": "2025-10-20T02:30:58.325444",
                 "favoriteSong": "Blank Space",
                 "listenCompleted": true, "commented": true, "comment": "Top!"]
            ]
            return (200, jsonData(sample))
        } ]
        let api = FavoritesAPI(session: makeMockSession())
        let result = try await api.list()
        #expect(result.count == 1)
        #expect(result.first?.name == "1989")
        #expect(result.first?.artist == "Taylor Swift")
    }

    // Test 4: FavoritesAPI.create (verifica método y body)
    @Test
    func favorites_create_posts_body() async throws {
        MockURLProtocol.handlers = [ { req in
            #expect(req.httpMethod == "POST")
            let sent = try! JSONSerialization.jsonObject(with: req.httpBody ?? Data()) as? [String: Any]
            #expect(sent?["name"] as? String == "Red")
            #expect(sent?["artist"] as? String == "Taylor Swift")
            let created: [String: Any] = [
                "id": 10, "name": "Red", "artist": "Taylor Swift",
                "dateAdded": "2025-10-20T02:31:00.000000",
                "favoriteSong": "Begin Again",
                "listenCompleted": false, "commented": false, "comment": "Por probar"
            ]
            return (201, jsonData(created))
        } ]
        let api = FavoritesAPI(session: makeMockSession())
        let fav = try await api.create(name: "Red", artist: "Taylor Swift",
                                       favoriteSong: "Begin Again",
                                       listenCompleted: false, commented: false, comment: "Por probar")
        #expect(fav.id == 10)
        #expect(fav.name == "Red")
    }

    // Test 5: FavoritesAPI.update (PATCH)
    @Test
    func favorites_update_patches_fields() async throws {
        MockURLProtocol.handlers = [ { req in
            #expect(req.httpMethod == "PATCH")
            #expect(req.url?.absoluteString.hasSuffix("/favorites/10") == true)
            let sent = try! JSONSerialization.jsonObject(with: req.httpBody ?? Data()) as? [String: Any]
            #expect(sent?["comment"] as? String == "Re-escuchar deluxe")
            let updated: [String: Any] = [
                "id": 10, "name": "Red", "artist": "Taylor Swift",
                "dateAdded": "2025-10-20T02:31:00.000000",
                "favoriteSong": "Begin Again",
                "listenCompleted": true, "commented": true, "comment": "Re-escuchar deluxe"
            ]
            return (200, jsonData(updated))
        } ]
        let api = FavoritesAPI(session: makeMockSession())
        let result = try await api.update(id: 10, comment: "Re-escuchar deluxe", listenCompleted: true, commented: true)
        #expect(result.listenCompleted == true)
        #expect(result.commented == true)
        #expect(result.comment == "Re-escuchar deluxe")
    }

    // Test 6: FavoritesAPI.delete
    @Test
    func favorites_delete_calls_endpoint() async throws {
        MockURLProtocol.handlers = [ { req in
            #expect(req.httpMethod == "DELETE")
            #expect(req.url?.absoluteString.hasSuffix("/favorites/10") == true)
            return (200, Data("{}““.utf8)) // cuerpo vacío/ok
        } ]
        let api = FavoritesAPI(session: makeMockSession())
        try await api.delete(id: 10)
        // Si no lanza error, pasa
        #expect(true)
    }
}