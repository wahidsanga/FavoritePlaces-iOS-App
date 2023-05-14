//
//  ContentView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI

/// the master view
struct ContentView: View {
    /// managed object context represents a single object space, or scratch pad, in a Core Data application
    @Environment(\.managedObjectContext) var ctx
    @FetchRequest(sortDescriptors: []) var places:FetchedResults<Place>
    var body: some View {
        VStack{
            NavigationView{
                List{
                    ForEach(places){
                        place in
                        NavigationLink(destination: DetailView(place: place)) {
                            RowView(place: place)
                        }
                    }.onDelete {
                        idx in idx.map{places[$0]}.forEach{place in ctx.delete(place)}
                        saveData()
                    }
                }
                .navigationTitle("Favourite Places")
                .navigationBarItems(leading: Button("+"){
                    addPlace()}, trailing: EditButton())
            }
        }.task {
            if(places.count == 0) {
                    loadDefaultData()
            }
        }
    }
    
    /// this function adds a new Place instance and saves in in the database
    func addPlace(){
        let place=Place(context: ctx)
        place.name="New Place"
        place.latitude=0.0
        place.longitude=0.0
        saveData()
    }
}
