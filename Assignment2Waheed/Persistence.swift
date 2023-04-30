//
//  Persistence.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import Foundation
import CoreData
/// data persistence is maintained through persistence Handler
struct PersistenceHandler{
    static let shared=PersistenceHandler()
    let container:NSPersistentContainer
    init(){
    container=NSPersistentContainer(name: "Model")
    container.loadPersistentStores{_, error in
        if let err=error{
            fatalError("Error to load with \(err)")
            }
        }
    }
}
