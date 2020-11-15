import Foundation
import SwiftUI
import MapKit
import StreamDeckKit

func makeMapIcon(coordinates: CLLocationCoordinate2D, completion: @escaping (NSImage) -> Void) {
    let mapSnapshotOptions = MKMapSnapshotter.Options()
    let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: PluginConstants.zoomLevel, longitudinalMeters: PluginConstants.zoomLevel)
    guard CLLocationCoordinate2DIsValid(coordinates) else {
        completion(.init(color: .red, size: .init(width: 72, height: 72)))
        return
    }
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
}

func bootedOverlay(color: Color) -> some View {
    return Circle().fill(color).frame(width: 10, height: 10).offset(x: -5.0, y: -5.0).frame(width: 72, height: 72, alignment: .bottomTrailing)
}
