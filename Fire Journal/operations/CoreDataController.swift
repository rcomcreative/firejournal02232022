//
//  CoreDataController.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/15/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

public class CoreDataController: NSObject {
    
    public private (set) var isStoreLoaded = false
    
    public var isReadOnly = false
    
    public var shouldAddStoreAsynchronously = true
    
    public var shouldMigrateStoreAutomatically = true
    
    public var shouldInferMappingModelAutomatically = true
    
    private let persistentContainer: NSPersistentContainer;
    
    
    public class func defaultDirectoryURL()->URL {
        return NSPersistentContainer.defaultDirectoryURL()
    }
    
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public var storeURL: URL? {
        var url: URL?
        let descriptions = persistentContainer.persistentStoreDescriptions
        if let firstDescription = descriptions.first {
            url = firstDescription.url
        }
        return url
    }
    
    public init?(name: String) {
        let bundle = Bundle(for: CoreDataController.self)
        guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            return nil
        }
        
        persistentContainer = NSPersistentContainer(name: name, managedObjectModel: mom)
        super.init()
    }
    
    public func loadStore(completionHandler: @escaping (Error?) -> Void) {
        loadStore(storeURL: storeURL, completionHandler: completionHandler)
    }
    
    public func loadStore(storeURL: URL?, completionHandler: @escaping (Error?) -> Void) {
        
        if let storeURL = storeURL ?? self.storeURL {
            let description = storeDescription(with: storeURL)
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if error == nil {
                self.isStoreLoaded = true
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            }
            
            DispatchQueue.main.async {
                completionHandler(error)
            }
        }
    }
    
    public func persistentStoreExists(at storeURL: URL) -> Bool {
        if storeURL.isFileURL &&
            FileManager.default.fileExists(atPath: storeURL.path) {
            return true
        }
        return false
    }
    
    public func destroyPersistentStore(at storeURL: URL) throws {
        let psc = persistentContainer.persistentStoreCoordinator
        try psc.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
    }
    
    public func replacePersistentStore(at url: URL, withPersistentStoreFrom sourceURL: URL) throws {
        let psc = persistentContainer.persistentStoreCoordinator
        try psc.replacePersistentStore(at: url, destinationOptions: nil,
                                       withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
    }
    
    public func newPrivateContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    public func performBackgroundTask(block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    public func managedObjectID(forURIRepresentation storeURL: URL) -> NSManagedObjectID? {
        let psc = persistentContainer.persistentStoreCoordinator
        return psc.managedObjectID(forURIRepresentation: storeURL)
    }
    
    
    private func storeDescription(with url: URL) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = shouldMigrateStoreAutomatically
        description.shouldInferMappingModelAutomatically = shouldInferMappingModelAutomatically
        description.shouldAddStoreAsynchronously = shouldAddStoreAsynchronously
        description.isReadOnly = isReadOnly
        return description
    }
    
    
}
