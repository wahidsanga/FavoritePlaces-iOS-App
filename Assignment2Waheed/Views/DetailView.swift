//
//  DetailView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI
import CoreData
import MapKit
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
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
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
                    NavigationLink(destination: MapView(place: place, name: name, latitude: latitude, longitude:longitude)) {
                        Map(coordinateRegion: $region).frame(width: 50,height: 50)
                        Text("Map of \(name)")
                    }
                    Text("\(location)")
                }
            }else{
                List{
                    TextField("Name: ", text: $name)
                    TextField("Url: ", text: $url)
                    Text("Enter Location Details:")
                        .font(.title3)
                        .fontWeight(.bold)
                    TextField("Location details: ", text: $location)
                }
            }
            HStack{
                Image(systemName: "sunrise")
                place.SunriseView
                Spacer()
                Image(systemName: "sunrise.fill")
                place.SunsetView
            }.padding()
        }
        .onAppear(){
            name = place.strName
            location = place.strLocation
            url = place.strUrl
            longitude = place.strLongitude
            latitude = place.strLatitude
            region.center.longitude = place.longitude
            region.center.latitude = place.latitude
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
            place.fetchTimeZone()
            place.fetchSunriseSunset()
        }
    }
}

