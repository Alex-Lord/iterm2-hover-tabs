import AppKit

// Time is supplied by the caller so transitions can be tested without sleeping.
struct iTermHoverTabBarState {
    private(set) var expanded = false
    private(set) var deadline: TimeInterval?
    private(set) var revealUntil: TimeInterval?
    private var target = false

    mutating func reveal(now: TimeInterval, duration: TimeInterval) {
        expanded = true
        target = true
        deadline = nil
        revealUntil = now + max(0, duration)
    }

    mutating func update(enabled: Bool,
                         inside: Bool,
                         interacting: Bool,
                         now: TimeInterval) {
        guard enabled else {
            expanded = false
            target = false
            deadline = nil
            revealUntil = nil
            return
        }
        // Never close under a drag or an open menu. A drag that starts outside
        // the rail does not, by itself, open it.
        if let revealUntil, now >= revealUntil { self.revealUntil = nil }
        let desired = inside || revealUntil != nil || (expanded && interacting)
        if desired == expanded {
            target = desired
            deadline = nil
            return
        }
        if desired != target || deadline == nil {
            target = desired
            deadline = now + (desired ? 0.05 : 0.10)
        }
        if let deadline, now >= deadline {
            expanded = target
            self.deadline = nil
        }
    }
}

// Owns only the hover state and its tracking area. The root terminal view owns
// layout; keeping that callback weak at the call site avoids a retain cycle.
@objc(iTermHoverTabBarController)
public final class iTermHoverTabBarController: NSObject {
    private weak var view: NSView?
    private weak var observedWindow: NSWindow?
    private var area: NSTrackingArea?
    private var rect = NSRect.zero
    private var enabled = false
    private var menuDepth = 0
    private var timer: Timer?
    private var state = iTermHoverTabBarState()
    private let changeHandler: () -> Void

    @objc public var expanded: Bool { state.expanded }

    @objc(revealForDuration:)
    public func reveal(forDuration duration: TimeInterval) {
        guard enabled, view?.window?.isKeyWindow == true else { return }
        state.reveal(now: ProcessInfo.processInfo.systemUptime, duration: duration)
        changeHandler()
        evaluate()
    }

    @objc(initWithChangeHandler:)
    public init(changeHandler: @escaping () -> Void) {
        self.changeHandler = changeHandler
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuBegan),
                                               name: NSMenu.didBeginTrackingNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuEnded),
                                               name: NSMenu.didEndTrackingNotification,
                                               object: nil)
    }

    deinit {
        timer?.invalidate()
        if let area { view?.removeTrackingArea(area) }
        NotificationCenter.default.removeObserver(self)
    }

    @objc(configureWithView:rect:enabled:)
    public func configure(view: NSView, rect: NSRect, enabled: Bool) {
        if observedWindow !== view.window {
            if let window = observedWindow {
                NotificationCenter.default.removeObserver(self,
                                                          name: NSWindow.didResignKeyNotification,
                                                          object: window)
            }
            observedWindow = view.window
            if let window = observedWindow {
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(windowResignedKey),
                                                       name: NSWindow.didResignKeyNotification,
                                                       object: window)
            }
        }
        let usable = enabled && !rect.isEmpty && view.window != nil
        if self.view !== view || self.rect != rect || self.enabled != usable {
            if let area { self.view?.removeTrackingArea(area) }
            area = nil
            self.view = view
            self.rect = rect
            self.enabled = usable
            if usable {
                var options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeInKeyWindow]
                if let window = view.window,
                   rect.contains(view.convert(window.mouseLocationOutsideOfEventStream, from: nil)) {
                    options.insert(.assumeInside)
                }
                let area = NSTrackingArea(rect: rect,
                                          options: options,
                                          owner: self,
                                          userInfo: nil)
                view.addTrackingArea(area)
                self.area = area
            }
        }
        // configure is called from layout. Do not reenter layout synchronously.
        evaluate(notify: false)
    }

    @objc private func mouseEntered(_ event: NSEvent) {
        guard event.trackingArea === area else { return }
        evaluate()
    }

    @objc private func mouseExited(_ event: NSEvent) {
        guard event.trackingArea === area else { return }
        evaluate()
    }

    @objc private func menuBegan(_ notification: Notification) {
        menuDepth += 1
    }

    @objc private func menuEnded(_ notification: Notification) {
        menuDepth = max(0, menuDepth - 1)
        evaluate()
    }

    @objc private func windowResignedKey(_ notification: Notification) {
        menuDepth = 0
        let wasExpanded = expanded
        state.update(enabled: false, inside: false, interacting: false,
                     now: ProcessInfo.processInfo.systemUptime)
        timer?.invalidate()
        timer = nil
        if wasExpanded { changeHandler() }
    }

    private func evaluate(notify: Bool = true) {
        let wasExpanded = expanded
        let active = enabled && view?.window?.isKeyWindow == true
        let point = view.flatMap { view in
            view.window.map { view.convert($0.mouseLocationOutsideOfEventStream, from: nil) }
        }
        let inside = point.map { rect.contains($0) } ?? false
        let interacting = NSEvent.pressedMouseButtons != 0 || menuDepth > 0
        state.update(enabled: active, inside: inside, interacting: interacting,
                     now: ProcessInfo.processInfo.systemUptime)
        timer?.invalidate()
        timer = nil
        // While expanded, recover even if replacing the tracking area loses an
        // exit or focus notification. A collapsed, idle rail has no timer.
        if state.deadline != nil || state.revealUntil != nil || (active && expanded) {
            let timer = Timer(timeInterval: 0.05, repeats: false) { [weak self] _ in
                self?.evaluate()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }
        if expanded != wasExpanded {
            if notify {
                changeHandler()
            } else if view?.window != nil {
                DispatchQueue.main.async { [weak self] in self?.changeHandler() }
            }
        }
    }
}
