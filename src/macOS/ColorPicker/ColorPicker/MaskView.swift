//
//  MaskView.swift
//  color-pickerPackageDescription
//
//  Created by modao on 2018/1/23.
//

import Cocoa

class MaskView: NSView {

    let display_id_list_size: UInt32 = 16
    var display_id_list: [CGDirectDisplayID]
    var color_space_list: [CGColorSpace]
    var display_bound_list: [CGRect]
    var image_surround_current_cursor: CGImage? {
        didSet {
            guard let cgImg = image_surround_current_cursor else {
                return
            }
            let ns_bitmap_image = NSBitmapImageRep(cgImage: cgImg)
            for y in 0..<Int(CAPTURE_HEIGHT) {
                for x in 0..<Int(CAPTURE_WIDTH) {
                    var color_values = autoreleasepool { () -> [CGFloat] in
                        let color = ns_bitmap_image.colorAt(x: x, y: y)
                        let red = color?.redComponent ?? 0
                        let green = color?.greenComponent ?? 0
                        let blue = color?.blueComponent ?? 0
                        return [red, green, blue, 1]
                    }
                    let fixedColor = autoreleasepool { () -> (red: CGFloat, green: CGFloat, blue: CGFloat) in
                        guard let cb = current_color_space,
                            let color = CGColor(colorSpace: cb, components: &color_values),
                            let nsColor = NSColor(cgColor: color),
                            let fixedColor = nsColor.usingColorSpace(.sRGB) else {
                                return (0,0,0)
                        }
                        return (fixedColor.redComponent, fixedColor.greenComponent, fixedColor.blueComponent)
                    }
                    CAPTUREED_PIXEL_COLOR_R[CAPTURE_HEIGHT-1-y][x] = fixedColor.red
                    CAPTUREED_PIXEL_COLOR_G[CAPTURE_HEIGHT-1-y][x] = fixedColor.green
                    CAPTUREED_PIXEL_COLOR_B[CAPTURE_HEIGHT-1-y][x] = fixedColor.blue
                }
            }
        }
    }
    var zoomed_image_surround_current_cursor: CGImage?
    var current_color_space: CGColorSpace?
    var mask_circle: CGImage?
    var display_count: UInt32 = 0
    var CAPTUREED_PIXEL_COLOR_R: [[CGFloat]]
    var CAPTUREED_PIXEL_COLOR_G: [[CGFloat]]
    var CAPTUREED_PIXEL_COLOR_B: [[CGFloat]]

    init?(failedCallBack:((Error?) -> Void)? = nil) {
        // 初始化数组
        let initializedValue:[CGFloat] = Array(repeating: 0, count: CAPTURE_HEIGHT)
        CAPTUREED_PIXEL_COLOR_R = Array(repeating: initializedValue, count: CAPTURE_WIDTH)
        CAPTUREED_PIXEL_COLOR_G = Array(repeating: initializedValue, count: CAPTURE_WIDTH)
        CAPTUREED_PIXEL_COLOR_B = Array(repeating: initializedValue, count: CAPTURE_WIDTH)

        display_id_list = Array(repeating: 0, count: Int(display_id_list_size))
        color_space_list = Array(repeating: CGColorSpace(name: CGColorSpace.sRGB)!, count: Int(display_id_list_size))
        display_bound_list = Array(repeating: CGRect.zero, count: Int(display_id_list_size))

        super.init(frame: .zero)
        do {
            try loadImage(image: Bundle.main.image(forResource: maskPNGName))
        } catch(let e) {
            print("Error: \(e.localizedDescription)")
            return nil
        }
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current?.cgContext
        let wnd_rect = CGRect(x: 0, y: 0, width: UI_WINDOW_WIDTH, height: UI_WINDOW_HEIGHT)
        // draw the zoomed image suround cursor
        if let cursor = zoomed_image_surround_current_cursor {
            ctx?.draw(cursor, in: wnd_rect)
        }
        // draw the mask
        if let mask = mask_circle {
            ctx?.draw(mask, in: wnd_rect)
        }
    }

