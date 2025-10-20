//
//  AddFavoritesSheet.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//


import SwiftUI
import SwiftData

struct AddFavoritesSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var context
    
    @State private var name : String = ""
    @State private var artist : String = ""
    @State private var dateAdded: Date = .now
    @State private var favoriteSong : String = ""
    @State private var listenCompleted: Bool = false
    @State private var commented: Bool = false
    @State private var comment : String = ""
    
    @State private var errorMessage: String?
    
    
    var body: some View {
        NavigationStack{
            
            
            Form{
                Section("Album") {
                    TextField("Name", text: $name)
                    TextField("Artist", text: $artist)
                    DatePicker("Registration Date", selection: $dateAdded, displayedComponents: .date)
                    TextField("Favorite Song", text: $favoriteSong)
                    Toggle("Have you listened the album complete?", isOn: $listenCompleted)
                }
                Section("Comment") {
                    Toggle("Add Comment", isOn: $commented)
                    if commented {
                        TextField("Write your comment", text: $comment, axis: .vertical)
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
                    Button("Save") {
                    guard Favorite.isValidName(name) else { return }
                        let favorite = Favorite(name: name, artist: artist, dateAdded: dateAdded, favoriteSong: favoriteSong, listenCompleted: listenCompleted, commented: commented, comment: comment)
                    context.insert(favorite)
                        do {
                            try? context.save()
                            dismiss()
                        } catch {
                            errorMessage = "Failed to save the favorite album: \(error.localizedDescription)"
                        }
                    }
                    .disabled(!Favorite.isValidName(name))

                    /*Button("Save"){
                        let favorite = Favorite(name: name, artist: artist, dateAdded: dateAdded, favoriteSong: favoriteSong, listenCompleted: listenCompleted, commented: commented, comment: comment)
                        context.insert(favorite)
                        do {
                            try! context.save()
                            dismiss()
                        } catch {
                            errorMessage = "Failed to save the favorite album: \(error.localizedDescription)"
                        }
                    }*/
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil), presenting: errorMessage) { _ in
                Button("OK", role: .cancel) { errorMessage = nil }  // Reset error
            } message: { msg in
                Text(msg)
            }
        }
    }
}
#Preview {
   AddFavoritesSheet()
}
