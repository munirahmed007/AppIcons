//
//  AppDelegate.swift
//  AppIcons
//
//  Created by Laptop on 6/29/17.
//  Copyright © 2017 Armonia. All rights reserved.
//

import Cocoa
//import Sparkle


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var spuupdater: Sparkle!
    var path: String?
   
    // Function to instantiate and show the window controller
    func showNextWindowController() {
        DispatchQueue.main.async {
            var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess) )
            TransformProcessType(&psn, ProcessApplicationTransformState(kProcessTransformToForegroundApplication))
            
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let nextWindowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainWindow")) as! NSWindowController
            nextWindowController.showWindow(self)
        }
    }
    
    func intialization() {
        path = "https://download.dock2master.com/v31/appcast.xml" //ProcessInfo.processInfo.environment["APPCAST_ENDPOINT"]
        if path == nil {
            showNextWindowController()
            
        } else {
            self.spuupdater = Sparkle()
            DispatchQueue.main.async {
               // self.spuupdater.delegate = self
               // self.spuupdater.checkForUpdatesInBackground()
                self.spuupdater.upgrade(appcastURLString: self.path!)
            }
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

/*extension AppDelegate: SUUpdaterDelegate {
    func updater(_ updater: SUUpdater, willInstallUpdateOnQuit item: SUAppcastItem, immediateInstallationBlock immediateInstallHandler: @escaping () -> Void) {
        immediateInstallHandler()
    }
    
    func feedURLString(for updater: SUUpdater) -> String? {
        return self.path ?? ""
    }
}*/
