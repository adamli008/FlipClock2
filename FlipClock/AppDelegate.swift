//
//  AppDelegate.swift
//  FlipClock
//
//  Created by adam li on 2025/12/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    /**
     * 应用启动完成后的回调
     * 每次启动都将窗口设置为全屏模式
     */
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 延迟一小段时间，确保窗口已经创建
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 获取主窗口并设置为全屏
            if let window = NSApplication.shared.windows.first {
                // 如果窗口不在全屏状态，则切换为全屏
                if !window.styleMask.contains(.fullScreen) {
                    window.toggleFullScreen(nil)
                }
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

