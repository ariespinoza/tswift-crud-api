//
//  UpdateFavoritesSheet.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//


import SwiftUI
import SwiftData

struct UpdateFavoriteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    
    @Bindable var favorite : Favorite
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack{
            
            
            Form{
                Section("Album") {
                    TextField("Name", text: $favorite.name)
                    TextField("Artist", text: $favorite.artist)
                    DatePicker("Registration Date", selection: $favorite.dateAdded, displayedComponents: .date)
                    TextField("Favorite Song", text: $favorite.favoriteSong)
                    Toggle("Have you listened the album complete?", isOn: $favorite.listenCompleted)
                }
                Section("Comment") {
                    Toggle("Add Comment", isOn: $favorite.commented)
                    if favorite.commented {
                        TextField("Write your comment", text: $favorite.comment, axis: .vertical)
                            .lineLimit(4, reservesSpace: true)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                }
                
            }
            .navigationTitle("Add Favorite")
            .navigationBarTitleDisplayMode(.large)
            .toolbar{
                ToolbarItemGroup(placement: .topBarLeading){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing){
                    Button("Done") {
                        do {
                            try context.save()
                            dismiss()
                        } catch {
                            errorMessage = "Failed to save changes: \(error.localizedDescription)"
                        }
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in Button("OK", role: .cancel) { errorMessage = nil }  // Reset error
            } message: { msg in
                Text(msg)
            }
        }
    }
}

#Preview {
    //UpdateTravelGoalSheet(travelGoal: TravelGoal(name: "Chiapas", dateAdded: .now, visited: false))
}
