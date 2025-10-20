//
//  AlbumsTabView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

//Se separa esta view en lugar de ponerla en el ContentView para respetar las reglas de Clean Code de small views, muestra los ablumes en forma de tarjetas
struct AlbumsTabView: View {
    @State private var vm = AlbumViewModel()
    
    var body: some View {
        
        NavigationStack{
            Group {
                // Estado de carga inicial
                if vm.isLoading && vm.arrAlbums.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView("Cargando álbumes…")
                        if let msg = vm.userMessage {
                            Text(msg).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                    .padding()

                    // Estado de error sin datos cargados
                } else if vm.arrAlbums.isEmpty {
                    VStack(spacing: 12) {
                        Text(vm.userMessage ?? "No se encontraron datos.")
                            .multilineTextAlignment(.center)
                        Button("Reintentar") { Task { await vm.loadAPI() } }
                    }
                    .padding()

                    // Estado con datos
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16){
                            ForEach(vm.arrAlbums) { album in
                                NavigationLink {
                                    AlbumDetailView(album: album) //Single Responsability: otra vista se encarga del detalle del album para no sobrecargar esta
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        CoverImageView(album: album)
                                            .frame(height: 225) //Single Responsability: otra vista se encarga de recolectar la información de la imágen ya que esta se va a reutilizar
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                        
                                        Text(album.name)
                                            .font(.headline)
                                            .foregroundStyle(.blue.opacity(0.8))
                                            .fontWeight(.bold)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                                    )
                                }
                                .padding(.horizontal, 13)
                                .padding(.vertical, 6)
                            }

                        }
                    }
                    .refreshable {
                      await vm.loadAPI()
                    }
                    
                    // Overlay de carga cuando se refresca con datos
                    .overlay(alignment: .top) {
                        if vm.isLoading {
                            ProgressView().padding(.top, 8)
                        }
                    }
                }
                
            }
            .navigationTitle("Taylor Swift")
        }
        //Dispara la primera carga
        .task {await vm.loadAPI() }
    }
    
}

#Preview {
    AlbumsTabView()
}
