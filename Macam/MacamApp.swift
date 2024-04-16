//
//  MacamApp.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import SwiftUI
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
//    var statusBar: NSStatusBar?
//    var statusBarItem: NSStatusItem?
//    var popover: NSPopover?
//    var contentView: ContentView?
//
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        statusBar = NSStatusBar.init()
//        statusBarItem = statusBar?.statusItem(withLength: NSStatusItem.squareLength)
//        statusBarItem?.button?.image = NSImage(named: NSImage.addTemplateName)
//        statusBarItem?.button?.action = #selector(AppDelegate.togglePopover(_:))
//
//        popover = NSPopover()
//        contentView = ContentView()
//        popover?.contentViewController = ViewController()
//        popover?.behavior = .transient
//    }
//
//    @objc func togglePopover(_ sender: AnyObject?) {
//        if popover?.isShown ?? false {
//            popover?.performClose(sender)
//        } else {
//            if let button = statusBarItem?.button {
//                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
//            }
//        }
//    }
}

@main
struct MacamApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Settings {
            SettingsView()
        }
        .windowResizability(.contentMinSize)
        MenuBarExtra("Macam", systemImage: "web.camera.fill") {
            CameraFeedView()
        }.menuBarExtraStyle(.window)
    }
}
