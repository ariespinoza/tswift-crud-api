//
//  crudMusicListTests.swift
//  crudMusicListTests
//
//  Created by Emmy Molina Palma on 1/10/25.
//

import Testing
import Foundation
@testable import crudMusicList


struct crudMusicListTests {
    
    //Test 1: validate that the name isn't empty or has spaces.
    @Test("Movie name must not be empty or whitespace")
    func testNameValidation() {
        #expect(Favorite.isValidName("Folklore"))
        #expect(!Favorite.isValidName(""))
        #expect(!Favorite.isValidName("   "))
    }
    
    //Test 2: validate that the name's lenght boundaries are valid
    @Test("Name length boundaries still valid if non-empty")
    func testNameBoundary() {
        #expect(Favorite.isValidName("A"))
        #expect(Favorite.isValidName(String(repeating: "X", count: 255)))
    }

    //Test 3: Test all parts of CRUD are working well
    @Test("CRUD with SwiftData Tests ")
    @MainActor
    func testCRUDInMemory() throws {
        // container in memory
        let container = try ModelContainer(
            for: Favorite.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let ctx = container.mainContext

        // Create
        let favorite = Favorite(name: "Test Album", artist: "Test Artist", dateAdded: "07/07/2005",
                                favoriteSong: "Test Song", listenCompleted: true, commented: true, comment: "Great album!")
        ctx.insert(favorite)
        try ctx.save()

        // Read
        var all = try ctx.fetch(FetchDescriptor<Favorite>())
        var match = all.first(where: { $0.name == "Test Album" })
        #expect(match != nil)

        // Update
        match?.comment = "Updated comment"
        try ctx.save()
        all = try ctx.fetch(FetchDescriptor<Favorite>())
        match = all.first(where: { $0.name == "Test Album" })
        #expect(match?.comment == "Updated comment")

        // Delete
        if let toDelete = match {
            ctx.delete(toDelete)
            try ctx.save()
        }
        all = try ctx.fetch(FetchDescriptor<Favorite>())
        #expect(!all.contains(where: { $0.name == "Test Album" }))
    }
}


