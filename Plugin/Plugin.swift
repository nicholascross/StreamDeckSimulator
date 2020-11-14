import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public final class Plugin: StreamDeckConnectionDelegate {
    private let connection: StreamDeckConnection
    private var loadedSettings: [String: Settings] = [:]
    private let setLocationAction: SetSimulatorLocationAction
    
    init(connection: StreamDeckConnection) {
        self.connection = connection
        self.setLocationAction = SetSimulatorLocationAction(connection: connection)
    }

    public func didReceiveSettings(_ settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.didReceiveSettings(settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func keyDown(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.keyDown(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func keyUp(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func propertyInspectorDidAppear(action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.propertyInspectorDidAppear(action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func propertyInspectorDidDisappear(action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.propertyInspectorDidDisappear(action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func willAppear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.willAppear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func willDisappear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.willDisappear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func receivedPayloadFromPropertyInspector(_ payload: [String : Any], action: String, context: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.receivedPayloadFromPropertyInspector(payload, action: action, context: context)
        default:
            break
        }
    }
    
    public func didChangeButtonTitle(_ title: ButtonTitle, coordinates: (Int, Int), state: Int, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.didChangeButtonTitle(title, coordinates: coordinates, state: state, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func didLaunchApplication(_ application: String) {
        
    }
    
    public func didTerminateApplication(_ application: String) {
        
    }
    
    public func didConnectDevice(_: String, info: DeviceInfo) {
        
    }
    
    public func didDisconnectDevice(_: String, info: DeviceInfo) {
        
    }
    
    public func didReceiveGlobalSettings(_ settings: [String : Any]) {

    }
    
    public func didWakeUp() {
        
    }
}

private enum ActionType: String, Decodable {
    case setSimulatorLocation = "com.nacross.stream-deck-sim-loc.action"
}
