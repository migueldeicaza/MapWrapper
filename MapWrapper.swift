//
//  MapWrapper.swift
//  MapWrapper
//
//  Created by Miguel de Icaza on 3/10/23.
//

import Foundation
import SwiftUI
import MapKit

///
/// Provides a wrapper around MKMapView from SwiftUI
/// with an API that sort of resembles the one in SwiftUI's Map
///
/// It deals with adding and removing items smoothly, without
/// flicker.
///
public struct MapKitWrapper<Items: RandomAccessCollection>: UIViewRepresentable where Items.Element: Identifiable, Items.Element: Hashable {
            
    @Binding var region: MKCoordinateRegion
    @Binding var items: Items
    
    var mapper: (Items.Element) -> MKAnnotation
    
    public typealias UIViewType = MKMapView
    
    ///
    /// - Parameters:
    ///  - region: the initial region to display
    ///  - items: collection of items to display, they must confirm to Identifiable
    ///  - mapper: callback that must produce an MKAnnotation on demand from a given Item
    public init (region: Binding<MKCoordinateRegion>, items: Binding<Items>, mapper: @escaping (Items.Element) -> MKAnnotation) {
        self._region = region
        self._items = items
        self.mapper = mapper
    }
    
    public func makeUIView(context: MapKitWrapper.Context) -> MKMapView {
        let map = MKMapView(frame: CGRect.zero)
        map.delegate = context.coordinator
        return map
    }

    public class MapCoordinator: NSObject, MKMapViewDelegate {
        var regionSet: Bool = false
        var computedItems: [Items.Element: MKAnnotation] = [:]
    }
    
    public func makeCoordinator() -> MapCoordinator {
        return MapCoordinator()
    }

    public func updateUIView(_ mapView: MapKitWrapper.UIViewType, context: MapKitWrapper.Context)
    {
        var insertJob: [Items.Element: MKAnnotation] = [:]
        var removeJob: [Items.Element] = []
        var seen = Set<Items.Element> ()
        let coordinator = context.coordinator

        if !coordinator.regionSet {
            coordinator.regionSet = true
            mapView.region = self.region
        }
        for x in items {
            seen.insert(x)
            if coordinator.computedItems [x] == nil {
                insertJob [x] = mapper (x)
            }
        }
        
        for x in coordinator.computedItems.keys {
            if !seen.contains(x) {
                removeJob.append (x)
            }
        }
        
        if insertJob.count > 0 || removeJob.count > 0 {
            var copy = coordinator.computedItems
            for (k,v) in insertJob {
                copy [k] = v
            }
            for k in removeJob {
                copy.removeValue(forKey: k)
            }
            let array: [MKAnnotation] = Array (copy.values)
            mapView.showAnnotations(array, animated: true)
            coordinator.computedItems = copy
        }
    }
}

struct SampleData: Identifiable, Hashable {
    var id = UUID ()
    var lat, long: Double
}

struct MapKitWrapper_Previews: PreviewProvider {
    struct Content: View {
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
    static var previews: some View {
        Content ()
    }
}
