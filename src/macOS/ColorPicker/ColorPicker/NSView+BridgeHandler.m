//
//  NSView+BridgeHandler.m
//  ColorPicker
//
//  Created by modao on 2018/1/24.
//  Copyright © 2018年 MockingBot. All rights reserved.
//

#import "NSView+BridgeHandler.h"

@implementation NSView (BridgeHandler)

-(CFMutableArrayRef)windowList {
    CFArrayRef window_list = CGWindowListCreate(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    CFIndex window_list_size = CFArrayGetCount(window_list);
    CFMutableArrayRef window_list_filtered = CFArrayCreateMutableCopy(kCFAllocatorDefault, window_list_size, window_list);
    NSInteger main_window_id = self.window.windowNumber;
    for (NSInteger idx = window_list_size - 1; idx >= 0; --idx) {
        if( main_window_id == (CGWindowID)(uintptr_t)CFArrayGetValueAtIndex(window_list, idx)) {
            CFArrayRemoveValueAtIndex(window_list_filtered, idx);
        }
    }
    CFRelease(window_list);
    return window_list_filtered;
}

@end
