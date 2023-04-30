//
//  ViewModel.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import Foundation
import CoreData
import SwiftUI

let defaultImage=Image(systemName: "photo").resizable()
var downloadImages: [URL:Image] = [:]

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
    var strLatitude:String{
        get{
            "\(self.latitude)"
        }
        set{
            guard let latitude=Float(newValue) else{return}
            self.latitude=latitude
        }
    }
    var strLongitude:String{
        get{
            "\(self.longitude)"
        }
        set{
            guard let longitude=Float(newValue) else{return}
            self.longitude=longitude
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
