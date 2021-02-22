import Foundation
import StreamDeckKit
import CoreLocation
import SwiftUI

public final class BootAction: SetSimulatorLocationAction {
    private let connection: StreamDeckConnection

    override init(connection: StreamDeckConnection) {
        self.connection = connection
        super.init(connection: connection)
    }

    public override func keyUp(_ coordinates: (row: Int, column: Int), isInMultiAction: Bool, action: String, context: String, device: String) {
        super.keyUp(coordinates, isInMultiAction: isInMultiAction, action: action, context: context, device: device)
        guard let simulator = simulatorForContext(context) else {
            self.connection.showAlert(context: context)
            return
        }

        SimulatorControl().bootSimulator(simulator)
        self.connection.showOkay(context: context)
        updateIcon(context: context)
    }

    override func updateIcon(context: String) {
        guard let simulator = simulatorForContext(context) else { return }

        self.connection.setButtonIcon(context: context) {
            ZStack {
                if #available(OSX 11.0, *) {
                    Image(systemName: "power").foregroundColor(.white)
                } else {
                    Text("Boot")
                }
                if simulator.state == .booted {
                    bootedOverlay(color: .green)
                } else {
                    bootedOverlay(color: .red)
                }
            }
        }
    }
}
