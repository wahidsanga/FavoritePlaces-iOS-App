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

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.latStr == rhs.latStr && lhs.longStr == rhs.longStr
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
                }
            }
            else{
                VStack{
                    HStack{
                        Text("latitude: ")
                        TextField("latitude: ", text: $region.latStr)
                    }
                    HStack{
                        Text("longitude: ")
                        TextField("longitude: ", text: $region.longStr)
                    }
                }.onChange(of: region) { _ in
                    latitude = region.latStr
                    longitude = region.longStr
                }
            }
        }
        .onAppear{
                latitude = place.strLatitude
                longitude = place.strLongitude
                saveData()
        }
        .navigationTitle("Map of \(name)")
        .navigationBarItems(trailing: Button("\(isEditing ? "Done" : "Edit")"){
            if(isEditing) {
                place.strLatitude = latitude
                place.strLongitude = longitude
                saveData()
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
