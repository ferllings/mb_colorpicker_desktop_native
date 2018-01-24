//
//  MaskWindow.swift
//  color-pickerPackageDescription
//
//  Created by modao on 2018/1/23.
//

import Cocoa

class MaskWindow: NSWindow {

    fileprivate var timer:Timer!
    let hook = MouseEventHook()

    init() {
        let event = CGEvent(source: nil)
        var mouse_pos = event?.unflippedLocation
        mouse_pos?.x = UI_WINDOW_WIDTH / 2.0
        mouse_pos?.y = UI_WINDOW_HEIGHT / 2.0
        let wnd_rect = CGRect(origin: mouse_pos ?? .zero,
                              size: CGSize(width: UI_WINDOW_WIDTH,
                                           height: UI_WINDOW_HEIGHT))
        super.init(contentRect: wnd_rect,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)
        backgroundColor = .clear
        level = .statusBar
        alphaValue = 1.0
        isOpaque = false
        contentView = MaskView { error in
            if let err = error {
                print("Failed to creat mask view: \(err.localizedDescription)")
            }
        }
        timer = Timer(timeInterval: 1.0/25.0,
                      target: self,
                      selector: #selector(MaskWindow.onTimerClick(_:)),
                      userInfo: nil,
                      repeats: true)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        NSCursor.hide()
    }

    override var canBecomeKey: Bool {
        return true
    }

    @objc func onTimerClick(_ sender: Timer) {
        if let view = self.contentView as? MaskView {
            view.refreshPictureSurroundCurrentCursor()
            view.display()
        }
    }

    override func close() {
        timer.invalidate()
        NSCursor.unhide()
        if let delegate = NSApp.delegate as? AppDelegate {
            let r = Int(roundf(Float(delegate.TheR)*255.0))
            let g = Int(roundf(Float(delegate.TheG)*255.0))
            let b = Int(roundf(Float(delegate.TheB)*255.0))
            print("\(r.format())\(g.format())\(b.format())\n")
            fflush(__stdoutp)
        }
        super.close()
    }
}

extension Int {
    func format(_ f: String = ".2") -> String {
        return String(format: "%\(f)d", self)
    }
}
