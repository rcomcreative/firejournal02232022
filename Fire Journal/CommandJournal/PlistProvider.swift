//
//  PlistProvider.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/9/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import CoreData

class PlistProvider: NSObject {
    
    private(set) var persistentContainer: NSPersistentContainer
    
    init(with persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    deinit {
        print("Plist is being deinitialized")
    }
    
}
