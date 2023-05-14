//
//  ViewModel.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import Foundation
import CoreData
import SwiftUI
import MapKit

let defaultImage=Image(systemName: "photo").resizable()
var downloadImages: [URL:Image] = [:]
var address = ""
var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 100.0, longitudeDelta: 100.0))
var delta = 100.0

extension Place{
    /// encapsulating variables inside the class
    var strName:String{
        get{
            self.name ?? "unknown"
        }
        set{
            self.name=newValue
        }
    }
    var strLocation:String{
        get{
            self.location ?? "unknown"
        }
        set{
            self.location=newValue
        }
    }
    var strLongitude:String {
        get {
            String(format: "%.5f", longitude)
        }
        set {
            guard let long = Double(newValue), long <= 180.0, long >= -180.0
            else {
                return
            }
            longitude = long
        }
    }
    var strLatitude:String {
        get {
            String(format: "%.5f", latitude)
        }
        set {
            guard let lat = Double(newValue), lat <= 90.0, lat >= -90.0
            else {
                return
            }
            latitude = lat
        }
    }
    var strUrl:String{
        get{
            self.imgurl?.absoluteString ?? ""
        }
        set{
            guard let url=URL(string: newValue) else{return}
            self.imgurl=url
        }
    }
    
    /// function to store image url and return image
    /// - Returns: image
    func getImage() async -> Image{
        guard let url=self.imgurl else{return defaultImage}
        if let image=downloadImages[url] {return image}
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiimg = UIImage(data: data) else {return defaultImage}
            let image = Image(uiImage: uiimg).resizable()
            downloadImages[url]=image
            return image
        }catch{
            print("Error in download image \(error)")
        }
        return defaultImage
    }
    
    func updateMap() {
        region.center.latitude = latitude
        region.center.longitude = longitude
    }
}

/// function to save data to the database
func saveData(){
    let ctx=PersistenceHandler.shared.container.viewContext
    do{
        try ctx.save()
    }catch{
        print("Error to save with \(error)")
    }
}

func addPlace() {
    let ctx = PersistenceHandler.shared.container.viewContext
    let place = Place(context: ctx)
    place.name = "New Place"
    place.location = ""
    place.latitude = 0.0
    place.longitude = 0.0
    saveData()
}

func loadDefaultData() {
    let ctx = PersistenceHandler.shared.container.viewContext
    let defaultPlaces = [["Japan","Mount fuji","35.3606","138.7274",
                          "https://www.planetware.com/photos-large/JPN/japan-mt-fuji-and-cherry-blossoms.jpg"],
                         ["Kashmir","Gulmarg","34.0484","74.3805",
                          "https://media.tacdn.com/media/attractions-splice-spp-674x446/06/e4/c8/e5.jpg"],
                         ["Dubai","Burj Khalifa","0","0",
                          "https://media.tacdn.com/media/attractions-splice-spp-674x446/07/74/81/8c.jpg"]]
    
    defaultPlaces.forEach {
        let place = Place(context: ctx)
        place.strName = $0[0]
        place.strLocation = $0[1]
        place.strLatitude = $0[2]
        place.strLongitude = $0[3]
        place.strUrl = $0[4]
    }
    saveData()
}
