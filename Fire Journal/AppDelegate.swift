//
//  AppDelegate.swift
//  dashboard
//
//  Created by DuRand Jones on 7/12/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications
import CloudKit
import UserNotifications
import os.log

//let subscriptionsService = SubscriptionsService.shared


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate,CLLocationManagerDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    let reachability = Reachability()!
    let subscriptionsService = SubscriptionsService.shared
    var fetched: [FireJournalUser]!
    var managedObjectContext: NSManagedObjectContext!
    var fju: FireJournalUser!
    let userDefaults = UserDefaults.standard
    var subscriptionBought: Bool = false
    var subscriptionIsLocallyCached: Bool = false
    var agreementAgreedTo: Bool = false
    var firstRun: Bool = false
    
    let myContainer = CKContainer.init(identifier: FJkCLOUDKITDATABASENAME)
    var privateDatabase:CKDatabase!
    var sharedDBChangeToken:CKServerChangeToken!
    var zoneIDs = [CKRecordZone.ID]()
    let cloud = CloudKitManager.shared
    let nc = NotificationCenter.default
    
    var bkgrdContext:NSManagedObjectContext!
    var device: Int = 0
    var orientation: Int = 0
    
    //    MARK: -BACKGROUNDTASK-
    var bgTask : UIBackgroundTaskIdentifier = .invalid
    var bkgrndTask: BkgrndTask?
    var thereIsBackgroundTask: Bool = false
    
    let pendingOperations = PendingOperations()
    let weatherPendingOperations = WeatherPendingOperations()
    private var currentLocation: CLLocation?
    
    /// A `OSLog` with my subsystem, so I can focus on my log statements and not those triggered
    /// by iOS internal subsystems. This isn't necessary (you can omit the `log` parameter to `os_log`,
    /// but it just becomes harder to filter Console for only those log statements this app issued).
    
    fileprivate let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "log")
    
    //    MARK -LOCATION FOR WEATHER-
    func determineLocation() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        manager.stopUpdatingLocation()
        let userLocation:CLLocation!
        
        if currentLocation != nil {
            userLocation = currentLocation
        } else {
            userLocation = locations[0] as CLLocation
            currentLocation = userLocation
        }
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        if userLocation != nil {
            userDefaults.set(latitude, forKey:FJkLATITUDE)
            userDefaults.set(longitude, forKey: FJkLONGITUDE)
            userDefaults.set(true, forKey: FJkLOCATION)
            userDefaults.synchronize()
        }
        
    }
    
    //    MARK: - WEATHER OPERATIONS -
    @objc func getOpenWeather(notification: Notification) {
        let latitude = userDefaults.double(forKey: FJkLATITUDE)
        let longitude = userDefaults.double(forKey: FJkLONGITUDE)
        weatherPendingOperations.weatherTypeQueue.isSuspended = true
        let weatherOperation = WeatherOperation.init(Date(), latitude: latitude, longitude: longitude)
        weatherPendingOperations.weatherTypeQueue.addOperation(weatherOperation)
        weatherPendingOperations.weatherTypeQueue.qualityOfService = .background
        weatherPendingOperations.weatherTypeQueue.isSuspended = false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bkgrndTask = BkgrndTask.init(bkgrndTask: bgTask)
        bkgrndTask?.operation = "AppDelegate"
        bkgrndTask?.registerBackgroundTask()
        thereIsBackgroundTask = true
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        addObservers()
        
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        navigationController.topViewController?.navigationItem.leftItemsSupplementBackButton = true
        splitViewController.delegate = self
        
        //        let minimumWidth = CGFloat(splitViewController.view.bounds.width)
        let minminWidth = CGFloat(splitViewController.view.bounds.width/4)
        splitViewController.minimumPrimaryColumnWidth = minminWidth
        splitViewController.maximumPrimaryColumnWidth = minminWidth
        splitViewController.preferredPrimaryColumnWidthFraction = 0.2
        
        splitViewController.preferredDisplayMode = .allVisible
        
        let masterNavigationController = splitViewController.viewControllers[0] as! UINavigationController
        let controller = masterNavigationController.topViewController as! MasterViewController
        masterNavigationController.title = ""
        controller.title = ""
        
        controller.managedObjectContext = persistentContainer.viewContext
        managedObjectContext = persistentContainer.viewContext
        
        subscriptionBought = userDefaults.bool(forKey: FJkSUBCRIPTIONBought)
        subscriptionIsLocallyCached = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        agreementAgreedTo = userDefaults.bool(forKey: FJkUserAgreementAgreed)
        
        UIApplication.shared.registerForRemoteNotifications()
        application.registerForRemoteNotifications()
        application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        
        // turn on user notifications if you want them
        
        UNUserNotificationCenter.current().delegate = self
        
        cloud.getTheData(moc: managedObjectContext)
        
        privateDatabase = myContainer.privateCloudDatabase
        
        
        if agreementAgreedTo {
            self.cloud.firstRun = false
            getTheUser(entity: "FireJournalUser", attribute: "userGuid", sortAttribute: "lastName")
            let reach = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
            if reach {
                fetchAnyChangesWeMissed(firstRun: firstRun)
                determineLocation()
            }
            userDefaults.set(false, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
            userDefaults.synchronize()
        } else {
            beginPlistProcess()
            self.cloud.firstRun = true
        }
        
        userDefaults.set(false, forKey: FJkVERSIONCONTROL)
        userDefaults.synchronize()
        
        return true
    }
    
    func addObservers() {
        nc.addObserver(self, selector: #selector(reachabilityChanged(note:)),name: NSNotification.Name.reachabilityChanged,object: nil)
        nc.addObserver(self,selector: #selector(detectOrientation(ns:)), name:UIDevice.orientationDidChangeNotification, object:nil)
        nc.addObserver(self, selector: #selector(contextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        nc.addObserver(self, selector:#selector(getOpenWeather(notification:)),name:NSNotification.Name(rawValue: FJkOPENWEATHER_UPDATENow), object: nil)
        nc.addObserver(self, selector:#selector(zoneRecordsCalled(notification:)),name:NSNotification.Name(rawValue: FJkFJSHOULDRunSYNC), object: nil)
        //        MARK: -OBSERVE NEW FIRE STATION-
        nc.addObserver(self, selector: #selector(getTheNotificationChanges(nc:)), name: NSNotification.Name(rawValue: FJkRECIEVEDRemoteNotification), object: nil)
    }
    
    @objc func detectOrientation(ns: Notification) {
        switch UIDevice.current.orientation {
        case .unknown:
//            print("Orientation Unknown")
            orientation = 0
        case UIDeviceOrientation.portrait:
//            print("Orientation Portrait")
            device = UIDeviceOrientation.portrait.rawValue
            orientation = 1
        case UIDeviceOrientation.portraitUpsideDown:
//            print("Orientation PortraitUpsideDown")
            device = UIDeviceOrientation.portraitUpsideDown.rawValue
            orientation = 2
        case UIDeviceOrientation.landscapeLeft:
//            print("Orientation LandscapeLeft")
            device = UIDeviceOrientation.landscapeLeft.rawValue
            orientation = 3
        case UIDeviceOrientation.landscapeRight:
//            print("Orientation LandscapeRight")
            device = UIDeviceOrientation.landscapeRight.rawValue
            orientation = 4
        case UIDeviceOrientation.faceUp:
//            print("Orientation FaceUp")
            if orientation == 0 {
                orientation = 1
            }
        case UIDeviceOrientation.faceDown:
//            print("Orientation FaceDown")
            if orientation == 0 {
                orientation = 1
            }
        @unknown default:
            break
        }
        if Device.IS_IPAD {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkORIENTATIONDIDCHANGE), object: nil, userInfo: ["orientation":self.orientation])
            }
        }
    }
    
    func beginPlistProcess() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NFIRSIncidentType" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "incidentTypeNumber CONTAINS %@","100")
        fetchRequest.predicate = predicate
        do {
            let fetched = try self.persistentContainer.viewContext.fetch(fetchRequest) as! [NFIRSIncidentType]
            bkgrdContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            bkgrdContext.persistentStoreCoordinator = managedObjectContext.persistentStoreCoordinator
            if fetched.count == 0 {
                let plistsLoad = LoadPlists.init(bkgrdContext)
                plistsLoad.runTheOperations()
            }
        }  catch let error as NSError {
            let errorMessage = "MasterTVC fetchRequest for plists error \(error.localizedDescription) \(String(describing: error._userInfo))"
            print(errorMessage)
        }
    }
    
    @objc private func zoneRecordsCalled(notification: Notification) {
        if agreementAgreedTo {
            getTheUserForStore(entity: "FireJournalUser", attribute: "userGuid", sortAttribute: "lastName")
            fetchAnyChangesWeMissed(firstRun: firstRun)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Update the app interface directly.
        
        // Play a sound.
        //        completionHandler(UNNotificationPresentationOptions.sound)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if agreementAgreedTo {
            if CKNotification(fromRemoteNotificationDictionary: userInfo) != nil {
                
                DispatchQueue.main.async {
                    self.nc.post(name: NSNotification.Name(rawValue: FJkRECIEVEDRemoteNotification), object: nil )
                }
                completionHandler(UIBackgroundFetchResult.newData)
                return
            }
        }
//        if agreementAgreedTo {
            //        let cloudkitNote = CKNotification.init(fromRemoteNotificationDictionary: userInfo)
            //        let body = cloudkitNote.alertBody
//            let dict = userInfo as! [String: NSObject]
//            let notification = CKNotification(fromRemoteNotificationDictionary: dict)!
//
//            switch application.applicationState {
//
//            case .inactive:
//                print("Inactive \(String(describing: notification.subscriptionID))")
//            case .background:
//                print("Background \(String(describing: notification.subscriptionID))")
            //            if notification.subscriptionID == "FireJournal" {
            //                fetchSharedChanges {
            //                    completionHandler(UIBackgroundFetchResult.newData)
            //                }
            //            }
//            case .active:
//                if notification.subscriptionID == "FireJournal" {
//                    fetchSharedChanges {
//                        completionHandler(UIBackgroundFetchResult.newData)
//                    }
//                }
//            default: break
//            }
            //
            //        completionHandler(UIBackgroundFetchResult.newData)
//        }
    }
    
    
    //    MARK: -NOTIFICATION TO GET SHARED CHANGES-
    @objc func getTheNotificationChanges(nc: Notification) {
        fetchSharedChanges({
            
        })
    }
    
    func fetchSharedChanges(_ callback: @escaping ()->Void ) {
        self.bkgrndTask?.registerBackgroundTask()
        thereIsBackgroundTask = true
        sharedDBChangeToken = userDefaults.object(forKey: FJkCKServerChangeToken) as? CKServerChangeToken
        
        let changesOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: sharedDBChangeToken)
        
        changesOperation.fetchAllChanges = true
        
        changesOperation.recordZoneWithIDChangedBlock = {(zoneID) in
            self.zoneIDs.append(zoneID)
        }
        changesOperation.recordZoneWithIDWasDeletedBlock = {(zoneID) in
            print("nothing here in recordZoneWithIDWasDeletedBlock")
        }
        
        changesOperation.fetchDatabaseChangesCompletionBlock = { newToken, more, error in
            guard error == nil else {
                if let ckerror = error as? CKError {
                    print("here is your error for this block fetchDatabaseChangesCompletionBlock \(ckerror.localizedDescription)")
                }
                return
            }
            self.sharedDBChangeToken = newToken
            print("here is the new token \(String(describing: self.sharedDBChangeToken))")
            self.addTokenToDefaults()
            print(self.zoneIDs)
            self.cloud.getCloudKitChanges(zoneIDs: self.zoneIDs)
            self.userDefaults.set(true, forKey: FJkCHANGESINFROMCLOUD)
            self.userDefaults.synchronize()
            if self.thereIsBackgroundTask {
                self.bkgrndTask?.endBackgroundTask()
                self.thereIsBackgroundTask = false
            }
        }
        
        privateDatabase.add(changesOperation)
    }
    
    func addTokenToDefaults()->Void {
        
        if sharedDBChangeToken != nil {
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: sharedDBChangeToken!, requiringSecureCoding: false)
            userDefaults.set(encodedData, forKey: FJkCKServerChangeToken)
            userDefaults.synchronize()
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("registered device token \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register \(error.localizedDescription)")
    }
    
    @objc func contextDidSave(_ notification: Notification) {
        
        //                print("here we are trying to get the notification for the core data save")
        if let userInfo = notification.userInfo as! [String: Any]? {
            if let info = userInfo["info"] as? String {
                print("here is info \(info)")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if thereIsBackgroundTask {
            bkgrndTask?.endBackgroundTask()
            print("resigned to background")
            thereIsBackgroundTask = false
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        reachability.stopNotifier()
        if thereIsBackgroundTask {
            bkgrndTask?.endBackgroundTask()
            thereIsBackgroundTask = false
            cloud.appMovedToBackground()
        }
        print("background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        reachabilityStartup()
        bkgrndTask?.registerBackgroundTask()
        thereIsBackgroundTask = true
        cloud.appMovedToForegraound()
        print("foreground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        cloud.appMovedToForegraound()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        reachability.stopNotifier()
        cloud.appMovedToBackground()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard (secondaryAsNavController.topViewController as? DetailViewController) != nil else { return false }
        if Device.IS_IPHONE {
            if orientation == 3 || orientation == 4 {
                return false
            }
            return true
        }
        return false
    }
    
    func fetchAnyChangesWeMissed(firstRun: Bool)->Void {
        self.cloud.firstRun = firstRun
        print("Starting to check for changes")
        bkgrndTask?.registerBackgroundTask()
        thereIsBackgroundTask = true
        sharedDBChangeToken = userDefaults.object(forKey: FJkCKServerChangeToken) as? CKServerChangeToken
        var changesOperation: CKFetchDatabaseChangesOperation!
        changesOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: sharedDBChangeToken)
        
        
        
        changesOperation.fetchAllChanges = true
        
        changesOperation.recordZoneWithIDChangedBlock = {(zoneID) in
            self.zoneIDs.append(zoneID)
        }
        changesOperation.recordZoneWithIDWasDeletedBlock = {(zoneID) in
            print("nothing here in recordZoneWithIDWasDeletedBlock")
        }
        
        changesOperation.fetchDatabaseChangesCompletionBlock = { newToken, more, error in
            guard error == nil else {
                if let ckerror = error as? CKError {
                    print("here is your error for this block fetchDatabaseChangesCompletionBlock \(ckerror.localizedDescription)")
                }
                return
            }
            self.sharedDBChangeToken = newToken
            print("here is the new token \(String(describing: self.sharedDBChangeToken))")
            self.addTokenToDefaults()
            print(self.zoneIDs)
            
            self.agreementAgreedTo = self.userDefaults.bool(forKey: FJkUserAgreementAgreed)
            if self.agreementAgreedTo {
                self.cloud.getCloudKitChanges(zoneIDs: self.zoneIDs)
            }
            self.userDefaults.set(true, forKey: FJkCHANGESINFROMCLOUD)
            self.userDefaults.synchronize()
            if self.thereIsBackgroundTask {
                self.bkgrndTask?.endBackgroundTask()
                self.thereIsBackgroundTask = false
            }
        }
        
        privateDatabase.add(changesOperation)
    }
    
    //    MARK: -Core Data PersistentContainer
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CommandJournal")
        
        let storeDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = storeDirectory.appendingPathComponent("CommandJournal.sqlite")
        
        let description = NSPersistentStoreDescription(url: url)
        description.shouldAddStoreAsynchronously = true
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.setOption(FileProtectionType.complete as NSObject, forKey: NSPersistentStoreFileProtectionKey)
        container.persistentStoreDescriptions = [description]
        let coordinator = container.persistentStoreCoordinator
        
        ////
        //        let storeOptions = [NSPersistentStoreFileProtectionKey: FileProtectionType.complete]
        //
        //        container.persistentStoreDescriptions
        
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            container.viewContext.mergePolicy = NSOverwriteMergePolicy //NSMergeByPropertyObjectTrumpMergePolicy
            
            
            //            print(storeDescription)
            
            if let error = error as NSError? {
                
                
                let nserror = error as NSError
                
                let errorMessage = "AppDelegate persistentContainer Unresolved error \(nserror) \(error.localizedDescription) \(error.userInfo)"
                print(errorMessage)
                
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = self.persistentContainer.viewContext
        if (context.hasChanges) {
            do {
                try context.save()
            } catch let error as NSError {
                let nserror = error
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                let error = "\(nserror):\(nserror.localizedDescription)\(nserror.userInfo)"
                print("AppDelegate: \(error)")
                
            }
        }
    }
    
    //    MARK: -Reachability
    
    /**
     REACHABILITY SEQUENCE
     */
    func reachabilityStartup() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi WHEN REACHABLE")
            } else {
                print("Reachable via Cellular")
            }
        }
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil, userInfo:["errorMessage":""])
            }
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi CONNECTION")
            userDefaults.set(true, forKey: FJkInternetConnectionAvailable)
            userDefaults.synchronize()
        case .cellular:
            print("Reachable via Cellular")
            userDefaults.set(true, forKey: FJkInternetConnectionAvailable)
            userDefaults.synchronize()
        case .none:
            userDefaults.set(false, forKey: FJkInternetConnectionAvailable)
            userDefaults.synchronize()
            DispatchQueue.main.async {
                self.nc.post(name: NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil, userInfo:["errorMessage":""])
            }
        }
    }
    
    /**
     observer: FJkNORecordCKRGetUserFromCLOUD
     If no CKRecord is found when app opens and runCount is equal to 0
     this gets run
     Checks network, checks for FireJournalUser
     
     @param n nil
     */
    private func getTheUser(entity: String, attribute: String, sortAttribute: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        self.fetched = try! self.managedObjectContext.fetch(fetchRequest) as! [FireJournalUser]
        
        if self.fetched.isEmpty {
            print("no user available")
            subscriptionsService.fetchAvailableProducts()
            return
        } else {
            fju = self.fetched.last
            if fju.fjuLocation != nil {
                userDefaults.set(false, forKey: FJkMoveTheLocationsToLocationsSC)
                userDefaults.synchronize()
            }
            if let guid = fju.userGuid {
                self.subscriptionsService.fjUserGuid = guid
            }
            if let email = fju.emailAddress {
                self.subscriptionsService.fjUserEmail = email
            }
            if let uName = fju.userName {
                print("here is the userName \(uName)")
            } else {
                var fName = ""
                var lName = ""
                if let first:String = self.fju.firstName {
                    fName = first
                }
                if let last:String = self.fju.lastName {
                    lName = last
                }
                fju.userName = "\(fName) \(lName)"
                fju.fjpUserModDate = Date()
                fju.fjpUserBackedUp = false
                saveContext()
            }
            subscriptionsService.fetchAvailableProducts()
            if agreementAgreedTo {
                if !subscriptionBought {
                    subscriptionsService.getAppReceipt()
                    let subscribed = subscriptionsService.subscribed
                    self.userDefaults.set(subscribed, forKey: FJkSUBCRIPTIONBought)
                    self.userDefaults.synchronize()
                }
            }
            
        }
        
        if (subscriptionIsLocallyCached) { return }
        let recordZone = CKRecordZone.init(zoneName: "FireJournalShare")
        
        let modifyRecordZone = CKModifyRecordZonesOperation.init(recordZonesToSave: [recordZone], recordZoneIDsToDelete: nil)
        modifyRecordZone.modifyRecordZonesCompletionBlock = { (savedRecordZones: [CKRecordZone]?, deletedRecordZoneIDs: [CKRecordZone.ID]?, error: Error?) in
            if let error = error {
                print("Error creating record zone \(error.localizedDescription)")
            }
            print("here are the savedRecordZones \(String(describing: savedRecordZones))")
            let subscription = CKDatabaseSubscription(subscriptionID: "FireJournal")
            
            let notificationInfo = CKSubscription.NotificationInfo()
            
            notificationInfo.shouldSendContentAvailable = true
            
            subscription.notificationInfo = notificationInfo
            
            let operation = CKModifySubscriptionsOperation(subscriptionsToSave: [subscription], subscriptionIDsToDelete: [] )
            operation.modifySubscriptionsCompletionBlock  = { (subscriptions, deletedIds, error) in
                if error == nil {
                    print("we have a subscription \(String(describing: subscriptions))")
                    self.userDefaults.set(true, forKey: FJkSUBSCRIPTIONIsLocallyCached)
                    self.userDefaults.synchronize()
                } else {
                    print("NSModifySubscriptionCompleteionBlock error \(String(describing: error))")
                    print("Push registration FAILED")
                }
            }
            operation.qualityOfService = .background
            self.privateDatabase.add(operation)
        }
        modifyRecordZone.qualityOfService = .background
        self.privateDatabase.add(modifyRecordZone)
    }
    
    private func getTheUserForStore(entity: String, attribute: String, sortAttribute: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K != %@", attribute, "")
        let sectionSortDescriptor = NSSortDescriptor(key: sortAttribute, ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        self.fetched = try! self.managedObjectContext.fetch(fetchRequest) as! [FireJournalUser]
        
        if self.fetched.isEmpty {
            print("no user available")
            return
        } else {
            fju = self.fetched.last
            if let guid = fju.userGuid {
                self.subscriptionsService.fjUserGuid = guid
            }
            if let email = fju.emailAddress {
                self.subscriptionsService.fjUserEmail = email
            }
            if let uName = fju.userName {
                print("here is the userName \(uName)")
            } else {
                var fName = ""
                var lName = ""
                if let first:String = self.fju.firstName {
                    fName = first
                }
                if let last:String = self.fju.lastName {
                    lName = last
                }
                fju.userName = "\(fName) \(lName)"
                fju.fjpUserModDate = Date()
                fju.fjpUserBackedUp = false
                saveContext()
            }
            subscriptionsService.fetchAvailableProducts()
            if !subscriptionBought {
                subscriptionsService.getAppReceipt()
                let subscribed = subscriptionsService.subscribed
                self.userDefaults.set(subscribed, forKey: FJkSUBCRIPTIONBought)
                self.userDefaults.synchronize()
            }
            
        }
        
    }
    
}

