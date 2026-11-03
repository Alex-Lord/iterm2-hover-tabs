import AppKit

private final class HoverTestWindow: NSWindow {
    var pointer = NSPoint(x: 10, y: 10)
    var key = true
    override var isKeyWindow: Bool { key }
    override var mouseLocationOutsideOfEventStream: NSPoint { pointer }
}

@main
struct HoverTrackingTests {
    static func waitFor(_ description: String, condition: () -> Bool) throws {
        let deadline = Date().addingTimeInterval(3)
        while !condition() && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        if !condition() {
            throw NSError(domain: "HoverTrackingTests", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: description])
        }
    }

    static func main() throws {
        _ = NSApplication.shared
        let window = HoverTestWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
                                     styleMask: [], backing: .buffered, defer: false)
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
        window.contentView = view
        let controller = iTermHoverTabBarController(changeHandler: {})
        controller.configure(view: view, rect: NSRect(x: 0, y: 0, width: 20, height: 300), enabled: true)
        try waitFor("The rail must expand while the pointer stays inside") { controller.expanded }
        // Expansion replaces the tracking area while the pointer is already inside.
        controller.configure(view: view, rect: NSRect(x: 0, y: 0, width: 180, height: 300), enabled: true)
        // No mouseExited event: exercise recovery from a missed tracking event.
        window.pointer = NSPoint(x: 300, y: 10)
        try waitFor("The expanded rail must recover from a missed mouseExited event") { !controller.expanded }
        window.pointer = NSPoint(x: 10, y: 10)
        controller.configure(view: view, rect: NSRect(x: 0, y: 0, width: 20, height: 300), enabled: true)
        try waitFor("The rail must reopen") { controller.expanded }
        window.key = false
        try waitFor("The rail must recover from a missed focus notification") { !controller.expanded }
        controller.configure(view: view, rect: .zero, enabled: false)
        print("PASS: AppKit controller recovers from missed exit and focus events")
    }
}
