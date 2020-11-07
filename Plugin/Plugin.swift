import Foundation
import StreamDeckKit
import CoreLocation

public final class Plugin: StreamDeckConnectionDelegate {
    private let connection: StreamDeckConnection
    private var loadedSettings: [String:Settings] = [:]
    
    init(connection: StreamDeckConnection) {
        self.connection = connection
    }
    
    public func didLaunchApplication(_ application: String) {
        
    }
    
    public func didTerminateApplication(_ application: String) {
        
    }
    
    public func didConnectDevice(_: String, info: DeviceInfo) {
        
    }
    
    public func didDisconnectDevice(_: String, info: DeviceInfo) {
        
    }
    
    var snapshotLoader: Any?
    public func didReceiveSettings(_ settings: [String : Any], action: String, context: String, device: String) {
        logDebug("didReceiveSettings: \(settings)")
        settings.forEach {
            var settings = loadedSettings[context] ?? Settings()
            settings.update(key: $0.key, value: $0.value)
            loadedSettings[context] = settings
        }
        
        updateIcon(context: context)
        
        struct Device: Encodable {
            let name: String
            let udid: String
            let selected: Bool
        }
        
        struct Simulators: Encodable {
            var booted: [Device]
            var shutdown: [Device]
        }

        do {
            let simulators = try SimulatorControl().simulators()
            
            let selected: String?
            if let simulator = settings[Fields.simulator.rawValue] as? String {
                selected = simulator
            } else {
                // set default simulator
                selected = (simulators.first { $0.state == .booted }.map { $0.udid.uuidString }) ??
                    (simulators.first { $0.state == .shutdown }.map { $0.udid.uuidString })
                
                loadedSettings[context]?.simulator = selected
                connection.setSettings(loadedSettings, context: context)
            }

            let booted = simulators.filter { $0.state == .booted }.map { Device(name: $0.name, udid: $0.udid.uuidString, selected: selected == $0.udid.uuidString) }
            let shutdown = simulators.filter { $0.state == .shutdown }.map { Device(name: $0.name, udid: $0.udid.uuidString, selected: selected == $0.udid.uuidString) }

            connection.sendToPropertyInspector(Simulators(booted: booted, shutdown: shutdown), action: action, context: context)
        } catch {
            logError("Failed to detect simulators")
        }
        
        struct Coords: Encodable {
            let latitude: String?
            let longitude: String?
        }
        
        let coords = Coords(latitude: loadedSettings[context]?.latitude, longitude: loadedSettings[context]?.longitude)
        connection.sendToPropertyInspector(coords, action: action, context: context)
    }
    
    public func didReceiveGlobalSettings(_ settings: [String : Any]) {
        logDebug("didReceiveGlobalSettings: \(settings)")
    }
    
    public func keyDown(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        guard let lat = loadedSettings[context]?.latitude, let long = loadedSettings[context]?.longitude, let latitude = Double(lat), let longitude = Double(long) else {
            connection.showAlert(context: context)
            return
        }
        
        guard let udid = loadedSettings[context]?.simulator, let simulator = UUID(uuidString: udid) else {
            connection.showAlert(context: context)
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        SimulatorControl().updateLocations(coordinate: location, identifiers: [simulator])
        connection.showOkay(context: context)
    }
    
    public func keyUp(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        
    }
    
    public func didWakeUp() {
        
    }
    
    public func propertyInspectorDidAppear(action: String, context: String, device: String) {
        logDebug("Property inspector did appear")
        
        connection.getSettings(context: context)
    }
    
    public func propertyInspectorDidDisappear(action: String, context: String, device: String) {
        logDebug("Property inspector did disappear")
    }
    
    public func willAppear(_: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        logDebug("will appear: \(action)")
        connection.getSettings(context: context)
    }
    
    public func willDisappear(_: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        logDebug("will disappear: \(action)")
    }
    
    public func receivedPayloadFromPropertyInspector(_ payload: [String : Any], action: String, context: String) {
        if payload.count == 1, let key = payload.first?.key, let value = payload.first?.value {
            handleUpdateValue(value, key: key, context: context)
        }
        logDebug("received payload: \(payload)")
    }
    
    public func didChangeButtonTitle(_: ButtonTitle, coordinates: (Int, Int), state: Int, settings: [String : Any], action: String, context: String, device: String) {
        
    }
    
    private func handleUpdateValue(_ value: Any, key: String, context: String) {
        loadedSettings[context]?.update(key: key, value: value)
        logDebug("will update settings: \(loadedSettings)")
        connection.setSettings(loadedSettings, context: context)
        updateIcon(context: context)
    }
    
    private func updateIcon(context: String) {
        if let lat = loadedSettings[context]?.latitude, let long = loadedSettings[context]?.longitude, let latitude = Double(lat), let longitude = Double(long) {
            snapshotLoader = makeMapIcon(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)) { image in
                if let base64String = image.base64String {
                    self.connection.setImage(base64String, context: context, target: .both)
                }
            }
        }
    }

}

struct Settings: Encodable {
    var simulator: String?
    var latitude: String?
    var longitude: String?
    
    mutating func update(key: String, value: Any) {
        switch Fields(rawValue: key) {
        case .simulator:
            simulator = value as? String
        case .latitude:
            latitude = value as? String
        case .longitude:
            longitude = value as? String
        default:
            break
        }
    }
}

private enum Fields: String {
    case simulator
    case latitude
    case longitude
}
