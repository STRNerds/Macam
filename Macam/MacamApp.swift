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
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var windowSizeTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let button = self.statusItem.button {
            button.image = NSImage(named: NSImage.addTemplateName)
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        let controller = CameraFeedViewController.newInstance()
        controller.view.frame.size = CGSize(width: 320, height: 180)
        
        self.popover.contentViewController = controller
        self.popover.animates = false
        
        self.eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
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
        
        windowSizeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
//            print("Current window size: \(self.window.frame.size)")
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        windowSizeTimer?.invalidate()
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func togglePopover(_ sender: NSStatusItem) {
//        print("togglePopover")
        if self.popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = self.statusItem.button {
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            self.eventMonitor?.start()
        }
    }

    func closePopover(sender: Any?)  {
        self.popover.performClose(sender)
        self.eventMonitor?.stop()
    }
    
    @objc func showPreferences() {
        let settingsViewController = NSHostingController(rootView: SettingsView())
        settingsViewController.view.frame.size = CGSize(width: 480, height: 300)
        
        let settingsWindow = NSWindow(contentViewController: settingsViewController)
        settingsWindow.title = "Settings"
        settingsWindow.makeKeyAndOrderFront(nil)
    }
}

//@main
//struct MacamApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        Settings {
//            SettingsView()
//        }
//        .windowResizability(.contentMinSize)
//    }
//}
