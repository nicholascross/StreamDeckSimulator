import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public class SetSimulatorLocationAction {
    private let connection: StreamDeckConnection
    private var loadedSettings: [String: Settings] = [:]
    
    init(connection: StreamDeckConnection) {
        self.connection = connection
    }

    public func didReceiveSettings(_ settings: [String : Any], action: String, context: String, device: String) {
        logDebug("didReceiveSettings: \(settings)")

        let rawSettings = (try? JSONSerialization.data(withJSONObject: settings, options: .prettyPrinted)) ?? Data()
        guard let settings = try? JSONDecoder().decode(Settings.self, from: rawSettings) else {
            logError("Unable to decode settings: \(String(data:rawSettings, encoding: .utf8) ?? "")")
            return
        }
        
        loadedSettings[context] = settings
        logDebug("loadedSettings: \(loadedSettings)")
        
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
            if let simulator = settings.simulator {
                selected = simulator
            } else {
                // set default simulator
                selected = (simulators.first { $0.state == .booted }.map { $0.udid.uuidString }) ??
                    (simulators.first { $0.state == .shutdown }.map { $0.udid.uuidString })
                
                updateSettingsForContext(context, simulator: selected)
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
        
        let coords = Coords(latitude: settings.latitude, longitude: settings.longitude)
        connection.sendToPropertyInspector(coords, action: action, context: context)
    }
    
    public func keyDown(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        let settings = settingsForContext(context)
        guard let lat = settings.latitude, let long = settings.longitude, let latitude = Double(lat), let longitude = Double(long) else {
            connection.showAlert(context: context)
            return
        }
        
        guard let udid = settings.simulator, let simulator = UUID(uuidString: udid) else {
            connection.showAlert(context: context)
            return
        }
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        SimulatorControl().updateLocations(coordinate: location, identifiers: [simulator])
        connection.showOkay(context: context)
    }
    
    public func keyUp(_: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        
    }

    public func propertyInspectorDidAppear(action: String, context: String, device: String) {
        logDebug("Property inspector did appear")
        
        connection.getSettings(context: context)
    }
    
    public func propertyInspectorDidDisappear(action: String, context: String, device: String) {
        logDebug("Property inspector did disappear")
    }
    
    public func willAppear(_: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        logDebug("will appear: \(action) \(context)")
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
    
    func coordinatesForContext(_ context: String) -> CLLocationCoordinate2D? {
        let settings = settingsForContext(context)

        guard let lat = settings.latitude, let long = settings.longitude,
              let latitude = Double(lat), let longitude = Double(long) else {
            return nil
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func simulatorForContext(_ context: String) -> Simulator? {
        let settings = settingsForContext(context)

        guard  let simulatorUDID = settings.simulator,
               let simulator = try? SimulatorControl().simulators().first(where: { $0.udid.uuidString == simulatorUDID }) else {
            return nil
        }
        
        return simulator
    }
    
    private func handleUpdateValue(_ value: Any, key: String, context: String) {
        var settings = settingsForContext(context)
        settings.update(key: key, value: value)
        logDebug("will update settings: \(settings)")
        
        updateSettingsForContext(context, simulator: settings.simulator, latitude: settings.latitude, longitude: settings.longitude, profile: settings.profile)
        updateIcon(context: context)
    }
    
    private func updateIcon(context: String) {
        if let coordinates = coordinatesForContext(context),
           let simulator = simulatorForContext(context) {
            makeMapIcon(coordinates: coordinates) { image in
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
    }
    
    func settingsForContext(_ context: String) -> Settings {
        return loadedSettings[context] ?? Settings()
    }
    
    func updateSettingsForContext(_ context: String, simulator: String? = nil, latitude: String? = nil, longitude: String? = nil, profile: String? = nil) {
        let current = settingsForContext(context)
        
        let settings = Settings(
            simulator: simulator ?? current.simulator,
            latitude: latitude ?? current.latitude,
            longitude: longitude ?? current.longitude,
            profile: profile ?? current.profile
        )
        
        loadedSettings[context] = settings
        connection.setSettings(settings, context: context)
    }

}

struct Settings: Codable {
    var simulator: String?
    var latitude: String?
    var longitude: String?
    var profile: String?
    
    mutating func update(key: String, value: Any) {
        switch Fields(rawValue: key) {
        case .simulator:
            simulator = value as? String
        case .latitude:
            latitude = value as? String
        case .longitude:
            longitude = value as? String
        case .profile:
            profile = value as? String
        default:
            break
        }
    }
}

private enum Fields: String {
    case simulator
    case latitude
    case longitude
    case profile
}
