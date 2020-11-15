import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public class TraverseToAction {
    private let connection: StreamDeckConnection
    private let traverseAction: TraverseAction
    private var keyReferences: [KeyReference] = []
    
    init(connection: StreamDeckConnection, traverseAction: TraverseAction) {
        self.connection = connection
        self.traverseAction = traverseAction
    }
    
    public func keyDown(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        guard let location = traverseAction.currentPosition,
           let simulator = traverseAction.currentSimulator else {
            return
        }
        
        let updatedLocation = offsetLocation(location: location, coordinates: coordinates)
        SimulatorControl().updateLocations(coordinate: updatedLocation, identifiers: [simulator.udid])
        connection.showOkay(context: context)
        
        traverseAction.currentPosition = updatedLocation
        keyReferences.forEach { keyReference in
            updateIcon(context: keyReference.context, coordinates: keyReference.coordinates)
        }
    }

    public func willAppear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        keyReferences.append(.init(coordinates: coordinates, context: context))
        updateIcon(context: context, coordinates: coordinates)
    }
    
    public func willDisappear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        keyReferences.removeAll { $0.coordinates == coordinates }
    }
    
    private func updateIcon(context: String, coordinates: (row: Int, column: Int)) {
        self.connection.setButtonIcon(context: context) {
            Image(nsImage: .init(color: .blue, size: .init(width: 72, height: 72)))
        }
        
        guard let location = traverseAction.currentPosition,
           let simulator = traverseAction.currentSimulator else {
            return
        }
        
        makeMapIcon(coordinates: offsetLocation(location: location, coordinates: coordinates)) { image in
            self.connection.setButtonIcon(context: context) {
                ZStack {
                    Image(nsImage: image)
                    if simulator.state == .booted {
                        bootedOverlay(color: .green)
                    } else {
                        bootedOverlay(color: .red)
                    }
                }
            }
        }
    }
    
    public func offsetLocation(location: CLLocationCoordinate2D, coordinates: (row: Int, column: Int)) -> CLLocationCoordinate2D {
        let metersPerDegree = 111111.0 // rough calculation; apparently doesn't work near poles
        let offset: Double = PluginConstants.zoomLevel / metersPerDegree
        let relativeCoordinates = (row: 1 - coordinates.row, column: coordinates.column - 2)
        
        return CLLocationCoordinate2D(latitude: location.latitude + Double(relativeCoordinates.row) * offset, longitude: location.longitude + Double(relativeCoordinates.column) * offset)
    }

}

private struct KeyReference {
    let coordinates: (row: Int, column: Int)
    let context: String
}
