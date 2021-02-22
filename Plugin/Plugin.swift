import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public final class Plugin: StreamDeckConnectionDelegate {
    private let connection: StreamDeckConnection
    private let setLocationAction: SetSimulatorLocationAction
    private let traverseAction: TraverseAction
    private let traverseToAction: TraverseToAction
    private let bootAction: BootAction
    
    init(connection: StreamDeckConnection) {
        self.connection = connection
        self.setLocationAction = SetSimulatorLocationAction(connection: connection)
        
        let traverseAction = TraverseAction(connection: connection)
        self.traverseAction = traverseAction
        self.traverseToAction = TraverseToAction(connection: connection, traverseAction: traverseAction)
        self.bootAction = BootAction(connection: connection)
    }

    public func didReceiveSettings(_ settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.didReceiveSettings(settings, action: action, context: context, device: device)
        case .traverse:
            traverseAction.didReceiveSettings(settings, action: action, context: context, device: device)
        case .boot:
            bootAction.didReceiveSettings(settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func keyDown(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.keyDown(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        case .traverse:
            traverseAction.keyDown(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        case .travelTo:
            traverseToAction.keyDown(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func keyUp(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        case .traverse:
            traverseAction.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        case .boot:
            bootAction.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func propertyInspectorDidAppear(action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.propertyInspectorDidAppear(action: action, context: context, device: device)
        case .traverse:
            traverseAction.propertyInspectorDidAppear(action: action, context: context, device: device)
        case .boot:
            bootAction.propertyInspectorDidAppear(action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func propertyInspectorDidDisappear(action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.propertyInspectorDidDisappear(action: action, context: context, device: device)
        case .traverse:
            traverseAction.propertyInspectorDidDisappear(action: action, context: context, device: device)
        case .boot:
            bootAction.propertyInspectorDidDisappear(action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func willAppear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.willAppear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .traverse:
            traverseAction.willAppear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .travelTo:
            traverseToAction.willAppear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .boot:
            bootAction.willAppear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func willDisappear(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.willDisappear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .traverse:
            traverseAction.willDisappear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .travelTo:
            traverseToAction.willDisappear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        case .boot:
            bootAction.willDisappear(coordinates, isInMultiAction: isInMultiAction, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func receivedPayloadFromPropertyInspector(_ payload: [String : Any], action: String, context: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.receivedPayloadFromPropertyInspector(payload, action: action, context: context)
        case .traverse:
            traverseAction.receivedPayloadFromPropertyInspector(payload, action: action, context: context)
        case .boot:
            bootAction.receivedPayloadFromPropertyInspector(payload, action: action, context: context)
        default:
            break
        }
    }
    
    public func didChangeButtonTitle(_ title: ButtonTitle, coordinates: (Int, Int), state: Int, settings: [String : Any], action: String, context: String, device: String) {
        switch ActionType(rawValue: action) {
        case .setSimulatorLocation:
            setLocationAction.didChangeButtonTitle(title, coordinates: coordinates, state: state, settings: settings, action: action, context: context, device: device)
        case .traverse:
            traverseAction.didChangeButtonTitle(title, coordinates: coordinates, state: state, settings: settings, action: action, context: context, device: device)
        case .boot:
            bootAction.didChangeButtonTitle(title, coordinates: coordinates, state: state, settings: settings, action: action, context: context, device: device)
        default:
            break
        }
    }
    
    public func didLaunchApplication(_ application: String) {
        
    }
    
    public func didTerminateApplication(_ application: String) {
        
    }
    
    public func didConnectDevice(_ deviceId: String, info: DeviceInfo) {
        traverseAction.deviceId = deviceId
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
    case traverse = "com.nacross.stream-deck-sim-loc.traverse"
    case travelTo = "com.nacross.stream-deck-sim-loc.traverse-to"
    case boot = "com.nacross.stream-deck-sim-loc.boot"
}

public enum PluginConstants {
    static var zoomLevel: Double = 300.0
}
