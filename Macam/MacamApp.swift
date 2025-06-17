//
//  MacamApp.swift
//  Macam
//
//  Created by Ethan Xu on 2024-04-07.
//

import SwiftUI
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var windowController: NSWindowController?
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var settingsWindowController: NSWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = self.statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: nil)
        }
        
        let menu = NSMenu()
        
        let showAppItem = NSMenuItem(title: "Open Macam", action: #selector(AppDelegate.showAppWindow(_:)), keyEquivalent: "\r")
        showAppItem.keyEquivalentModifierMask = []
        menu.addItem(showAppItem)
        
        menu.addItem(NSMenuItem.separator())
        
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
        
        createAndSetupWindow()
        
        let mainMenu = NSApp.mainMenu
        let menuItem = mainMenu?.item(withTitle: "Macam")?.submenu?.item(withTitle: "Settings...")
        menuItem?.action = #selector(showPreferences)
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApp.setActivationPolicy(.regular)
        if self.windowController?.window == nil || self.windowController?.window?.isVisible == false {
            createAndSetupWindow()
        } else {
            self.windowController?.window?.makeKeyAndOrderFront(nil)
        }
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    func createAndSetupWindow() {
        NSApp.setActivationPolicy(.regular)
        let contentView = ContentView()
                    .frame(minWidth: 480, maxWidth: .infinity, minHeight: 270, maxHeight: .infinity)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 960, height: 540), styleMask: [.titled, .closable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.delegate = self
        window.makeKeyAndOrderFront(nil)
        window.title = "Macam"
        window.aspectRatio = NSSize(width: 16, height: 9)
        
        windowController = NSWindowController(window: window)
        
        windowController?.showWindow(nil)
    }
    
    @objc func showPreferences() {
        NSApp.setActivationPolicy(.regular)
        if settingsWindowController == nil || settingsWindowController?.window == nil {
            let settingsViewController = NSHostingController(rootView: SettingsView())
            settingsViewController.view.frame.size = CGSize(width: 480, height: 300)
            
            let newSettingsWindow = NSWindow(contentViewController: settingsViewController)
            newSettingsWindow.title = "Settings"
            newSettingsWindow.styleMask.formUnion([.closable])
            newSettingsWindow.styleMask.subtract([.resizable, .miniaturizable])
            newSettingsWindow.center()
            
            settingsWindowController = NSWindowController(window: newSettingsWindow)
        }
        
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc func quitApp(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func menuBarCapturePhoto(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .menuBarCapturePhoto, object: nil)
    }
    
    @objc func showAppWindow(_ sender: NSMenuItem) {
        NSApp.setActivationPolicy(.regular)
        if self.windowController?.window == nil || self.windowController?.window?.isVisible == false {
            createAndSetupWindow()
        } else {
            self.windowController?.window?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func windowWillClose(_ notification: Notification) {
        if let closedWindow = notification.object as? NSWindow, closedWindow == self.windowController?.window {
            NSApp.setActivationPolicy(.accessory)	
        }	
    }
}
