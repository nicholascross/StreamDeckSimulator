import Foundation
import SwiftUI
import MapKit
import StreamDeckKit

func makeMapIcon(coordinates: CLLocationCoordinate2D, completion: @escaping (NSImage) -> Void) -> MKMapSnapshotter {
    let mapSnapshotOptions = MKMapSnapshotter.Options()
    let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 100, longitudinalMeters: 100)
    mapSnapshotOptions.appearance = NSAppearance(appearanceNamed: .vibrantLight, bundle: .main)
    mapSnapshotOptions.region = region
    mapSnapshotOptions.size = CGSize(width: 72, height: 72)
    mapSnapshotOptions.showsBuildings = true
    let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)

    snapShotter.start { (snapshot, error) in
        if let image = snapshot?.image {
            completion(image)
        } else {
            logError("Failed to make icon \(error.debugDescription)")
        }
    }

    return snapShotter
}
