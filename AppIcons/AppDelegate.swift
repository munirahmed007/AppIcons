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

    var spuupdater: SPUStandardUpdaterController!
    var path: String?
   
    func intialization() {
        path = ProcessInfo.processInfo.environment["APPCAST_ENDPOINT"]
        if path == nil {
            var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess) )
            TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication))
        } else {
            spuupdater = SPUStandardUpdaterController(updaterDelegate: self, userDriverDelegate: nil)
            DispatchQueue.main.async(execute: {
                self.spuupdater.startUpdater()
                self.spuupdater.checkForUpdates(self)
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

extension AppDelegate: SPUUpdaterDelegate {
    func updater(_ updater: SPUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) -> Bool {
        immediateInstallHandler()
        return true
    }
    
    func feedURLString(for updater: SPUUpdater) -> String? {
        return self.path ?? ""
    }
}
