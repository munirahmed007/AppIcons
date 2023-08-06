//
//  AppDelegate.swift
//  AppIcons
//
//  Created by Laptop on 6/29/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
import Sparkle


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var spuupdater: SUUpdater!
    var path: String?
   
    func intialization() {
        path = ProcessInfo.processInfo.environment["APPCAST_ENDPOINT"]
        if path == nil {
            var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess) )
            TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication))
        } else {
            self.spuupdater = SUUpdater(for: Bundle.main)!
            DispatchQueue.main.async(execute: {
                self.spuupdater.delegate = self
                self.spuupdater.checkForUpdatesInBackground()
            })
        }
    }
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        intialization()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: SUUpdaterDelegate {
    func updater(_ updater: SUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) {
        immediateInstallHandler()
    }
    
    func feedURLString(for updater: SUUpdater) -> String? {
        return self.path ?? ""
    }
}
