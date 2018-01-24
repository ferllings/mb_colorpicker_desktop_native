//
//  AppDelegate.swift
//  ColorPicker
//
//  Created by modao on 2018/1/24.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {

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
