//
//  DetailView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI
import CoreData
/// the DetailView displays all the data associated with a place including its description, image url, latitude and longitude
struct DetailView: View {
    @ObservedObject var place: Place
    @State var name = ""
    @State var location = ""
    @State var url = ""
    @State var longitude = ""
    @State var latitude = ""
    @Environment(\.editMode) var editMode
    @State var image = defaultImage
    var body: some View {
        VStack{
            if(editMode?.wrappedValue == .inactive){
                List {
                    if url == ""{
                        image.frame(width: 20, height: 20)
                    }
                    else{
                        image.scaledToFit()
                    }
                    Text("\(location)")
                    VStack{
                        Text("Latitude: \(latitude)")
                        Text("Longitude: \(longitude)")
                    }
                }
            }else{
                List{
                    TextField("New Name:", text: $name)
                    TextField("Enter image URL", text: $url)
                    Text("Enter Location Details:").font(.headline)
                    TextField("Loaction: ", text: $location)
                    VStack{
                        HStack{
                            Text("Latitude: ")
                            TextField("Latitude: ", text: $latitude)
                        }
                        HStack{
                            Text("Longitude: ")
                            TextField("Longitude: ", text: $longitude)
                        }
                    }
                }
            }
        }
        .onAppear(){
            name = place.strName
            location = place.strLocation
            url = place.strUrl
            longitude = place.strLongitude
            latitude = place.strLatitude
            saveData()
        }
        .onDisappear(){
            place.strName = name
            place.strUrl = url
            place.strLocation = location
            place.strLongitude = longitude
            place.strLatitude = latitude
            saveData()
        }
        .navigationTitle(name)
        .navigationBarItems(trailing: EditButton())
        .task {
            await image = place.getImage()
        }
    }
}

