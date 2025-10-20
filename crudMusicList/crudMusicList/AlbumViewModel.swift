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
    //Mensaje para el usuario de errores o estados
    var userMessage: String?
    //Feedback de carga
    var isLoading = false

    //URL de API propia y endpoint centralizado para editarlo unicamente en una view
    #if targetEnvironment(simulator)
    private let endpoint = "http://localhost:4000/albums"
    #endif

    //Single responsability: responsabilidad de traer los datos desde el API y actualiza el estado
    func loadAPI() async {
            guard let url = URL(string: endpoint) else {
                userMessage = "La URL del servicio es inválida."
                return
            }

            isLoading = true
            defer { isLoading = false }  // se ejecuta al salir si fue un éxito o fallo

            do {
                let (data, response) = try await URLSession.shared.data(from: url)

                //Validación de la respuesta del Http
                guard let http = response as? HTTPURLResponse else {
                    userMessage = "Respuesta inválida del servidor."
                    return
                }

                guard http.statusCode == 200 else {
                    //Clean code: mensaje legible y amigable para el usuario en lugar de solo números
                    userMessage = "Error del servidor (código \(http.statusCode))."
                    return
                }

                //Decoficicación de la información del JSON
                let resp = try JSONDecoder().decode(AlbumsResponse.self, from: data)
                self.arrAlbums = resp.items
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
