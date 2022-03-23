//
//  BkgrndTask.swift
//  Fire Journal
//
//  Created by DuRand Jones on 10/2/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

final class BkgrndTask: NSObject {
    
    var backgroundTask : UIBackgroundTaskIdentifier = .invalid
    var operation : String = ""
    var thereIsBackgroundTask: Bool = false
    
    init(bkgrndTask: UIBackgroundTaskIdentifier ) {
        self.backgroundTask = bkgrndTask
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
            self?.thereIsBackgroundTask.toggle()
        }
        thereIsBackgroundTask.toggle()
        //      assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
        //        print("Background task ended. BackgroundTask \(backgroundTask.self) operation: \(operation)")
        if thereIsBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
}
