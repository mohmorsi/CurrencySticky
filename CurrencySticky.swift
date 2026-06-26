import Cocoa
import Foundation

// The free API endpoint for exchange rates
let urlString = "https://open.er-api.com/v6/latest/USD"

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var label: NSTextField!
    var timer: Timer!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the window frame and position it
        let windowSize = NSSize(width: 180, height: 120)
        let screenSize = NSScreen.main?.frame.size ?? NSSize(width: 800, height: 600)
        let rect = NSRect(x: screenSize.width - windowSize.width - 50,
                          y: screenSize.height - windowSize.height - 50,
                          width: windowSize.width,
                          height: windowSize.height)

        // 2. Configure the window to look and act like a sticky note
        window = NSWindow(contentRect: rect,
                          styleMask: [.borderless], // Removes the standard macOS title bar
                          backing: .buffered,
                          defer: false)
        
        window.isOpaque = false
        window.backgroundColor = NSColor(calibratedRed: 0.99, green: 0.96, blue: 0.55, alpha: 1.0) // Classic sticky yellow
        window.level = .floating // Pins it on top of all other windows
        window.isMovableByWindowBackground = true // Allows you to click and drag it anywhere
        window.hasShadow = true
        
        // 3. Create the text label
        label = NSTextField(frame: NSRect(x: 10, y: 10, width: 160, height: 100))
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = NSColor.black
        label.stringValue = "Fetching\nRate..."
        
        window.contentView?.addSubview(label)
        window.makeKeyAndOrderFront(nil)
        
        // 4. Fetch the initial rate and set a timer to update hourly (3600 seconds)
        fetchRate()
        timer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(fetchRate), userInfo: nil, repeats: true)
    }
    
    @objc func fetchRate() {
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { self.label.stringValue = "Network\nError" }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let rates = json["rates"] as? [String: Any],
                   let cadRate = rates["CAD"] as? Double {
                    
                    // Update the label on the main thread
                    DispatchQueue.main.async {
                        self.label.stringValue = String(format: "$1 USD\n=\n$%.3f CAD", cadRate)
                    }
                }
            } catch {
                DispatchQueue.main.async { self.label.stringValue = "Data\nError" }
            }
        }
        task.resume()
    }
}

// 5. Run the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory) // Prevents an icon from cluttering your Dock
app.run()
