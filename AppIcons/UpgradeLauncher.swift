//
//  UpgradeLauncher.swift
//  AppIcons
//
//  Created by Munir Ahmed on 05/08/2023.
//  Copyright © 2023 Armonia. All rights reserved.
//

import Foundation
import AppKit
import Zip

class UpdateLauncher {
    static let shared = UpdateLauncher()
    
    private init() {}
    
    func showNextWindow() {
        DispatchQueue.main.async {
            let delegate = NSApp.delegate as! AppDelegate
            delegate.showNextWindowController()
        }
    }
    
    func downloadExtractAndReplaceBundle(from downloadURLString: String) {
        if let downloadURL = URL(string: downloadURLString) {
            let configuration = URLSessionConfiguration.default
            let session = URLSession(configuration: configuration)
            
            let task = session.downloadTask(with: downloadURL) { (temporaryURL, response, error) in
                if let error = error {
                    self.showNextWindow()
                    print("Error downloading file: \(error)")
                    return
                }
                
                guard let temporaryURL = temporaryURL else {
                    print("Temporary URL not found.")
                    self.showNextWindow()
                    return
                }
                
                // Create a directory to extract the zip contents
                let extractionDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("ExtractedBundle")
                
                do {
                    try FileManager.default.createDirectory(at: extractionDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    try FileManager.default.moveItem(at: temporaryURL, to: extractionDirectory.appendingPathComponent("upgrade.zip"))
                    // Extract the downloaded zip file
                    try Zip.unzipFile(extractionDirectory.appendingPathComponent("upgrade.zip"), destination: extractionDirectory, overwrite: true, password: nil)
                    
                    try FileManager.default.removeItem(at: extractionDirectory.appendingPathComponent("upgrade.zip"))
                    let mainBundleURL = Bundle.main.bundleURL
                        // Replace the existing bundle with the extracted bundle
                        do {
                            try FileManager.default.removeItem(at: mainBundleURL)
                            try FileManager.default.moveItem(at: extractionDirectory.appendingPathComponent(mainBundleURL.lastPathComponent), to: mainBundleURL)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                NSWorkspace.shared.open(mainBundleURL)
                                NSApp.terminate(self)
                            }
                            print("Bundle replaced successfully.")
                        } catch {
                            print("Error replacing bundle: \(error)")
                            self.showNextWindow()
                        }
                    
                } catch {
                    print("Error extracting or replacing bundle: \(error)")
                    self.showNextWindow()
                }
            }
            
            task.resume()
        } else {
            print("Invalid URL.")
            self.showNextWindow()
        }
    }
}