    func refreshPictureSurroundCurrentCursor() {
        if image_surround_current_cursor != nil {
            image_surround_current_cursor = nil
        }
        if zoomed_image_surround_current_cursor != nil {
            zoomed_image_surround_current_cursor = nil
        }
        guard let window_list = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) else {
            return
        }
        let window_list_size = CFArrayGetCount(window_list)
        var window_list_filtered = CFArrayCreateMutableCopy(kCFAllocatorDefault, window_list_size, window_list)
        let main_window_id = window?.windowNumber
        for idx in (0...window_list_size-1).reversed() where CFArrayGetValueAtIndex(window_list, idx).assumingMemoryBound(to: Int.self).pointee == main_window_id {
            CFArrayRemoveValueAtIndex(window_list_filtered, idx)
        }
        guard let event = CGEvent(source: nil) else {
            return
        }
        // global display coordinates.
        let cursor_position = event.location
        let displayCount = Int(display_count)
        var display_id_idx = 0xFFFF
        for idx in 0..<displayCount where display_bound_list[idx].contains(cursor_position) {
            display_id_idx = idx
            break
        }
        if display_id_idx == 0xFFFF {
            resetDisplayId(display_id_idx: &display_id_idx,
                           displayCount: displayCount,
                           cursorPoint: cursor_position)
        }
        current_color_space = color_space_list[display_id_idx]
        let rect = CGRect(x: CGFloat(CAPTURE_WIDTH/2),
                          y: CGFloat(CAPTURE_HEIGHT/2),
                          width: CGFloat(CAPTURE_WIDTH),
                          height: CGFloat(CAPTURE_HEIGHT))
        guard let windowArray = window_list_filtered else {
            return
        }
        image_surround_current_cursor = CGImage(windowListFromArrayScreenBounds: rect,
                                                windowArray: windowArray,
                                                imageOption: .nominalResolution)
        drawPixels()
        defer {
            window_list_filtered = nil
        }
    }
}

extension MaskView {

    fileprivate func loadImage(image img: NSImage?) throws {
        guard let image = img else {
            let error = NSError(domain: error_domain,
                                code: -1002,
                                userInfo: [NSLocalizedDescriptionKey: "Mask.png does not exist"])
            throw error
        }
        guard let repre = image.representations.first else {
            let error = NSError(domain: error_domain,
                                code: -1003,
                                userInfo: [NSLocalizedDescriptionKey: "Image representations do not exist"])
            throw error
        }
        let pixel_wide = repre.pixelsWide
        let pixel_high = repre.pixelsHigh
        repre.size = NSSize(width: pixel_wide, height: pixel_high)
        image.size = NSSize(width: pixel_wide, height: pixel_high)
        image.addRepresentation(repre)
        image.removeRepresentation(image.representations.first!)
        var imageRect = NSRect(x: 0, y: 0, width: UI_WINDOW_WIDTH, height: UI_WINDOW_HEIGHT)
        let cgImg = image.cgImage(forProposedRect: &imageRect,
                                  context: NSGraphicsContext.current,
                                  hints: nil)
        var displayCount: UInt32 = 0
        if CGError.success != CGGetActiveDisplayList(display_id_list_size, &display_id_list, &displayCount) {
            let error = NSError(domain: error_domain,
                                code: -1001,
                                userInfo: [NSLocalizedDescriptionKey: "CGGetActiveDisplayList Failed"])
            throw error
        }
        mask_circle = cgImg
        display_count = displayCount
        for i in 0..<displayCount {
            let idx = Int(i)
            color_space_list[idx] = CGDisplayCopyColorSpace(display_id_list[idx])
            // in the global display coordinate space
            display_bound_list[idx] = CGDisplayBounds(display_id_list[idx])
        }
    }

    fileprivate func resetDisplayId(display_id_idx: inout Int,
                                    displayCount:Int,
                                    cursorPoint cursor: CGPoint) {
        var checkPoints = Array(repeating: CGPoint.zero, count: 4)
        checkPoints[0].x = cursor.x - 10
        checkPoints[0].y = cursor.y - 10
        checkPoints[1].x = cursor.x + 10
        checkPoints[1].y = cursor.y - 10
        checkPoints[2].x = cursor.x - 10
        checkPoints[2].y = cursor.y + 10
        checkPoints[3].x = cursor.x + 10
        checkPoints[3].y = cursor.y + 10
        var check_marks = Array(repeating: 0, count: displayCount)
        for idx in 0..<displayCount {
            var mark = 0
            let rect = display_bound_list[idx]
            if rect.contains(checkPoints[0]) {
                mark += 1
            }
            if rect.contains(checkPoints[1]) {
                mark += 1
            }
            if rect.contains(checkPoints[2]) {
                mark += 1
            }
            if rect.contains(checkPoints[3]) {
                mark += 1
            }
            check_marks[idx] = mark
        }
        var max_mark = -1
        for idx in 0..<displayCount where check_marks[idx] > max_mark {
            max_mark = check_marks[idx]
            display_id_idx = idx
        }
    }

