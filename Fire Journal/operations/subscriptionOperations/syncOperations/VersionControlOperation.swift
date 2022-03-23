//
//  VersionControlOperation.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/4/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

class VersionControlOperation: FJOperation {
    
    var thread:Thread!
    let nc = NotificationCenter.default
    var currentVersionBundle: String!
    var appStoreVersionBunde: String!
    var todaysDate: Date
    var versionInSync: Bool = false
    var bundleIdentifer: String = "http://itunes.apple.com/lookup?bundleId=com.purecommand.FireJournal"
    
    init(theDate: Date) {
        self.todaysDate = theDate
        super.init()
    }
    
    override func main() {
        guard isCancelled == false else {
            self.executing(false)
            self.operation = "UserFDResourcesPointOfTruthOperation"
            self.finish(true)
            return
        }
        
        thread = Thread(target:self, selector:#selector(checkTheThread), object:nil)
        executing(true)
        
        letsCheckTheVersionNumber {
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue:FJkVERSIONCONTROL), object: nil, userInfo: ["versionControl": self.versionInSync])
            }
        }
        
        
        guard isCancelled == false else {
                   self.executing(false)
                   self.operation = "UserFDResourcesPointOfTruthOperation"
                   self.finish(true)
                   return
               }
    }
    
    
    @objc func checkTheThread() {
        let testThread:Bool = thread.isMainThread
        print("VersionControlOperation here is testThread \(testThread) and \(Thread.current)")
    }
    
    private func letsCheckTheVersionNumber(withCompletion completion:()-> Void) {
        let bundle = Bundle.main
        var versionFromiTunes: String = ""
        if let infoDictionary = bundle.infoDictionary {
            let urlOnAppStore = NSURL(string: bundleIdentifer)
            if let data = NSData(contentsOf: urlOnAppStore! as URL) {
                do {
                 let version = try JSONSerialization.jsonObject(
                    with: data as Data, options: .mutableContainers) as! [String: AnyObject]
//                    print("VersionControlOperation version: \(version)")
                    if let resultCount = version["resultCount"] as? Int64 {
                        if resultCount == 1 {
                            let results:NSArray = (version["results"] as? NSArray)!
                            let versions: [String: AnyObject] = results[0]  as! [String: AnyObject]
                            for (key,value) in versions {
                                let v = value
                                let k = key
                                if k == "version" {
                                    versionFromiTunes = v as? String ?? ""
                                }
                            }
                            if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                                if versionFromiTunes != currentVersion {
                                    versionInSync = true
                                }
                            }
                            completion()
                        }
                    }
                } catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    print("JSON error description: \(jsonError.description)")
                }
            }
        }
    }
    
}

