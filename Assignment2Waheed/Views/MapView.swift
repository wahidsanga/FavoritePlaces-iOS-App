//
//  MapView.swift
//  FavouritePlaces
//
//  Created by Waheed Hasan on 8/5/2023.
//

import SwiftUI
import CoreData
import MapKit

//overriding MKCoordinateRegion class
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
////overriding MKCoordinateRegion class to conform to equatable
extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.latStr == rhs.latStr && lhs.longStr == rhs.longStr
    }
}

/// MapView displays the name of the location, its coordinates, as well as an interactive map showing the location.
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
            HStack{
                if(isEditing){
                    Image(systemName: "magnifyingglass.circle")
                        .onTapGesture {
                            place.fromLocToAddress()
                            name=place.strName
                            saveData()
                    }
                    TextField("location name: ", text: $name)
                }
                else{
                    Text(name)
                }
            } .onChange(of: name) { _ in
                place.strName=name
                saveData()
            }
            ZStack{
                /// map showing
                Map(coordinateRegion: $region)
                VStack(alignment: .leading){
                    Text("")
                }
            }
            if(!isEditing){
                VStack{
                    Text("Latitude:\(latitude)")
                    Text("Longitude:\(longitude)")
                }
            }
            else{
                HStack{
                    Image(systemName: "globe").foregroundColor(Color.blue)
                        .onTapGesture {
                        fromAddressToLoc()
                    }
                    VStack{
                        HStack{
                            Text("latitude: ")
                            TextField("latitude: ", text: $region.latStr)
                        }
                        HStack{
                            Text("longitude: ")
                            TextField("longitude: ", text: $region.longStr)
                        }
                    }
                }
                /// to change the value of latitude and longitude after updating
                .onChange(of: region) { _ in
                    latitude = region.latStr
                    longitude = region.longStr
                }
            }
        }.onAppear{
            region.center.latitude = place.latitude
            region.center.longitude = place.longitude
            latitude = place.strLatitude
            longitude = place.strLongitude
            saveData()
        }.onDisappear{
            place.latitude = region.center.latitude
            place.longitude = region.center.longitude
            place.name = name
            saveData()
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
    /// function to checkmap and update
    func checkMap() {
        latitude = place.strLatitude
        longitude = place.strLongitude
        region.center.latitude = place.latitude
        region.center.longitude = place.longitude
    }
    func fromAddressToLoc() {
        let coder = CLGeocoder()
        coder.geocodeAddressString(name) { marks, error in
            if let err = error {
                print("errof in fromAddressToLoc \(err)")
                return
            }
            guard let pmk = marks?.first else {
                print("can't find primary placemark in address to loc")
                return
            }
            region.center.latitude = pmk.location?.coordinate.latitude ?? 0.0
            region.center.longitude = pmk.location?.coordinate.longitude ?? 0.0
        }
    }
}