    fileprivate func drawPixels() {
        // prepare context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.floatComponents.rawValue
        let ctx = CGContext(data: nil,
                            width: Int(UI_WINDOW_WIDTH),
                            height: Int(UI_WINDOW_HEIGHT),
                            bitsPerComponent: 32,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo)
        let mask_bound = CGRect(x: 8+2,
                                y: 8+2,
                                width: UI_WINDOW_WIDTH-(8+2)*2,
                                height: UI_WINDOW_HEIGHT-(8+2)*2)
        ctx?.saveGState()
        let clip_path = CGPath(ellipseIn: mask_bound, transform: nil)
        ctx?.addPath(clip_path)
        ctx?.clip()
        ctx?.setLineWidth(1.0)
        ctx?.setShouldAntialias(false)

        // draw background for grid
        let grid_color = CGColor(red: 0.72, green: 0.72, blue: 0.72, alpha: 0.98)
        let wnd_rect = CGRect(x: 0, y: 0, width: UI_WINDOW_WIDTH, height: UI_WINDOW_HEIGHT)
        ctx?.setFillColor(grid_color)
        ctx?.fill(wnd_rect)

        // draw each pixel
        for y in 0..<CAPTURE_HEIGHT {
            for x in 0..<CAPTURE_WIDTH {
                let r = CAPTUREED_PIXEL_COLOR_R[y][x]
                let g = CAPTUREED_PIXEL_COLOR_G[y][x]
                let b = CAPTUREED_PIXEL_COLOR_B[y][x]
                ctx?.setFillColor(red: r, green: g, blue: b, alpha: 1)
                let rect = CGRect(x: 8+1+(1+GRID_PIXEL)*x,
                                  y: 8+1+(1+GRID_PIXEL)*y,
                                  width: GRID_PIXEL,
                                  height: GRID_PIXEL)
                ctx?.fill(rect)
            }
        }
        // black and white and the center pixel color
        let x = GRID_NUMUBER_L
        let y = GRID_NUMUBER_L
        var rect = CGRect(x: CGFloat(8+1+(1+GRID_PIXEL)*x-1),
                          y: CGFloat(8+1+(1+GRID_PIXEL)*y-1),
                          width: CGFloat(GRID_PIXEL+2),
                          height: CGFloat(GRID_PIXEL+2))
        ctx?.setFillColor(red: 0, green: 0, blue: 0, alpha: 1)
        ctx?.fill(rect)

        rect.origin.x = CGFloat(8+1+(1+GRID_PIXEL)*x)
        rect.origin.y = CGFloat(8+1+(1+GRID_PIXEL)*y)
        rect.size.width = CGFloat(GRID_PIXEL)
        rect.size.height = CGFloat(GRID_PIXEL)
        ctx?.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx?.fill(rect)

        rect.origin.x = CGFloat(8+1+(1+GRID_PIXEL)*x+1)
        rect.origin.y = CGFloat(8+1+(1+GRID_PIXEL)*y+1)
        rect.size.width = CGFloat(GRID_PIXEL-2)
        rect.size.height = CGFloat(GRID_PIXEL-2)

        if let delegate = NSApp.delegate as? AppDelegate {
            delegate.TheR = CAPTUREED_PIXEL_COLOR_R[y][x]
            delegate.TheG = CAPTUREED_PIXEL_COLOR_G[y][x]
            delegate.TheB = CAPTUREED_PIXEL_COLOR_B[y][x]

            ctx?.setFillColor(red: delegate.TheR,
                              green: delegate.TheG,
                              blue: delegate.TheB,
                              alpha: 1.0)
            ctx?.fill(rect)
        }
        ctx?.restoreGState()
        zoomed_image_surround_current_cursor = ctx?.makeImage()
    }
}
