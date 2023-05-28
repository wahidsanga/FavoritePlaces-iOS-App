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
    /// Encapsulates the `name` property of the `Place` class.
    /// This computed property provides a getter and setter for the `name` property, allowing you to access and modify the value conveniently. If the `name` property is `nil`, it returns "unknown" as the default value when accessed.
    var strName:String{
        get{
            self.name ?? "unknown"
        }
        set{
            self.name=newValue
        }
    }
    /// Encapsulates the `location` property of the `Place` class.
    /// This computed property provides a getter and setter for the `location` property, allowing you to access and modify the value conveniently. If the `location` property is `nil`, it returns "unknown" as the default value when accessed.
    var strLocation:String{
        get{
            self.location ?? "unknown"
        }
        set{
            self.location=newValue
        }
    }
    /// Encapsulates the `longitude` property of the `Place` class.
    /// This computed property provides a getter and setter for the `longitude` property, allowing you to access and modify the value conveniently. If the `longitude` property is `nil`, it returns "unknown" as the default value when accessed.
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
    /// Encapsulates the `latitude` property of the `Place` class.
    /// This computed property provides a getter and setter for the `latitude` property, allowing you to access and modify the value conveniently. If the `latitude` property is `nil`, it returns "unknown" as the default value when accessed.
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
    /// Encapsulates the `imgurl` property of the `Place` class.
    /// This computed property provides a getter and setter for the `imgurl` property, allowing you to access and modify the value conveniently. If the `imgurl` property is `nil`, it returns "unknown" as the default value when accessed.
    var strUrl:String{
        get{
            self.imgurl?.absoluteString ?? ""
        }
        set{
            guard let url=URL(string: newValue) else{return}
            self.imgurl=url
        }
    }
    
    /// Fetches the image asynchronously for the place from the specified image URL.
    /// This function makes an asynchronous API request to download the image from the specified `imgurl` and returns it as an `Image` object. The downloaded images are cached to avoid repeated downloads.
    /// - Returns: The downloaded image as an `Image` object.
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
    
    /// Updates the map region to the current place's latitude and longitude.
    /// This function updates the `region` property of the map view to center it around the current place's latitude and longitude. It does not return any value.
    ///  ``` var myPlace = Place()
    ///      myPlace.updateMap()
    ///  ```
    func updateMap() {
        region.center.latitude = latitude
        region.center.longitude = longitude
    }
    
   
    /// Converts the current location coordinates to an address.
    /// This function uses a reverse geocoding API to convert the current location coordinates (latitude and longitude) to an address. The retrieved address components are then used to update the `name` property of the place object. If the reverse geocoding fails or no address components are found, the `name` property is set to a default value.
    /// ``` var myPlace = Place()
    /// myPlace.fromLocToAddress()
    ///```
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
    
    /// This function fetches the sunrise and sunset times for the specified location and assigns them to the `sunrise` and `sunset` properties
    ///  of place object by making an API request to retreive the timeZone information. Decoding is done and assigning is further done.
    /// - Parameters:
    ///    - latitude: The latitude of the location.
    ///    - longitude: The longitude of the location.
    ///    - timeZone: The time zone identifier for the location.
    /// - Note: The `sunrise` and `sunset` properties will be updated asynchronously on the main queue.
    func fetchSunriseSunset() {
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
    
    /// Fetches the time zone for the specified coordinates and assigns it to the `timeZone` property of place object
    /// by making an API request to retreive the timeZone information. Decoding is done and assigning is further done.
    ///- Parameters:
    ///    - latitude: The latitude of the location.
    ///    - longitude: The longitude of the location.
    /// - Note: The `timeZone` property will be updated asynchronously on the main queue.
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
    
    /// View representation of the time zone.
    /// This computed property returns a view that displays the time zone information.
    /// - Returns: A view displaying the time zone.
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
   
    /// View representation of the sunrise time.
    /// This computed property returns a view that displays the sunrise time.
    /// If the sunrise time is available and the time zone is provided, it converts the GMT time to the local time zone.
    /// If the sunrise time is available but the time zone is not provided, it displays the GMT time.
    /// If the sunrise time is not available, it displays a progress view.
    /// - Returns: A view displaying the sunrise time.
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
    
    /// View representation of the sunset time.
    /// This computed property returns a view that displays the sunset time.
    /// If the sunset time is available and the time zone is provided, it converts the GMT time to the local time zone.
    /// If the sunset time is available but the time zone is not provided, it displays the GMT time.
    /// If the sunset time is not available, it displays a progress view.
    /// - Returns: A view displaying the sunset time.
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
    
    /// Function to convert GMT time to the local time zone.
    /// This function takes a GMT time and a time zone identifier as input and returns the local time in the specified time zone.
    /// It uses DateFormatter to format the input and output time and applies the specified time zone.
    /// - Parameters:
    ///   - tm: The GMT time to convert.
    ///   - tz: The time zone identifier for the local time.
    /// - Returns: The local time converted from GMT.
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


/// This function saves the data to the database using the shared view context of the PersistenceHandler.
/// - Note: If an error occurs while saving, it is printed to the console.
func saveData(){
    let ctx=PersistenceHandler.shared.container.viewContext
    do{
        try ctx.save()
    }catch{
        print("Error to save with \(error)")
    }
}


/// This function creates a new Place object with default values and saves it to the database using the shared view context of the PersistenceHandler.
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


/// This function loads the defaultPlaces array and creates Place instances in the database using the shared view context of the PersistenceHandler.
/// Each element in the defaultPlaces array represents a place with its name, location, latitude, longitude, and image URL.
/// The function iterates over the defaultPlaces array, creates a new Place instance for each element, and sets the properties of the new instance.
/// Finally, the `saveData()` function is called to save the created instances to the database.
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


/// Structure to represent the time zone obtained from an API.
struct MyTimeZone: Decodable {
    var timeZone: String
}

/// Structure to represent the sunrise and sunset times obtained from an API.
struct SunriseSunset: Decodable {
    var sunrise: String
    var sunset: String
}

/// Structure to represent the API response for sunrise and sunset times.
struct SunriseSunsetAPI: Decodable {
    var results: SunriseSunset
}


