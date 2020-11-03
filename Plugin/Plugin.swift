import Foundation
import StreamDeckKit

public final class Plugin: StreamDeckConnectionDelegate {
    private let connection: StreamDeckConnection
    private var loadedSettings: Settings = Settings()
    
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
    
    public func didReceiveSettings(_ settings: [String : Any], action: String, context: String, device: String) {
        logDebug("didReceiveSettings: \(settings)")
        settings.forEach { loadedSettings.update(key: $0.key, value: $0.value) }
        
        struct Device: Encodable {
            let name: String
            let udid: String
            let selected: Bool
        }
        
        struct Simulators: Encodable {
            var booted: [Device]
            var shutdown: [Device]
        }

        let selected = settings[Fields.simulator.rawValue] as? String
        
        do {
            let booted = try SimulatorControl().simulators().filter { $0.state == .booted }.map { Device(name: $0.name, udid: $0.udid.uuidString, selected: selected == $0.udid.uuidString) }
            let shutdown = try SimulatorControl().simulators().filter { $0.state == .shutdown }.map { Device(name: $0.name, udid: $0.udid.uuidString, selected: selected == $0.udid.uuidString) }

            connection.sendToPropertyInspector(Simulators(booted: booted, shutdown: shutdown), action: action, context: context)
        } catch {
            logError("Failed to detect simulators")
        }
        
        struct Coords: Encodable {
            let latitude: String?
            let longitude: String?
        }
        
        let coords = Coords(latitude: loadedSettings.latitude, longitude: loadedSettings.longitude)
        connection.sendToPropertyInspector(coords, action: action, context: context)
    }
    
    public func didReceiveGlobalSettings(_ settings: [String : Any]) {
        logDebug("didReceiveGlobalSettings: \(settings)")
    }
    
    public func keyDown(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        logDebug("Key down")
        connection.setTitle("Down", context: context, target: .both, state: 0)
    }
    
    public func keyUp(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        logDebug("Key up")
        connection.setTitle("Up", context: context, target: .both, state: 0)
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
        loadedSettings.update(key: key, value: value)
        logDebug("will update settings: \(loadedSettings)")
        connection.setSettings(loadedSettings, context: context)
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
