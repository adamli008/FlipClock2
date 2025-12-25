import Cocoa
import SwiftUI

class ViewController: NSViewController {
    
    // Hold the model here so we can control it from the Menu
    let timeModel = TimeModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Inject the model into the view
        let clockView = FlipClockView(timeModel: timeModel)
        let hostingController = NSHostingController(rootView: clockView)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
