//
//  MouseEventHook.swift
//  color-pickerPackageDescription
//
//  Created by modao on 2018/1/23.
//

import Cocoa

private func myCGEventCallback(proxy: CGEventTapProxy,
                               type: CGEventType,
                               event: CGEvent,
                               refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {

    guard let window = (NSApp.delegate as? AppDelegate)?.mainWindow else {
        return Unmanaged.passUnretained(event)
    }
    // relative to the lower-left corner of the main display.
    var mouse_pos = event.unflippedLocation
    mouse_pos.x -= UI_WINDOW_WIDTH/2.0
    mouse_pos.y -= UI_WINDOW_HEIGHT/2.0
    switch type {
    case .mouseMoved:
        NSApp.activate(ignoringOtherApps: true)
        window.setFrameOrigin(mouse_pos)
    case .leftMouseDown, .rightMouseDown:
        window.close()
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

class MouseEventHook {

    fileprivate var mouse_event_tap: CFMachPort?
    fileprivate var event_tap_src_ref: CFRunLoopSource?
    init() {
        var emask: CGEventMask = CGEventMask(1 << CGEventType.mouseMoved.rawValue)
        emask |= CGEventMask(1 << CGEventType.rightMouseDown.rawValue)
        emask |= CGEventMask(1 << CGEventType.leftMouseDown.rawValue)
        mouse_event_tap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap,
                                            place: .tailAppendEventTap,
                                            options: .listenOnly,
                                            eventsOfInterest: emask,
                                            callback: myCGEventCallback,
                                            userInfo: nil)
        event_tap_src_ref = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, mouse_event_tap, 0)
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            event_tap_src_ref,
            CFRunLoopMode.defaultMode
        )
    }

    deinit {
        CFRunLoopRemoveSource(
            CFRunLoopGetCurrent(),
            event_tap_src_ref,
            CFRunLoopMode.defaultMode
        )
    }
}
