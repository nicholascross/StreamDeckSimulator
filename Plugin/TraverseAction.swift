import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public final class TraverseAction: SetSimulatorLocationAction {
    private let connection: StreamDeckConnection
    
    var currentPosition: CLLocationCoordinate2D?
    var currentSimulator: Simulator?
    var deviceId: String?
    
    override init(connection: StreamDeckConnection) {
        self.connection = connection
        super.init(connection: connection)
    }
    
    public override func keyUp(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        super.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        currentPosition = coordinatesForContext(context)
        currentSimulator = simulatorForContext(context)
        logDebug("current: \(currentSimulator) - \(currentPosition) - \(self.deviceId)")
        
        guard let deviceId = self.deviceId else {
            logError("Device id not set")
            return
        }
        
        connection.switchToProfile("Travel", context: connection.pluginUUID, deviceId: deviceId)
    }
}
