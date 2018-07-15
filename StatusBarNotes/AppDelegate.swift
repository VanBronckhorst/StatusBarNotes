//
//  AppDelegate.swift
//  StatusBarNotes
//
//  Created by Filippo Pellolio on 7/14/18.
//  Copyright © 2018 pll. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
  let popover = NSPopover()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let button = statusItem.button {
      button.image = NSImage(named:NSImage.Name("clipboard"))
      button.action = #selector(togglePopover(_:))
    }

    popover.contentViewController = ClipboardViewController.freshController()
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


  @objc func togglePopover(_ sender: Any?) {
    if (popover.isShown) {
      closePopover()
    } else {
      openPopover()
    }
  }

  func closePopover() {
    popover.close()
  }

  func openPopover() {
    if let icon = statusItem.button {
      popover.show(relativeTo: icon.bounds, of: icon, preferredEdge: NSRectEdge.minY)
    }
  }

}

