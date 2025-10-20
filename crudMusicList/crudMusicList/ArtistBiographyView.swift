//
//  ArtistBiographyView.swift
//  crudMusicList
//
//  Created by Ariana Espinoza on 30/09/25.
//

import SwiftUI

struct ArtistBiographyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16){
            
            Image("TaylorSwift")
                .resizable()
                .scaledToFill()
                .frame(width: 325, height: 325)
            
            Text("Taylor Swift")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Biography")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.top, 10)
                .fontWeight(.bold)
            
            Text("Taylor Swift is an American singer-songwriter born on December 13, 1989, in Reading, Pennsylvania. She started in country music and became famous with songs like Love Story. Later, she moved to pop and won many awards, including Grammys. She is also re-recording her old albums to own her music.")
                .font(.body)
                .lineSpacing(5)
                .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding()
    }
}

#Preview {
    ArtistBiographyView()
}
