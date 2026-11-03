import Foundation

// Run with run.sh. These exercise the same state implementation linked into
// iTerm2, with a simulated clock rather than timing-sensitive sleeps.
@main
struct HoverTabStateTests {
    static func check(_ condition: Bool, _ message: String) throws {
        if !condition {
            throw NSError(domain: "HoverTabStateTests", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: message])
        }
    }

    static func update(_ state: inout iTermHoverTabBarState, _ time: Double,
                       inside: Bool, interacting: Bool = false, enabled: Bool = true) {
        state.update(enabled: enabled, inside: inside, interacting: interacting, now: time)
    }

    static func main() throws {
        var state = iTermHoverTabBarState()
        update(&state, 0, inside: true)
        update(&state, 0.03, inside: true)
        try check(!state.expanded, "Passing over the rail must not immediately expand it")
        update(&state, 0.06, inside: true)
        try check(state.expanded, "Sustained hover must expand")
        update(&state, 1, inside: false)
        update(&state, 1.05, inside: false)
        try check(state.expanded, "Brief exits must preserve the expanded bar")
        update(&state, 1.06, inside: true)
        update(&state, 2, inside: true)
        try check(state.expanded && state.deadline == nil, "Reentry must cancel collapse")
        update(&state, 3, inside: false)
        update(&state, 3.11, inside: false)
        try check(!state.expanded, "Leaving must collapse")

        update(&state, 4, inside: true)
        update(&state, 4.03, inside: false)
        update(&state, 5, inside: false)
        try check(!state.expanded && state.deadline == nil, "A cancelled hover must never open later")

        update(&state, 6, inside: true)
        update(&state, 6.06, inside: true)
        update(&state, 7, inside: false, interacting: true)
        update(&state, 8, inside: false, interacting: true)
        try check(state.expanded && state.deadline == nil, "Drag/menu interaction must hold the bar open")
        update(&state, 9, inside: false)
        update(&state, 9.11, inside: false)
        try check(!state.expanded, "Ending an interaction must allow collapse")
        update(&state, 10, inside: false, interacting: true)
        update(&state, 11, inside: false, interacting: true)
        try check(!state.expanded, "Dragging in the terminal must not open the rail")

        state.reveal(now: 12, duration: 1)
        update(&state, 12.9, inside: false)
        try check(state.expanded, "Keyboard tab switching must briefly reveal titles")
        state.reveal(now: 12.95, duration: 1)
        update(&state, 13.5, inside: false)
        try check(state.expanded, "Repeated tab switches must extend the reveal")
        update(&state, 14, inside: false)
        update(&state, 14.11, inside: false)
        try check(!state.expanded, "Temporary reveal must eventually collapse")

        state.reveal(now: 15, duration: 1)
        update(&state, 15.1, inside: true, enabled: false)
        try check(!state.expanded && state.deadline == nil && state.revealUntil == nil,
                  "Disabling or losing focus must reset all pending state")
        update(&state, 16, inside: false)
        try check(!state.expanded, "Re-enabling must not restore stale expansion")
        print("PASS: 14 hover, cancellation, interaction, focus and keyboard-reveal checks")
    }
}
