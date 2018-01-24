//
//  Constants.swift
//  color-pickerPackageDescription
//
//  Created by modao on 2018/1/23.
//

import Cocoa

let GRID_PIXEL = 9
let GRID_NUMUBER_L = 8
let GRID_NUMUBER = GRID_NUMUBER_L*2 + 1
let CAPTURE_WIDTH = GRID_NUMUBER
let CAPTURE_HEIGHT = GRID_NUMUBER
let UI_WINDOW_WIDTH: CGFloat = 16 + CGFloat(GRID_PIXEL) + 2 + CGFloat(GRID_NUMUBER_L * GRID_PIXEL + GRID_NUMUBER_L)*2
let UI_WINDOW_HEIGHT: CGFloat = 16 + CGFloat(GRID_PIXEL) + 2 + CGFloat(GRID_NUMUBER_L * GRID_PIXEL + GRID_NUMUBER_L)*2
let error_domain = "com.mockingbot.colorpicker"
let maskPNGName = NSImage.Name("Mask")
