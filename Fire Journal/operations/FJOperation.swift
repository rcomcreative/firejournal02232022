//
//  FJOperation.swift
//  dashboard
//
//  Created by DuRand Jones on 10/3/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class FJOperation: Operation {
    
    var backgroundTask : UIBackgroundTaskIdentifier = .invalid
    var operation: String = ""
    var thereIsBackgroundTask: Bool = false
    
    private var _concurrent = false {
        willSet {
            willChangeValue(forKey: "isConcurrent")
        }
        didSet {
            didChangeValue(forKey: "isConcurrent")
        }
    }
    override var isConcurrent: Bool {
        return _concurrent
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        registerBackgroundTask()
        print("executing")
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        print("is finished")
        endBackgroundTask()
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
    
    func concurrent(_ concurrent: Bool) {
        _concurrent = concurrent
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
