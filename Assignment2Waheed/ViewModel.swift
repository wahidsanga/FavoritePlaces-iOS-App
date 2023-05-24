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
    
    func fromLocToAddress() {
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { marks, error in
            if let err = error {
                print("error in fromLocToAddress: \(err)")
                return
            }
            guard let mark = marks?.first else {
                print("can't find primary placemark in loc to address")
                return
            }
            self.name = mark.name ?? mark.country ?? mark.locality ?? mark.administrativeArea ?? "No name"
        }
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

/// function to create a new place instance and store in the database
func addPlace() {
    let ctx = PersistenceHandler.shared.container.viewContext
    let place = Place(context: ctx)
    place.name = "New Place"
    place.location = ""
    place.latitude = 0.0
    place.longitude = 0.0
    saveData()
}

//default data shown in the app when there is no user data stored
 let defaultPlaces = [["Japan","Mount fuji","35.3606","138.7274",
                      "https://www.planetware.com/photos-large/JPN/japan-mt-fuji-and-cherry-blossoms.jpg"],
                     ["Kashmir","Gulmarg","34.0484","74.3805",
                      "https://media.tacdn.com/media/attractions-splice-spp-674x446/06/e4/c8/e5.jpg"],
                     ["Dubai","Burj Khalifa","0","0",
                      "https://media.tacdn.com/media/attractions-splice-spp-674x446/07/74/81/8c.jpg"]]

/// function to store default data into database
func loadDefaultData() {
    let ctx = PersistenceHandler.shared.container.viewContext
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


struct MyTimeZone: Decodable{
    var timeZone:String
}

struct SunriseSunset:Decodable {
    var sunrise:String
    var sunset:String
}

struct SunriseSunsetAPI:Decodable {
    var results: SunriseSunset
}

extension Place{
    func fetchSunriseSunset() {
        //"https://api.sunrise-sunset.org/json?lat=\(self.strLatitude)&lng=\(self.strLongitude)"
        let urlStr="https://api.sunrise-sunset.org/json?lat=\(self.strLatitude)&lng=\(self.strLongitude)&date=today"
        guard let url=URL(string: urlStr) else {return}
        let request=URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, _, _ in
            guard let data = data,
                  let api=try? JSONDecoder().decode(SunriseSunsetAPI.self, from: data)
            else {return}  //need timezone struct
            DispatchQueue.main.async {
                self.sunrise=api.results.sunrise
                self.sunset=api.results.sunset
            }
        }.resume()
    }
    
    func fetchTimeZone() {
        let urlStr="https://timeapi.io/api/TimeZone/coordinate?latitude=\(self.latitude)&longitude=\(self.longitude)"
        guard let url=URL(string: urlStr) else {return}
        let request=URLRequest(url: url)
        URLSession.shared.dataTask(with: request){ data, _, _ in
            guard let data = data,
                  let api=try? JSONDecoder().decode(MyTimeZone.self, from: data)
            else {return}  //need timezone struct
            DispatchQueue.main.async {
                self.timeZone = api.timeZone
            }
        }.resume()
    }
    var timeZoneView: some View{
        HStack{
            Text("TimeZone: ")
            if let tz=self.timeZone {
                Text(tz)
            }else{
                    ProgressView()
                }
        }
    }
    var SunriseView: some View{
        HStack{
            if let tm = self.sunrise {
                if let tz = self.timeZone {
                    let ltm = self.getLocalTimeFromGMT(tm, tz)
                    Text("\(ltm)")
                }
                else{
                    Text("GMT:\(tm)")
                }
            }else{
                    ProgressView()
            }
        }
    }
    var SunsetView: some View{
        HStack{
            if let tm = self.sunset {
                if let tz = self.timeZone {
                    let ltm = self.getLocalTimeFromGMT(tm, tz)
                    Text("\(ltm)")
                }
                else{
                    Text("GMT:\(tm)")
                }
            }else{
                    ProgressView()
            }
        }
    }
    
    func getLocalTimeFromGMT (_ tm:String, _ tz:String) -> String  {
        let inputFormatter = DateFormatter()
        inputFormatter.dateStyle = .none
        inputFormatter.timeStyle = .medium
        inputFormatter.timeZone = .init(secondsFromGMT:0)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .none
        outputFormatter.timeStyle = .medium
        outputFormatter.timeZone = TimeZone(identifier: tz)
        
        if let time=inputFormatter.date(from: tm) {
            return outputFormatter.string(from: time)
        }
            return ""
    }
}

