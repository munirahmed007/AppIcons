//
//  UpgradeLauncher.swift
//  AppIcons
//
//  Created by Munir Ahmed on 05/08/2023.
//  Copyright © 2023 Armonia. All rights reserved.
//

import Foundation
import AppKit
import ZipArchive

extension FileManager {
    func createTempDirectory() -> URL? {
        let fileManager = FileManager.default
        let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        
        do {
            let tempDirectory = tempDirectoryURL.appendingPathComponent(UUID().uuidString)
            try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true, attributes: nil)
            return tempDirectory
        } catch {
            print("Error creating temporary directory: \(error)")
            return nil
        }
    }
}

class Zip {
    class func unzipFile(_ source: URL, destination: URL, overwrite: Bool, password: String?) {
        // Unzip
        SSZipArchive.unzipFile(atPath: source.path, toDestination: destination.path)
    }
}

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
                let extractionDirectory = FileManager.default.createTempDirectory()!.appendingPathComponent("ExtractedBundle")
                
                do {
                    try FileManager.default.createDirectory(at: extractionDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    try FileManager.default.moveItem(at: temporaryURL, to: extractionDirectory.appendingPathComponent("upgrade.zip"))
                    // Extract the downloaded zip file
                    Zip.unzipFile(extractionDirectory.appendingPathComponent("upgrade.zip"), destination: extractionDirectory, overwrite: true, password: nil)
                    
                    try FileManager.default.removeItem(at: extractionDirectory.appendingPathComponent("upgrade.zip"))
                    let mainBundleURL = Bundle.main.bundleURL.appendingPathComponent("Contents")
                        // Replace the existing bundle with the extracted bundle
                        do {
                            try FileManager.default.removeItem(at: mainBundleURL)
                            try FileManager.default.moveItem(at: extractionDirectory.appendingPathComponent(Bundle.main.bundleURL.lastPathComponent).appendingPathComponent("Contents"), to: mainBundleURL)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                NSWorkspace.shared.open(Bundle.main.bundleURL)
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
