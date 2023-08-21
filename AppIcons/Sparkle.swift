//
//  Sparkle.swift
//  AppIcons
//
//  Created by Munir Ahmed on 05/08/2023.
//  Copyright © 2023 Armonia. All rights reserved.
//

import Foundation
import AppKit

class Sparkle: NSObject {
    
    func showNextWindow() {
        DispatchQueue.main.async {
            let delegate = NSApp.delegate as! AppDelegate
            delegate.showNextWindowController()
        }
    }
    
    func upgrade(appcastURLString: String) {
        // Create a URL from the string
        if let appcastURL = URL(string: appcastURLString) {
            // Create a URLSession configuration
            let configuration = URLSessionConfiguration.default
             
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
                
            // Create a data task to fetch the XML
            let task = session.dataTask(with: appcastURL) { (data, response, error) in
             
                if let error = error {
                    print("Error: \(error)")
                    self.showNextWindow()
                    return
                }
                
                if let data = data {
                    // Parse the XML
                    let parser = XMLParser(data: data)
                    let appcastDelegate = AppcastXMLDelegate()
                    parser.delegate = appcastDelegate
                    parser.parse()
                    
                    // Get the download link from the delegate
                    if let downloadLink = appcastDelegate.downloadLink {
                        print("Download Link: \(downloadLink)")
                        let launcher = UpdateLauncher.shared
                        launcher.downloadExtractAndReplaceBundle(from: downloadLink)
                    } else {
                        self.showNextWindow()
                        print("Download link not found in Appcast XML.")
                    }
                    
                }
            }
            // Start the data task
            task.resume()
        } else {
            showNextWindow()
            print("Invalid URL.")
        }
    }
}

extension Sparkle: URLSessionDelegate {
   
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                    // Bypass certificate validation by trusting the server's certificate.
                    if let serverTrust = challenge.protectionSpace.serverTrust {
                        let credential = URLCredential(trust: serverTrust)
                        completionHandler(.useCredential, credential)
                    }
                } else {
                    // Handle other authentication methods.
                    completionHandler(.performDefaultHandling, nil)
                }
    }
}

// Define a custom XML parser delegate
class AppcastXMLDelegate: NSObject, XMLParserDelegate {
    var isDownloadLink = false
    var downloadLink: String?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "enclosure", let link = attributeDict["url"] {
            downloadLink = link
        }
    }
}

