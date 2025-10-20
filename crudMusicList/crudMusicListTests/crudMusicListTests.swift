//
//  crudMusicListTests.swift
//  crudMusicListTests
//
//  Created by Ariana Espinoza on 1/10/25.
//

//
//  crudMusicListTests.swift
//  crudMusicListTests
//
//  Tests para API remota (JSON) sin SwiftData.
//  - MockURLProtocol para interceptar requests
//  - Aserciones SIEMPRE fuera del handler (framework `Testing`)
//

import Testing
import Foundation
@testable import crudMusicList

// MARK: - Mock URLProtocol (captura la última request)

final class MockURLProtocol: URLProtocol {
    /// Respuesta simulada para la próxima request
    static var responder: ((URLRequest) -> (Int, Data))?
    /// Última request capturada (para aserciones en el test)
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        // Guarda la request para que el test la pueda inspeccionar
        Self.lastRequest = request

        guard let responder = Self.responder else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let (status, data) = responder(request)

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: status,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private func makeMockSession() -> URLSession {
    let cfg = URLSessionConfiguration.ephemeral
    cfg.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: cfg)
}

// MARK: - Helpers

private func jsonData(_ obj: Any) -> Data {
    // Opciones vacías para máxima compatibilidad del SDK
    return try! JSONSerialization.data(withJSONObject: obj, options: [])
}

private func bodyData(from request: URLRequest?) -> Data? {
    guard let request else { return nil }
    if let d = request.httpBody { return d }
    guard let stream = request.httpBodyStream else { return nil }

    stream.open()
    defer { stream.close() }

    var data = Data()
    let bufSize = 1024
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufSize)
    defer { buffer.deallocate() }

    while stream.hasBytesAvailable {
        let read = stream.read(buffer, maxLength: bufSize)
        if read > 0 { data.append(buffer, count: read) }
        else { break }
    }
    return data
}


// MARK: - Tests

@MainActor
struct crudMusicListTests {

    // 1) Validación simple: nombre no vacío
    @Test
    func validateNonEmptyName() async throws {
        let name = "  "
        #expect(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    // 2) Decodificación de /albums (array directo)
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

    // 3) FavoritesAPI.list
    @Test
    func favorites_list_returns_items() async throws {
        MockURLProtocol.responder = { _ in
            let sample: [[String: Any]] = [
                [
                    "id": 1,
                    "name": "1989",
                    "artist": "Taylor Swift",
                    "dateAdded": "2025-10-20T02:30:58.325444",
                    "favoriteSong": "Blank Space",
                    "listenCompleted": true,
                    "commented": true,
                    "comment": "Top!"
                ]
            ]
            return (200, jsonData(sample))
        }
        MockURLProtocol.lastRequest = nil

        let api = FavoritesAPI(session: makeMockSession())
        let result = try await api.list()

        // No hay aserciones dentro del handler: se hacen aquí
        let req = MockURLProtocol.lastRequest
        #expect(req?.httpMethod == "GET")
        #expect(req?.url?.absoluteString.hasSuffix("/favorites") == true)

        #expect(result.count == 1)
        #expect(result.first?.name == "1989")
        #expect(result.first?.artist == "Taylor Swift")
    }

    // 4) FavoritesAPI.create (método y body correctos)
    @Test
    func favorites_create_posts_body() async throws {
        let created: [String: Any] = [
            "id": 10,
            "name": "Red",
            "artist": "Taylor Swift",
            "dateAdded": "2025-10-20T02:31:00.000000",
            "favoriteSong": "Begin Again",
            "listenCompleted": false,
            "commented": false,
            "comment": "Por probar"
        ]

        MockURLProtocol.responder = { _ in (201, jsonData(created)) }
        MockURLProtocol.lastRequest = nil

        let api = FavoritesAPI(session: makeMockSession())
        let fav = try await api.create(
            name: "Red",
            artist: "Taylor Swift",
            favoriteSong: "Begin Again",
            listenCompleted: false,
            commented: false,
            comment: "Por probar"
        )

        let req = MockURLProtocol.lastRequest
        #expect(req?.httpMethod == "POST")
        #expect(req?.url?.absoluteString.hasSuffix("/favorites") == true)

        if let data = bodyData(from: req),
        let sent = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            #expect(sent["name"] as? String == "Red")
            #expect(sent["artist"] as? String == "Taylor Swift")
            #expect(sent["favoriteSong"] as? String == "Begin Again")
        } else {
            #expect(Bool(false))
        }


        #expect(fav.id == 10)
        #expect(fav.name == "Red")
    }

    // 5) FavoritesAPI.update (PATCH) con campos específicos
    @Test
    func favorites_update_patches_fields() async throws {
        let updated: [String: Any] = [
            "id": 10, "name": "Red", "artist": "Taylor Swift",
            "dateAdded": "2025-10-20T02:31:00.000000",
            "favoriteSong": "Begin Again",
            "listenCompleted": true, "commented": true, "comment": "Re-escuchar deluxe"
        ]
        MockURLProtocol.responder = { _ in (200, jsonData(updated)) }

        MockURLProtocol.lastRequest = nil

        let api = FavoritesAPI(session: makeMockSession())
        let result = try await api.update(
            id: 10,
            listenCompleted: true,
            commented: true,
            comment: "Re-escuchar deluxe"
            
        )

        let req = MockURLProtocol.lastRequest
        #expect(req?.httpMethod == "PATCH")
        #expect(req?.url?.absoluteString.hasSuffix("/favorites/10") == true)

        if let data = bodyData(from: req),
        let sent = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            #expect(sent["comment"] as? String == "Re-escuchar deluxe")
            #expect(sent["listenCompleted"] as? Bool == true)
            #expect(sent["commented"] as? Bool == true)
        } else {
            #expect(Bool(false)) // fuerza fallo si no hubo body
        }

        #expect(result.listenCompleted == true)
        #expect(result.commented == true)
        #expect(result.comment == "Re-escuchar deluxe")

    }

    // 6) FavoritesAPI.delete
    @Test
    func favorites_delete_calls_endpoint() async throws {
        MockURLProtocol.responder = { _ in (200, Data("{}".utf8)) }
        MockURLProtocol.lastRequest = nil

        let api = FavoritesAPI(session: makeMockSession())
        try await api.delete(id: 10)

        let req = MockURLProtocol.lastRequest
        #expect(req?.httpMethod == "DELETE")
        #expect(req?.url?.absoluteString.hasSuffix("/favorites/10") == true)
    }
}
