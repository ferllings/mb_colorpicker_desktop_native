//
//  main.swift
//  ColorPicker
//
//  Created by modao on 2018/1/24.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

import Cocoa

let app = NSApplication.shared
NSApp.setActivationPolicy(.accessory)
let controller = AppDelegate()
app.delegate = controller

app.run()
