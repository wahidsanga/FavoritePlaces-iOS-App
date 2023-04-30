//
//  RowView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI

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
