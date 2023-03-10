//
//  ContentView.swift
//  Sample
//
//  Created by Miguel de Icaza on 3/10/23.
//

import SwiftUI
import MapWrapper
import MapKit


struct SampleData: Identifiable, Hashable {
    var id = UUID ()
    var lat, long: Double
}

struct ContentView: View {
    @State var region: MKCoordinateRegion = MKCoordinateRegion (
        center: CLLocationCoordinate2D (latitude: 40.706, longitude: -74.008),
        span: MKCoordinateSpan (latitudeDelta: 20, longitudeDelta: 20))
    
    @State var items: [SampleData] = [
        SampleData (lat: 42.354303, long: -71.065636),
        SampleData (lat: 48.856117, long: 2.314073)
    ]
    
    var body: some View {
        MapKitWrapper (region: $region, items: $items) { v -> MKAnnotation in
            let a = MKPointAnnotation()
            a.coordinate = CLLocationCoordinate2D (latitude: v.lat, longitude: v.long)
            return a
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
