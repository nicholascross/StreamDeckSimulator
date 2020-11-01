import CoreLocation
import Foundation
import Shell

public final class SimulatorControl {
    
    public func simulators() throws -> [Simulator] {
        let simulators = try JSONDecoder().decode(Simulators.self, from: shell.xcrun("simctl list -j devices").outputData)
        return simulators.devices.values.flatMap { $0 }
    }
    
    public func updateLocations(coordinate: CLLocationCoordinate2D, identifiers: [SimulatorIdentifier]) {
        let userInfo: [String: Any] = [
            "simulateLocationLatitude": coordinate.latitude,
            "simulateLocationLongitude": coordinate.longitude,
            "simulateLocationDevices": identifiers.map { $0.uuidString },
        ]

        let notification = Notification(
            name: Notification.Name(rawValue: "com.apple.iphonesimulator.simulateLocation"),
            object: nil,
            userInfo: userInfo
        )
    
        DistributedNotificationCenter.default().post(notification)
    }
    
}

public struct Simulators: Decodable {
    public let devices: [String: [Simulator]]
}

public struct Simulator: Decodable {
    public let state: SimulatorState
    public let name: String
    public let udid: SimulatorIdentifier
}

public enum SimulatorState: String, Decodable {
    case shutdown = "Shutdown"
    case booted = "Booted"
}

public typealias SimulatorIdentifier = UUID
