//
//  MapView.swift
//  FavouritePlaces
//
//  Created by Waheed Hasan on 8/5/2023.
//

import SwiftUI
import CoreData
import MapKit

extension MKCoordinateRegion {
    var latStr: String {
        get{
            "\(center.latitude)"
        }
        set{
            guard let d = Double(newValue) else {return}
            center.latitude = d
        }
    }
    var longStr: String {
        get{
            "\(center.longitude)"
        }
        set{
            guard let d = Double(newValue) else {return}
            center.longitude = d
        }
    }
}

struct MapView: View {
    @ObservedObject var place: Place
    @State var name = ""
    @State var latitude = "0.0"
    @State var longitude = "0.0"
    @State var delta = 100.0
    @State var isEditing = false
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
                                           span: MKCoordinateSpan(latitudeDelta: 10.0, longitudeDelta: 10.0))
    

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            ZStack{
                Map(coordinateRegion: $region)  //adds map
                VStack(alignment: .leading){
                    Text("")
                }
                
            }
            if(!isEditing){
                VStack{
                    Text("Latitude: \(latitude) ")
                    Text("longitude: \(longitude)")
                   // Text("Latitude:\(region.center.latitude)")
                    //Text("Longitude:\(region.center.longitude)")
                }.onAppear{
                    print(place.strLatitude)
                }
            }
            else{
                VStack{
                    HStack{
                        Text("latitude: ")
                        TextField("latitude: ", text: $region.latStr)
                        Button("+"){
                            print(region.latStr)
                            latitude=region.latStr
                        }
                    }
                    HStack{
                        Text("longitude: ")
                        TextField("longitude: ", text: $region.longStr)
                        Button("+"){
                            print(region.longStr)

                            longitude=region.longStr

                        }
                    }
                }
                .onDisappear{
                    longitude=region.longStr
                    latitude=region.latStr
                }
            }
        }
        .onAppear{
            latitude = place.strLatitude
            longitude = place.strLongitude
            saveData()
        }.onDisappear{
        }
        .navigationTitle("Map of \(name)")
        .navigationBarItems(trailing: Button("\(isEditing ? "Done" : "Edit")"){
            if(isEditing) {
                place.strLatitude = latitude
                place.strLongitude = longitude
                saveData()
                place.updateMap()
                Task {
                    checkMap()
                }
            }
            isEditing.toggle()
        })
        .padding()
        .task {
            checkMap()
        }
    }
    func checkMap() {
        latitude = place.strLatitude
        longitude = place.strLongitude
        region.center.latitude = place.latitude
        region.center.longitude = place.longitude
    }
}
