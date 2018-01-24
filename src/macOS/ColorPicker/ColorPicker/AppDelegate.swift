//
//  AppDelegate.swift
//  ColorPicker
//
//  Created by modao on 2018/1/24.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindow: NSWindow!
    // 输出值
    var TheR: CGFloat = 0
    var TheG: CGFloat = 0
    var TheB: CGFloat = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mainWindow = MaskWindow()
        mainWindow.makeKeyAndOrderFront(nil)
        mainWindow?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

/// Swift版printf
@discardableResult
func swiftprintf(format: String, _ arguments: CVarArg...) -> String? {
    return withVaList(arguments) { va_list in
        var buffer: UnsafeMutablePointer<Int8>? = nil
        return format.withCString { CString in
            guard vasprintf(&buffer, CString, va_list) != 0 else {
                return nil
            }
            return String(validatingUTF8: buffer!)
        }
    }
}
