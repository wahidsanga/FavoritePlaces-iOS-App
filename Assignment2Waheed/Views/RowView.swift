//
//  RowView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI

/// displays each row of the Places List on the the master with and includes an image icon plus the name of the place
/// - Parameters:
///   - place:An observed object representing a Place instance.
///   - image:A state variable holding the image associated with a landmark of the place.
struct RowView: View {
    @ObservedObject var place: Place
    @State var image = defaultImage
    var body: some View {
        HStack{
            image.frame(width: 20, height: 20)
            Text(place.strName)
        }
        .task {
            image = await place.getImage()
        }
    }
}
