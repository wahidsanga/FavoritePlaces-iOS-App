//
//  ContentView.swift
//  Assignment2Waheed
//
//  Created by Waheed Hasan on 29/4/2023.
//

import SwiftUI

struct ContentView: View {
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
        }
//        .onAppear{saveData()}
//            .onDisappear{
//                saveData()
//            }
    }
    
    func addPlace(){
        let place=Place(context: ctx)
        place.name="New Place"
        place.latitude=0.0
        place.longitude=0.0
        saveData()
    }
}
