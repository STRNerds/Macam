//
//  MacamApp.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import SwiftUI
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = self.statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: nil)
        }
        
        let menu = NSMenu()
        
        let takePictureItem = NSMenuItem(title: "Take Picture", action: #selector(AppDelegate.menuBarCapturePhoto(_:)), keyEquivalent: " ")
        takePictureItem.keyEquivalentModifierMask = []
        menu.addItem(takePictureItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let controller = ViewController(inMenuBar: true)
        controller.view.frame.size = CGSize(width: 320, height: 180)
        
        let cameraFeedViewItem = NSMenuItem()
        cameraFeedViewItem.view = controller.view
        
        menu.addItem(cameraFeedViewItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Macam", action: #selector(AppDelegate.quitApp(_:)), keyEquivalent: "q"))
            
        self.statusItem.menu = menu
        
        let contentView = ContentView()
                    .frame(minWidth: 480, maxWidth: .infinity, minHeight: 270, maxHeight: .infinity)
        
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 960, height: 540), styleMask: [.titled, .closable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.title = "Macam"
        window.aspectRatio = NSSize(width: 16, height: 9)
        print(window.minSize)
        
        let mainMenu = NSApp.mainMenu
        let menuItem = mainMenu?.item(withTitle: "Macam")?.submenu?.item(withTitle: "Settings...")
        menuItem?.action = #selector(showPreferences)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func showPreferences() {
        let settingsViewController = NSHostingController(rootView: SettingsView())
        settingsViewController.view.frame.size = CGSize(width: 480, height: 300)
        
        let settingsWindow = NSWindow(contentViewController: settingsViewController)
        settingsWindow.title = "Settings"
        settingsWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func menuBarCapturePhoto(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .menuBarCapturePhoto, object: nil)
    }
}
