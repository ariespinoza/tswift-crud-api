//
//  AlbumViewModel.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import Foundation
import Observation

@Observable
@MainActor
class AlbumViewModel {
    var arrAlbums: [Album] = []
    var userMessage: String?
    var isLoading = false

    private let endpoint = "\(APIConfig.baseURL)/albums"

    func loadAPI() async {
        guard let url = URL(string: endpoint) else {
            userMessage = "La URL del servicio es inválida."
            return
        }
        isLoading = true
        defer { isLoading = false }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                userMessage = "Error del servidor."
                return
            }
            self.arrAlbums = try JSONDecoder().decode([Album].self, from: data)
            self.userMessage = nil

            } catch let error as URLError {
                //Casos para depuración y saber cuál es el error
                switch error.code {
                case .notConnectedToInternet:
                    userMessage = "Sin conexión. Por favor revisa tu red."
                case .timedOut:
                    userMessage = "La conexión expiró. Intenta nuevamente."
                case .cannotFindHost, .cannotConnectToHost:
                    userMessage = "No se pudo conectar al servidor."
                default:
                    userMessage = "Error de red: \(error.localizedDescription)"
                }
                print("Network error:", error)

            } catch {
                userMessage = "Error inesperado: \(error.localizedDescription)"
                print("Unknown error:", error)
            }
    }
}
