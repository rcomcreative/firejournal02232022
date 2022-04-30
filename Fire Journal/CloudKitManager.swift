    //
    //  CloudKitManager.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 12/6/18.
    //  Copyright © 2020 PureCommand, LLC. All rights reserved.
    //

    import UIKit
    import Foundation
    import CoreData
    import CloudKit

    public enum CloudTypes:Int {
        case fjuser
        case journals
        case incidents
        case ics214
        case userTime
        case arcForm
        case user
        case userAttendee
        case userCrews
        case userResourcesGroups
        case localIncidentTypes
        case userTags
        case ics214Personel
        case userResources
        case icsActivityLog
        case nfirsStreetType
        case userFDResources
    }

    public enum TheEntities:String {
        case fjUser = "FireJournalUser" //
        case fjJournal = "Journal" //
        case fjIncident = "Incident" //
        case fjICS214 = "ICS214Form" //
        case fjUserTime = "UserTime"
        case fjArcForm = "ARCrossForm" //
        case fjAttendee = "UserAttendees" //
        case fjCrews = "UserCrews" //
        case fjResourcesG = "UserResourcesGroup" //
        case fjLocalIncident = "UserLocalIncidentType"
        case fjUserTags = "UserTags"
        case fjICS214Personnel = "ICS214Personnel"
        case fjUserAttendee = "UserAttendee"
        case fjUserResources = "UserResources"
        case fjICS214ActivityLog = "ICS214ActivityLog"
        case fjNFIRSStreetType = "NFIRSStreetType"
        case fjUserFDResource = "UserFDResource"
        case fjResidence = "Residence"
        case fjLocalPartners = "LocalPartners"
        case fjNationalPartners = "NationalPartners"
        case fjFINISHED = "Finished"
    }

    class CloudKitManager: NSObject {
        
        //    MARK: -Properties
        static let shared = CloudKitManager(name: FJkCLOUDKITCONTAINERNAME)
        
        var backgroundTask : UIBackgroundTaskIdentifier = .invalid
        
        let cloudKitName: String
        var context:NSManagedObjectContext!
        var container:CKContainer!
        var privateDatabase:CKDatabase!
        //    let permissions: CKContainer.Application.Permissions!
        var bkgrdContext:NSManagedObjectContext!
        var thread:Thread!
        let nc = NotificationCenter.default
        let userDefaults = UserDefaults.standard
        var sharedDBChangeToken:CKServerChangeToken!
        var fjuserRs = [CKRecord]()
        var journalRs = [CKRecord]()
        var incidentRs = [CKRecord]()
        var userAttendeesRs = [CKRecord]()
        var userCrewRs = [CKRecord]()
        var ics214Rs = [CKRecord]()
        var userTimRs =  [CKRecord]()
        var arcCrossFormRs = [CKRecord]()
        var residenceRs = [CKRecord]()
        var localPartnersRs = [CKRecord]()
        var nationalPartnersRs = [CKRecord]()
        var userResourcesGroupRs = [CKRecord]()
        var userLocalIncidentTypeRs = [CKRecord]()
        var userTimeRs = [CKRecord]()
        var fjUserTagRs = [CKRecord]()
        var fjICS214PersonnelRs = [CKRecord]()
        var fjUserAttendeeRs = [CKRecord]()
        var fjUserResourceRs = [CKRecord]()
        var fjICS214ActivityLogRs = [CKRecord]()
        var fjNFIRSStreetTypeRs = [CKRecord]()
        var fjUserFDResourcesRs = [CKRecord]()
        
        var cloudType = CloudTypes(rawValue: 0)
        var recordEntity:TheEntities = TheEntities.fjUser
        var objectID: NSManagedObjectID? = nil
        var zoneIDs = [CKRecordZone.ID]()
        let pendingOperations = PendingOperations()
        let versionPendingOperation = VersionPendingOperation()
        let resourcesPendingOperations = ResourcesPendingOperations()
        let locationsSCPendingOperations = UpdateLocationsSCPendingOperations()
        let weatherPendingOperations = WeatherPendingOperations()
        let arcFormPendingOperations = ARCFormPendingOperations()
        let tagsReloadOperations = TagsPendingOperation()
        let resourcesReloadOperations = ResourceReloadPendingOperation()
        let rankReloadOperations = RankPendingOperation()
        let platoonReloadOperations = PlatoonPendingOperation()
        let streetTypeReloadOperations = StreetTypePendingOperation()
        let localIncidentTypeReloadOperations = LocalIncidentTypePendingOperation()
        let userSyncOperation = UserSyncOperation()
        let journalSyncOperation = JournalSyncOperation()
        let incidentSyncOperation = IncidentSyncOperation()
        let userTimeSyncOperation = UserTimeSyncOperation()
        let ics214SyncOperation = ICS214SyncOperation()
        let arcFormSyncOperation = ArcFormSyncOperation()
        let userAttendeeSyncOperation = UserAttendeeSyncOperation()
        let ics214ActivityLogSyncOperation = ICS214ActivityLogSyncOperation()
        let ics214PersonalSyncOperation = ICS214PersonalSyncOperation()
        let fdResourcesSyncOperation = FDResourcesSyncOperation()
        var operation: String = "CloudKitManager"
        var runOnce: Bool = false
        var bkgrndTask: BkgrndTask?
        var firstRun: Bool = false
        
        lazy var theUserProvider: FireJournalUserProvider = {
            let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
            return provider
        }()
        var theUserContext: NSManagedObjectContext!
        
        //    MARK: -INIT-
        private init(name: String) {
            self.cloudKitName = name
            super.init()
        }
        
        /**
         The URL of the thumbnail folder.
         */
        static var attachmentFolder: URL = {
            var url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(  FConnectName, isDirectory: true)
            url = url.appendingPathComponent("attachments", isDirectory: true)
            
                // Create it if it doesn’t exist.
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    
                } catch {
                    print("###\(#function): Failed to create thumbnail folder URL: \(error)")
                }
            }
            return url
        }()
        
        func registerBackgroundTask() {
            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
                self?.endBackgroundTask()
            }
            //      assert(backgroundTask != .invalid)
        }
        
        func endBackgroundTask() {
            //        print("Background task ended. BackgroundTask \(backgroundTask.self) operation: \(operation)")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        
        func getTheData(moc:NSManagedObjectContext) {
            context = moc
            container = CKContainer.init(identifier: cloudKitName)
            privateDatabase = container.privateCloudDatabase
            bkgrdContext = makeBckGround()
            thread = Thread(target:self, selector:#selector(runTheOperations), object:nil)
            createNotificationObservers()
            let available:Bool = cloudServiceAvailable()
            print(available)
            runTheOperations()
        }
        
        //    MARK: -CLOUD SERVICE AVAILABLE-
        func cloudServiceAvailable() -> Bool {
            var available:Bool = true
            
            let reach = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
            if reach {
                if container != nil && privateDatabase != nil {
                    container.accountStatus(completionHandler: { ckAccountStatus, statusError in
                        switch ckAccountStatus {
                        case .noAccount: available = false
                        case .restricted: available = false
                        case .couldNotDetermine:
                            let error = statusError ?? NSError(domain: CKErrorDomain, code: CKError.notAuthenticated.rawValue, userInfo: nil)
                            print(error)
                            available = false
                        case .available:
                            available = true
                        default: break
                        }
                    })
                }
            }
            return available
        }
        
        @objc func runTheOperations() {
            let testThread:Bool = thread.isMainThread
            print("here is testThread \(testThread) and \(Thread.current) and here are the user defaults \(userDefaults)")
        }
        
        func makeBckGround()->NSManagedObjectContext {
            let bkgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            bkgroundContext.persistentStoreCoordinator = context.persistentStoreCoordinator
            return bkgroundContext
        }
        
        //    MARK: -CREATE NOTIFICATION-
        func createNotificationObservers() {
            nc.addObserver(self,selector:#selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
            
            
            nc.addObserver(self,selector:#selector(appMovedToForegraound), name: UIApplication.willEnterForegroundNotification, object: nil)
            
            nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: bkgrdContext)
            
            nc.addObserver(self, selector:#selector(zoneRecordsCalled(notification:)),name:NSNotification.Name(rawValue: FJkCKZoneRecordsCALLED), object: nil)
            
            nc.addObserver(self, selector:#selector(newIncidentSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKNewIncidentCreated), object: nil)
            
            nc.addObserver(self, selector:#selector(newJournalSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKNewJournalCreated), object: nil)
            
            nc.addObserver(self, selector:#selector(newProjectSendToCloud(nc:)),name: .fireJournalNewProjectCreatedSendToCloud, object: nil)
            
            nc.addObserver(self, selector:#selector(modifiedProjectSendToCloud(nc:)),name: .fireJournalProjectModifiedSendToCloud, object: nil)
            
            nc.addObserver(self, selector:#selector(newStartEndSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKNewStartEndCreated), object: nil)
            
            nc.addObserver(self, selector:#selector(modifiedStartEndSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKMODIFIEDSTARTENDTOCLOUD), object: nil)
            
            nc.addObserver(self, selector:#selector(modifyIncidentSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKModifyIncidentToCloud), object: nil)
            
            nc.addObserver(self, selector:#selector(modifyJournalSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKModifyJournalToCloud), object: nil)
            
            nc.addObserver(self, selector:#selector(modifiedIncidentsSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKModifiedIncidentsToCloud), object: nil)
            
            //        nc.addObserver(self, selector:#selector(modifiedJournalsSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKModifiedJournalsToCloud), object: nil)
            
            nc.addObserver(self, selector:#selector(newFireJournalUserSendToTheCloud(notification:)),name:NSNotification.Name(rawValue: FJkFJUserNEWSendToCloud), object: nil)
            
            nc.addObserver(self, selector:  #selector(modifiedFireJournalUserSendToTheCloud(notification:)),name: .fireJournalUserModifiedSendToCloud , object: nil)
            
            nc.addObserver(self, selector:#selector(newICS214SendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkNEWICS214FormCreated), object: nil)
            
            nc.addObserver(self, selector:#selector(modifiedICS214SendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(newARCFormToCloud(notification:)),name:NSNotification.Name(rawValue: FJkCKNewARCrossCreated), object: nil)
            
            nc.addObserver(self, selector:#selector(newICS214ActivitySendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(newICS214PersonnelSendToCloud(notification:)),name:NSNotification.Name(rawValue: FJkNEWICS214PERSONNEL_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(deleteFromICS214Personnel(notification:)), name: NSNotification.Name(FJkDELETEMODIFIEDICS214PERSONNEL_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(deleteFromICS214ActivityLog(notification:)), name: NSNotification.Name(FJkDELETEMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(modifiedARCFormToCloud(notification:)),name:NSNotification.Name(rawValue: fjkMODIFIEDARCFORM_GOTOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector:#selector(joinFreshDesk(notification:)),name:NSNotification.Name(rawValue: FJkFRESHDESK_UPDATENow), object: nil)
            
            nc.addObserver(self, selector:#selector(cleanUpUserAttendees(notification:)),name:NSNotification.Name(rawValue: FJkCLEANUSERATTENDEES), object: nil)
            
            nc.addObserver(self, selector:#selector(deleteFromList(notification:)),name:NSNotification.Name(rawValue: FJkDELETEFROMLIST), object: nil)
            
            nc.addObserver(self, selector: #selector(userFDResourceSyncFromCloud(notification:)), name: NSNotification.Name(FJkFDRESOURCESSYNCFROMCLOUD), object: nil)
            
            nc.addObserver(self, selector: #selector(newUserResourceToCloud(notification:)), name: NSNotification.Name(rawValue:FJkUSERRESOURCENEWTOCLOUD), object: nil)
            
            nc.addObserver(self, selector: #selector(newUserFDResourceToCloud(notification:)), name: NSNotification.Name(rawValue:FJkFDRESOURCESNEWTOCLOUD), object: nil)
            
            nc.addObserver(self, selector: #selector(modifyUserFDResourceToCloud(notification:)), name: NSNotification.Name(rawValue:FJkFDRESOURCESMODIFIEDTOCLOUD), object: nil)
            
            nc.addObserver(self, selector: #selector(deleteUserFDResourceToCloud(notification:)), name: NSNotification.Name(rawValue:FJkFDRESOURCESDELETETOCLOUD), object: nil)
            
            nc.addObserver(self, selector: #selector(runUserResourcesCustomTrueFalse(notification:)), name: NSNotification.Name(rawValue:FJkSETTINGSUSERRESOURCESCUSTOMRUN), object: nil)
            
            nc.addObserver(self, selector: #selector(runUserResourcesPointOfTruth(notification:)), name: NSNotification.Name(rawValue:FJkUSERFDRESOURCESPOINTOFTRUTH), object: nil)
            
            nc.addObserver(self, selector: #selector(runCallVersionControl(ns:)), name: NSNotification.Name(rawValue:FJkCALLVERSIONCONTROL), object: nil)
            
            nc.addObserver(self, selector: #selector(newUserAttendeeToCloud(ns:)), name: NSNotification.Name(rawValue:FJkNEWUSERATTENDEE_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector: #selector(modifiedUserAttendeeToCloud(ns:)), name: NSNotification.Name(rawValue:FJkMODIFIEDUSERATTENDEE_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector: #selector(deleteUserAttendeeToCloud(ns:)), name: NSNotification.Name(rawValue:FJkDELETEUSERATTENDEE_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector: #selector(modifyICS214ActivitySendToCloud(ns:)), name: NSNotification.Name(rawValue:FJkMODIFIEDICS214ACTIVITYLOG_TOCLOUDKIT), object: nil)
            
            nc.addObserver(self, selector: #selector(moveLocationToLocaitonSC(ns:)), name: NSNotification.Name(rawValue:FJkNEXTLOCATIONUPDATE), object: nil)
            
            //        MARK: - NEW ARCFORM OPERATIONS-
            //        MARK: -OBSERVE WHEN NEW ARCFORM SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendNewArcFormToCloud(ns:)), name: NSNotification.Name(rawValue: FJkNEWARCFORMForCloudKit), object: nil)
            //        MARK: -OBSERVE WHEN MODIFIED ARCFORM SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendModifiedArcFormToCloud(ns:)), name:NSNotification.Name(rawValue: FJkMODIFIEDARCFORMForCloudKit), object: nil)
            //        MARK: -OBSERVE WHEN NEW JOURNAL SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendNewJournalToCloud(ns:)), name: NSNotification.Name(rawValue: FJkNEWJOURNALForCloudKit ), object: nil)
            //        MARK: -OBSERVE WHEN MODIFIED JOURNAL SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendModifiedJournalToCloud(ns:)), name: NSNotification.Name(rawValue: FJkMODIFIEDJOURNALForCloudKit ), object: nil )
            //        MARK: -OBSERVE WHEN NEW RESIDENCE SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendNewResidenceToCloud(ns:)), name: NSNotification.Name(rawValue: FJkNEWRESIDENCEForCloudKit ), object: nil )
            //        MARK: -OBSERVE WHEN NEW LOCALPARTNERS SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendNewLocalPartnersToCloud(ns:)), name: NSNotification.Name(rawValue: FJkNEWLOCALPARTNERSForCloudKit), object: nil )
            //        MARK: -OBSERVE WHEN NEW NATIONALPARTNERS SAVED SEND TO CLOUDKIT-
            nc.addObserver(self, selector: #selector(sendNewNationalPartnersToCloud(ns:)), name: NSNotification.Name(rawValue: FJkNEWNATIONALPARTNERSForCloudKit ), object: nil )
            //        MARK: -OBSERVE WHEN TAGS NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadTheTags(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserTagsCalled ), object: nil )
            //        MARK: -OBSERVE WHEN Resources NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadTheResources(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserResourcesCalled ), object: nil )
            //        MARK: -OBSERVE WHEN Rank NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadTheRank(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserRankCalled ), object: nil )
            //        MARK: -OBSERVE WHEN Platoon NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadThePlatoon(ns:)), name: NSNotification.Name(rawValue: FJkReloadUserPlatoonCalled ), object: nil )
            //        MARK: -OBSERVE WHEN STreetType NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadTheStreettype(ns:)), name: NSNotification.Name(rawValue: FJkReloadStreetTypeCalled ), object: nil )
            //        MARK: -OBSERVE WHEN LocalIncidentType NEED TO BE RELOADED-
            nc.addObserver(self, selector: #selector(reloadTheLocalIncidentType(ns:)), name: NSNotification.Name(rawValue: FJkReloadLocalIncidentTypesCalled ), object: nil )
            
            
        }
        
        //    MARK: -RELOAD ROUTINES-
        /// RELOAD SETTINGS LOCALINCIDENTTYPE PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadTheLocalIncidentType( ns: Notification ) {
            localIncidentTypeReloadOperations.localIncidentTypeReloadQueue.isSuspended = true
            let localIncidentReloadOperation = LocalIncidentTypeReloadOperation(context)
            localIncidentTypeReloadOperations.localIncidentTypeReloadQueue.addOperation(localIncidentReloadOperation)
            localIncidentTypeReloadOperations.localIncidentTypeReloadQueue.isSuspended = false
        }
        
        
        /// RELOAD SETTINGS STREETTYPE PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadTheStreettype( ns: Notification ) {
            streetTypeReloadOperations.streetTypeReloadQueue.isSuspended = true
            let streetTypeReloadOperation = StreetTypeReloadOperation(context)
            streetTypeReloadOperations.streetTypeReloadQueue.addOperation(streetTypeReloadOperation)
            streetTypeReloadOperations.streetTypeReloadQueue.isSuspended = false
        }
        
        /// RELOAD SETTINGS PLATOON PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadThePlatoon( ns: Notification ) {
            platoonReloadOperations.platoonReloadQueue.isSuspended = true
            let platoonReloadOperation = PlatoonReloadOperation(context)
            platoonReloadOperations.platoonReloadQueue.addOperation(platoonReloadOperation)
            platoonReloadOperations.platoonReloadQueue.isSuspended = false
        }
        
        /// RELOAD SETTINGS RANK PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadTheRank( ns: Notification ) {
            rankReloadOperations.rankReloadQueue.isSuspended = true
            let rankReloadOperation = RankReloadOperation(context)
            rankReloadOperations.rankReloadQueue.addOperation(rankReloadOperation)
            rankReloadOperations.rankReloadQueue.isSuspended = false
        }
        
        /// RELOAD SETTINGS USERRESOURCES PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadTheResources( ns: Notification ) {
            resourcesReloadOperations.resourcesReloadQueue.isSuspended = false
            let resourcesReloadOperation = ResourcesReloadOperation(context)
            resourcesReloadOperations.resourcesReloadQueue.addOperation(resourcesReloadOperation)
            resourcesReloadOperations.resourcesReloadQueue.isSuspended = false
        }
        
        /// RELOAD SETTINGS USERTAGS PLIST FOR CORE DATA
        /// - Parameter ns: NO USERINFO
        @objc func reloadTheTags( ns: Notification ) {
            tagsReloadOperations.tagsReloadQueue.isSuspended = true
            let tagsReloadOperation = TagsReloadOperation(context)
            tagsReloadOperations.tagsReloadQueue.addOperation(tagsReloadOperation)
            tagsReloadOperations.tagsReloadQueue.isSuspended = false
        }
        
        //    MARK: -SEND NEW ARCFORM TO CLOUD-
        /// Send New ARCForm to CloudKit
        /// - Parameter ns: Notification includes objectID
        @objc func sendNewArcFormToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendNewARCFormOperation = ARCrossFormNewToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendNewARCFormOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND MODIFIED ARCFORM TO CLOUD-
        /// Send Modified ARCForm to cloudkit
        /// - Parameter ns: Notification contains userinfo with objectID
        @objc func sendModifiedArcFormToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendModifiedARCFormOperation = ARCrossFormModifiedToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendModifiedARCFormOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND NEW JOURNAL TO CLOUD-
        /// New Journal sent to cloudkit
        /// - Parameter ns: notification userinfo includes objectid
        @objc func sendNewJournalToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendNewJournalFormOperation = JournalNewToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendNewJournalFormOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND MODIFIED JOURNAL TO CLOUD-
        /// send modified journal to cloudkit
        /// - Parameter ns: notification userinfo holds objectID
        @objc func sendModifiedJournalToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendModifiedJournalFormOperation = JournalModifiedToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendModifiedJournalFormOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND NEW RESIDENCE TO CLOUD-
        /// Send new residence to cloudkit
        /// - Parameter ns: notification userinfo hold objectid
        @objc func sendNewResidenceToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendNewResidenseToCloudOperation = ResidenceNewToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendNewResidenseToCloudOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND NEW LOCAL PARTNERS TO CLOUD-
        /// Send new Local Partner to CloudKit
        /// - Parameter ns: notification user info hold objectID
        @objc func sendNewLocalPartnersToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendNewLocalPartnersToCloudOperation = LocalPartnersNewToCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendNewLocalPartnersToCloudOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        //    MARK: -SEND NEW NATIONALPARTNERS TO CLOUD-
        /// send new National Partner to cloudkit
        /// - Parameter ns: notification holds usesinfo with objectid
        @objc func sendNewNationalPartnersToCloud( ns: Notification ) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                if objectID != nil {
                    
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = true
                    let sendNewNationalPartnersToCloudOperation = NationalPartnersNewCloudOperation( context, database: privateDatabase, objectID: objectID! )
                    arcFormPendingOperations.arcFormTypeQueue.addOperation( sendNewNationalPartnersToCloudOperation )
                    arcFormPendingOperations.arcFormTypeQueue.isSuspended = false
                    
                }
            }
        }
        
        
        
        @objc private func moveLocationToLocaitonSC(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let menuType = userInfo["MenuItems"] as? MenuItems
                locationsSCPendingOperations.locationsSCTypeQueue.isSuspended = true
                var type:MenuItems!
                switch menuType {
                case .arcForm:
                    type = MenuItems.arcForm
                case .fjuser:
                    type = MenuItems.fjuser
                case .fireSafetyInspection:
                    type = MenuItems.fireSafetyInspection
                case .ics214:
                    type = MenuItems.ics214
                case .incidents:
                    type = MenuItems.incidents
                case .userFDResource:
                    type = MenuItems.userFDResource
                case .journal:
                    type = MenuItems.journal
                case .finished:
                    type = MenuItems.finished
                default: break
                }
                if type != MenuItems.finished {
                    let moveLocationsOperation = MoveLocationToLocationSCOperation.init(context, database: privateDatabase, theType: type)
                    locationsSCPendingOperations.locationsSCTypeQueue.addOperation(moveLocationsOperation)
                } else {
                    userDefaults.set(true, forKey: FJkMoveTheLocationsToLocationsSC)
                    userDefaults.synchronize()
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkLocationsAllUpdatedToSC), object: nil, userInfo: nil)
                    }
                }
                locationsSCPendingOperations.locationsSCTypeQueue.isSuspended = false
            }
        }
        
        // MARK: -USER ATTENDEES-
        @objc private func newUserAttendeeToCloud(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newUserAttendeeToCloud = fjkNewUserAttendeeSyncOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newUserAttendeeToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        @objc private func modifiedUserAttendeeToCloud(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifyUserAttendeeToCloud = fjkModifyUserAttendeeSyncOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifyUserAttendeeToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func deleteUserAttendeeToCloud(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let ckrObject = userInfo["ckrObject"] as? Data
                if ckrObject != nil {
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                    let deleteUserAttendeeListOperation = fjkDeleteUserAttendeeSyncOperation.init(context, dataObject: ckrObject!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteUserAttendeeListOperation)
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
                }
            }
        }
        
        //    MARK: -APP TO BACKGROUND-
        @objc func appMovedToBackground() {
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            endBackgroundTask()
        }
        
        @objc func appMovedToForegraound() {
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
//            registerBackgroundTask()
        }
        
        //     MARK: -VERSION CONTROL-
        @objc func runCallVersionControl(ns: Notification) {
            versionPendingOperation.versionPendingQueue.isSuspended = true
            let checkVersionOperation = VersionControlOperation.init(theDate: Date())
            versionPendingOperation.versionPendingQueue.addOperation(checkVersionOperation)
            versionPendingOperation.versionPendingQueue.isSuspended = false
        }
        
        //    MARK: -POINT OF TRUTH-USER RESOURCES-
        @objc func runUserResourcesPointOfTruth(notification: Notification) {
//            bkgrndTask = BkgrndTask.init(bkgrndTask: backgroundTask)
//            bkgrndTask?.operation = "CloudKitManager"
//            bkgrndTask?.registerBackgroundTask()
            resourcesPendingOperations.resourcesTypeQueue.isSuspended = true
            let userFDResourcesSync = UserFDResourcesPointOfTruthOperation.init(context)
            resourcesPendingOperations.resourcesTypeQueue.addOperation(userFDResourcesSync)
            resourcesPendingOperations.resourcesTypeQueue.isSuspended = false
        }
        
        //    MARK: -FRESH DESK-
        @objc func joinFreshDesk(notification: Notification) {
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            let freshDeskOperation = FreshDeskOperation.init(context)
            pendingOperations.nfirsIncidentTypeQueue.addOperation(freshDeskOperation)
            //        pendingOperations.nfirsIncidentTypeQueue.qualityOfService = .background
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        }
        
        //    MARK: -CLOUDKIT CHANGES-
        func getCloudKitChanges(zoneIDs: [CKRecordZone.ID], completionHandler: (() -> Void)? = nil) {

            if let data = userDefaults.data(forKey: FJkCKZondChangeToken) {
                do {
                    if let token = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? CKServerChangeToken {
                        sharedDBChangeToken = token
                    }
                } catch {
                    print("there wasn't a token as such")
                }
            }
            
            let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
            options.previousServerChangeToken = sharedDBChangeToken
            //        options.desiredKeys = ["theEntity"]
            
            for zoneId in zoneIDs {
                print("here is the zoneID \(zoneId)")
                let changesOperation = CKFetchRecordZoneChangesOperation.init(recordZoneIDs: [zoneId], optionsByRecordZoneID: [zoneId:options])
                
                changesOperation.fetchAllChanges = true
                var counter = 0
                
                //            var countF = 0
                changesOperation.recordChangedBlock = { [weak self] record in
                    //                do {
                    if let entity = record["theEntity"] as? String {
                        switch entity {
                        case TheEntities.fjUser.rawValue:
                            self?.cloudType = CloudTypes.fjuser
                            self?.fjuserRs.append(record)
                        case TheEntities.fjUserTime.rawValue:
                            self?.cloudType = CloudTypes.userTime
                            self?.userTimRs.append(record)
                        case TheEntities.fjJournal.rawValue:
                            self?.cloudType = CloudTypes.journals
                            self?.journalRs.append(record)
                        case TheEntities.fjIncident.rawValue:
                            self?.cloudType = CloudTypes.incidents
                            self?.incidentRs.append(record)
                        case TheEntities.fjICS214.rawValue:
                            self?.cloudType = CloudTypes.ics214
                            self?.ics214Rs.append(record)
                        case TheEntities.fjArcForm.rawValue:
                            self?.cloudType = CloudTypes.arcForm
                            self?.arcCrossFormRs.append(record)
                        case TheEntities.fjUserTime.rawValue:
                            self?.cloudType = CloudTypes.userTime
                            self?.userTimeRs.append(record)
                        case TheEntities.fjUserFDResource.rawValue:
                            self?.cloudType = CloudTypes.userFDResources
                            self?.fjUserFDResourcesRs.append(record)
                        case TheEntities.fjAttendee.rawValue:
                            self?.cloudType = CloudTypes.userAttendee
                            self?.userAttendeesRs.append(record)
                        case TheEntities.fjCrews.rawValue:
                            self?.cloudType = CloudTypes.userCrews
                            self?.userCrewRs.append(record)
                        case TheEntities.fjResourcesG.rawValue:
                            self?.cloudType = CloudTypes.userResourcesGroups
                            self?.userResourcesGroupRs.append(record)
                        case TheEntities.fjLocalIncident.rawValue:
                            self?.cloudType = CloudTypes.localIncidentTypes
                            self?.userLocalIncidentTypeRs.append(record)
                        case TheEntities.fjUserTags.rawValue:
                            self?.cloudType = CloudTypes.userTags
                            self?.fjUserTagRs.append(record)
                        case TheEntities.fjICS214Personnel.rawValue:
                            self?.cloudType = CloudTypes.ics214Personel
                            self?.fjICS214PersonnelRs.append(record)
                        case TheEntities.fjUserAttendee.rawValue:
                            self?.cloudType = CloudTypes.userAttendee
                            self?.fjUserAttendeeRs.append(record)
                        case TheEntities.fjUserResources.rawValue:
                            self?.cloudType = CloudTypes.userResources
                            self?.fjUserResourceRs.append(record)
                        case TheEntities.fjICS214ActivityLog.rawValue:
                            self?.cloudType = CloudTypes.icsActivityLog
                            self?.fjICS214ActivityLogRs.append(record)
                        case TheEntities.fjNFIRSStreetType.rawValue:
                            self?.cloudType = CloudTypes.nfirsStreetType
                            self?.fjNFIRSStreetTypeRs.append(record)
                        default:
                            print("here is an entity we didn't expect \(entity)")
                        }
                        counter += 1
                    }
                }
                
                changesOperation.recordWithIDWasDeletedBlock = { [weak self] (recordId, _) in
                    let id:String = recordId.recordName
                    var searchString:String = ""
                    if id.hasWhiteSpace {
                    }
                    if id.hasPeriod {
                        if let range = id.range(of: ".") {
                            let substring = id[..<range.lowerBound]
                            searchString = String(substring)
                            let type = Int(searchString)
                            if !((self?.firstRun) != nil) {
                                switch type {
                                case 01:
                                    self?.deleteFromCloudOperationByGuid(entity: "Journal", attribute: "fjpJGuidForReference", guid: id)
                                case 02:
                                    self?.deleteFromCloudOperationByGuid(entity: "Incident", attribute: "fjpIncGuidForReference", guid: id)
                                case 30:
                                    self?.deleteFromCloudOperationByGuid(entity: "ICS214Form", attribute: "ics214Guid", guid: id)
                                case 40:
                                    self?.deleteFromCloudOperationByGuid(entity: "ARCrossForm", attribute: "arcFormGuid", guid: id)
                                case 91:
                                    self?.deleteFromCloudOperationByGuid(entity: "UserFDResources", attribute: "fdResourceGuid", guid: id)
                                default:
                                    self?.deleteFromCloudWithGeneratedID(guid: id)
                                }
                            }
                            
                        }
                    }
                    
                    
                    // TODO: -Write this record deletion to memory
                }
                
                
                
                changesOperation.recordZoneChangeTokensUpdatedBlock = {  (zoneId, token, data) in
                    print("recordZoneChangeTokensUpdatedBlock saving to disk")
                    // TODO: -Flush record changes and deletions for this zone to disk
                }
                
                changesOperation.recordZoneFetchCompletionBlock = { [weak self] (zoneId, changeToken, _, _, error) in
                    if let error = error {
                        print("Error fetching zone changes for database:", error)
                        return
                    }
                    //                print("recordZoneFetchCompletionBlock saving to disk changeToken = ",changeToken as Any)
                    // TODO: -Flush record changes and deletions for this zone to disk
                    
                    // Write this new zone change token to disk
                    self?.sharedDBChangeToken = changeToken
                    self?.addTokenToDefaults()
                }
                
                changesOperation.fetchRecordZoneChangesCompletionBlock = { [weak self] error in
                    
                    if let ckError = error as? CKError {
                        if ckError.code == CKError.Code.partialFailure {
                            print("error was partial failure \(CKError.Code.partialFailure)")
                        }
                        print("Error fetching zone changes for database: \(ckError)")
                    }
                    print("fetch changes completed successfully")
                    
                    let count = counter
                    print(count)
                    
                    DispatchQueue.main.async {
                        self?.nc.post(name:Notification.Name(rawValue: FJkCKZoneRecordsCALLED),
                                      object: nil,
                                      userInfo: ["recordEntity":TheEntities.fjIncident])
                        completionHandler?()
                        //                    self?.endBackgroundTask()
                    }
                    
                    
                }
                
                privateDatabase.add(changesOperation)
                
            }
        }
        
        func extractDateFromDeletionString(datedString: String ) -> Date {
            let numbersBit = datedString.index(datedString.endIndex, offsetBy: -21)
            let dateString = String(datedString[numbersBit...])
            let record2Date = RecordIDToDate.init(stringDate:dateString)
            return record2Date.convertStringToDate()
        }
        
        func addTokenToDefaults()->Void {
//            registerBackgroundTask()
            DispatchQueue.main.async {
                let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: self.sharedDBChangeToken!, requiringSecureCoding: false)
                self.userDefaults.set(encodedData, forKey: FJkCKZondChangeToken)
                self.endBackgroundTask()
            }
        }
        
        func runFJUserOperation() {
            
        }
        
        func deleteFromCloudWithGeneratedID(guid: String) {
            self.pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            let deleteFromCloudWithGeneratedIDSyncOperation = DeleteFromCloudWithGeneratedIDSyncOperation.init(self.context, theCKRecordIDName: guid)
            self.pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteFromCloudWithGeneratedIDSyncOperation)
            self.pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        }
        
        func deleteFromCloudOperationByGuid(entity: String, attribute: String, guid: String) {
            self.pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            let deleteFromCDWithGuidOperation = DeleteFromCloudWithGuidSyncOperation.init(self.context, theGuid: guid, theEntity: entity, theAttribute: attribute)
            self.pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteFromCDWithGuidOperation)
            self.pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        }
        
        //    MARK: -ZONE RECORDS CALLED-
        @objc func zoneRecordsCalled(notification: Notification)->Void {

            if let userInfo = notification.userInfo as! [String: Any]?
            {
                recordEntity = userInfo["recordEntity"] as? TheEntities ?? TheEntities.fjUser
                
    //            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                
                switch recordEntity {
                case TheEntities.fjUser:
                    self.cloudType = CloudTypes.fjuser
                    if !fjuserRs.isEmpty {
                        userSyncOperation.userSyncQueue.isSuspended = false
                        var fjUsers = Array(NSOrderedSet(array: fjuserRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjUserLoader = FJIUserSyncOperation.init(theUserContext, ckArray: fjuserRs)
                        userSyncOperation.userSyncQueue.addOperation(fjUserLoader)
                        userSyncOperation.userSyncQueue.isSuspended = true
                        fjuserRs.removeAll()
                        fjUsers.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjUserTime])
                        }
                    }
                case TheEntities.fjJournal:
                    self.cloudType = CloudTypes.journals
                    if !journalRs.isEmpty {
                        journalSyncOperation.journalSyncQueue.isSuspended = true
                        var fjJournals = Array(NSOrderedSet(array: journalRs)) as! [CKRecord]
                        print("here is journalRs count: \(journalRs.count)")
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjJournalLoader = FJJournalLoader.init(theUserContext, ckArray: journalRs)
                        journalSyncOperation.journalSyncQueue.addOperation(fjJournalLoader)
                        journalSyncOperation.journalSyncQueue.isSuspended = false
                        journalRs.removeAll()
                        fjJournals.removeAll()
                    } else {
                        
                        if !self.firstRun {
                            DispatchQueue.main.async {
                                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                             object: nil,
                                             userInfo: ["recordEntity":TheEntities.fjUser])
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                             object: nil,
                                             userInfo: ["recordEntity":TheEntities.fjUserTime])
                            }
                        }
                    }
                case TheEntities.fjIncident:
                    self.cloudType = CloudTypes.incidents
                    if !incidentRs.isEmpty {
                        incidentSyncOperation.incidentSyncQueue.isSuspended = true
                        var fjIncidents = Array(NSOrderedSet(array: incidentRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjIncidentLoader = FJIncidentLoader.init(theUserContext, ckArray: fjIncidents)
                        incidentSyncOperation.incidentSyncQueue.addOperation(fjIncidentLoader)
                        incidentSyncOperation.incidentSyncQueue.isSuspended = false
                        incidentRs.removeAll()
                        fjIncidents.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjJournal])
                        }
                    }
                case TheEntities.fjUserTime:
                    self.cloudType = CloudTypes.userTime
                    if !userTimRs.isEmpty {
                        userTimeSyncOperation.userTimeSyncQueue.isSuspended = true
                        var fjUserTimes = Array(NSOrderedSet(array: userTimRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjUserTimeLoader = FJUserTimeSyncOperation.init(theUserContext,ckArray: fjUserTimes)
                        userTimeSyncOperation.userTimeSyncQueue.addOperation(fjUserTimeLoader)
                        userTimeSyncOperation.userTimeSyncQueue.isSuspended = false
                        userTimRs.removeAll()
                        fjUserTimes.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjICS214])
                        }
                    }
                case TheEntities.fjICS214:
                    self.cloudType = CloudTypes.ics214
                    if !ics214Rs.isEmpty {
                        ics214SyncOperation.ics214SyncQueue.isSuspended = true
                        var fjics214s = Array(NSOrderedSet(array: ics214Rs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjICS214Loader = FJICS214Loader.init(theUserContext, ckArray: fjics214s)
                        ics214SyncOperation.ics214SyncQueue.addOperation(fjICS214Loader)
                        ics214SyncOperation.ics214SyncQueue.isSuspended = false
                        ics214Rs.removeAll()
                        fjics214s.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjArcForm])
                        }
                    }
                case TheEntities.fjArcForm:
                    self.cloudType = CloudTypes.arcForm
                    if !arcCrossFormRs.isEmpty {
                        arcFormSyncOperation.arcFormSyncQueue.isSuspended = true
                        var fjARCFormss = Array(NSOrderedSet(array: arcCrossFormRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjARCFormLoader = FJARCCrossFormLoader.init(theUserContext, ckArray: fjARCFormss)
                        arcFormSyncOperation.arcFormSyncQueue.addOperation(fjARCFormLoader)
                        arcFormSyncOperation.arcFormSyncQueue.isSuspended = false
                        arcCrossFormRs.removeAll()
                        fjARCFormss.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjAttendee])
                        }
                    }
                case TheEntities.fjAttendee:
                    self.cloudType = CloudTypes.userAttendee
                    if !userAttendeesRs.isEmpty {
                        userAttendeeSyncOperation.userAttendeeSyncQueue.isSuspended = true
                        var fjUserAttendees = Array(NSOrderedSet(array: userAttendeesRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let fjUserAtteendeesLoader = FJUserAttendeesFromCloudSyncingOperation.init(theUserContext, ckArray: fjUserAttendees)
                        userAttendeeSyncOperation.userAttendeeSyncQueue.addOperation(fjUserAtteendeesLoader)
                        userAttendeeSyncOperation.userAttendeeSyncQueue.isSuspended = false
                        fjUserAttendeeRs.removeAll()
                        fjUserAttendees.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjICS214ActivityLog])
                        }
                    }
                case TheEntities.fjICS214ActivityLog:
                    self.cloudType = CloudTypes.icsActivityLog
                    if !fjICS214ActivityLogRs.isEmpty {
                        ics214ActivityLogSyncOperation.ics214ActivityLogSyncQueue.isSuspended = true
                        var fjICS214ALs = Array(NSOrderedSet(array: fjICS214ActivityLogRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let ics214ALogLoader = FJICS214ActivityLogOperation.init(theUserContext, ckArray: fjICS214ALs)
                        ics214ActivityLogSyncOperation.ics214ActivityLogSyncQueue.addOperation(ics214ALogLoader)
                        ics214ActivityLogSyncOperation.ics214ActivityLogSyncQueue.isSuspended = false
                        fjICS214ActivityLogRs.removeAll()
                        fjICS214ALs.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjICS214Personnel])
                        }
                    }
                case TheEntities.fjICS214Personnel:
                    self.cloudType = CloudTypes.ics214Personel
                    if !fjICS214PersonnelRs.isEmpty {
                        ics214PersonalSyncOperation.ics214PersonalSyncQueue.isSuspended = true
                        var fjICS214Ps = Array(NSOrderedSet(array: fjICS214PersonnelRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let ics214Personnel = FJICS214PersonnelOperation.init(theUserContext, ckArray: fjICS214Ps)
                        ics214PersonalSyncOperation.ics214PersonalSyncQueue.addOperation(ics214Personnel)
                        ics214PersonalSyncOperation.ics214PersonalSyncQueue.isSuspended = false
                        fjICS214PersonnelRs.removeAll()
                        fjICS214Ps.removeAll()
                    } else {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjUserFDResource])
                        }
                    }
                case TheEntities.fjUserFDResource:
                    self.cloudType = CloudTypes.userFDResources
                    self.firstRun = userDefaults.bool(forKey: FJkFIRSTRUNFORDATAFROMCLOUDKIT)
                    if fjUserFDResourcesRs.isEmpty {
                        DispatchQueue.main.async {
                            self.nc.post(name:Notification.Name(rawValue:FJkCKZoneRecordsCALLED),
                                         object: nil,
                                         userInfo: ["recordEntity":TheEntities.fjCrews])
                        }
                    } else {
                        fdResourcesSyncOperation.fdResourcesSyncQueue.isSuspended = true
                        var fjUserFDResources = Array(NSOrderedSet(array: fjUserFDResourcesRs)) as! [CKRecord]
                        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                        let ufdResources = FJUserFDResourcesSyncOperation.init(theUserContext, ckArray: fjUserFDResources, firstRun: firstRun)
                        fdResourcesSyncOperation.fdResourcesSyncQueue.addOperation(ufdResources)
                        fdResourcesSyncOperation.fdResourcesSyncQueue.isSuspended = false
                        fjUserFDResourcesRs.removeAll()
                        fjUserFDResources.removeAll()
                        userDefaults.set(false, forKey: FJkFIRSTRUNFORDATAFROMCLOUDKIT)
                        self.firstRun = false
                    }
                case TheEntities.fjCrews:
                    self.cloudType = CloudTypes.userCrews
                    DispatchQueue.main.async {
                        self.nc.post(name:Notification.Name(rawValue:FJkRELOADTHEDASHBOARD),
                                     object: nil,
                                     userInfo: ["recordEntity":""])
                    }
                    //                endBackgroundTask()
                    return
                //                return
                case TheEntities.fjLocalIncident:
                    self.cloudType = CloudTypes.localIncidentTypes
                //                TODO: -LOCAL_INCIDENT_TYPES
                case TheEntities.fjUserTags:
                    self.cloudType = CloudTypes.userTags
                //                TODO: -USER_TAGS
                case TheEntities.fjUserResources:
                    self.cloudType = CloudTypes.userResources
                //                TODO: -USER_RESOURSES
                case TheEntities.fjResourcesG:
                    self.cloudType = CloudTypes.userResourcesGroups
                //                TODO: -USER_RESOURSES_GROUPS
                case TheEntities.fjNFIRSStreetType:
                    self.cloudType = CloudTypes.nfirsStreetType
                //                TODO: -NFIRS_STREET_TYPES
                
                default:
                    print("here is an entity we didn't expect \(recordEntity)")
                }
                
    //            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -FDRESOURCES-POINT OF TRUTH-
        private func fdResoucesPointOfTruth() {
            let userFDResourcesUpdated = self.userDefaults.bool(forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
            if !userFDResourcesUpdated {
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:(FJkUSERFDRESOURCESPOINTOFTRUTH)),
                                 object: nil,
                                 userInfo: nil)
                }
                self.userDefaults.set(true, forKey: FJkUserFDResourcesPointOfTruthOperationHasRun)
                
            }
        }
        
        //    MARK: -ARC FORM-
        @objc private func newARCFormToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newARCFormToCloud = NewARCrossFormSendToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newARCFormToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedARCFormToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifiedARCFormToCloud = ModifyARCrossFormToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedARCFormToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -ICS214 TO CLOUD-
        @objc private func newICS214SendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newICS214ToCloud = NewICS214SendToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newICS214ToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedICS214SendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifiedICS214ToCloud = ModifyICS214ToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedICS214ToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -ICS214 ACTIVITYLOG-
        @objc private func newICS214ActivitySendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newICS214ActivityLogToCloud = NewICS214ActivityLogOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newICS214ActivityLogToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifyICS214ActivitySendToCloud(ns: Notification) {
            if let userInfo = ns.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifyICS214ActivityLogToCloud = ModifyICS214ActivityLogOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifyICS214ActivityLogToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        
        @objc private func deleteFromICS214ActivityLog(notification: NSNotification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                
                let theGuid = userInfo["theGuid"] as? String ?? ""
                
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if theGuid != "" {
                    let deleteICS214ActivityToCloud = DeleteICS214ActivityLogAssociatedWithFormOperation.init(context, guid: theGuid)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteICS214ActivityToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        
        //    MARK: -ICS214 PERSONNEL-
        @objc private func newICS214PersonnelSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newICS21PersonnelToCloud = NewICS214PersonnelOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newICS21PersonnelToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func deleteFromICS214Personnel(notification: NSNotification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                
                let theGuid = userInfo["theGuid"] as? String ?? ""
                
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if theGuid != "" {
                    let deleteICS214PersonnelToCloud = DeleteICS214PersonnelAssociatedWithFormOperation.init(context, guid: theGuid)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteICS214PersonnelToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -SHIFT TO CLOUD-
        @objc private func newStartEndSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newStartEndToCloud = NewUserTimeOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newStartEndToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedStartEndSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifiedStartEndToCloud = ModifiedUserTimeOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedStartEndToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -INCIDENT TO CLOUD-
        @objc private func newIncidentSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newIncidentToCloud = NewIncidentToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newIncidentToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        
        @objc private func modifyIncidentSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifyIncidentToCloud = ModifyIncidentToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifyIncidentToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedIncidentsSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectIDs:[NSManagedObjectID] = userInfo["objectIDs"] as! [NSManagedObjectID]
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectIDs.isEmpty {
                    print("no objectIDs that need backup")
                    return
                } else {
                    let modifiedIncidentsToCloud = AllModifiedIncidentsToCloud.init(context, objectIDs: objectIDs)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedIncidentsToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -JOURNAL TO CLOUD-
        @objc private func newJournalSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newJournalToCloud = NewJournalToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newJournalToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifyJournalSendToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let modifyJournalToCloud = ModifyJournalToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifyJournalToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
//        MARK: -PROJECT TO CLOUD-
        @objc private func newProjectSendToCloud(nc: Notification) {
            if let userInfo = nc.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
//                    let newJournalToCloud = NewJournalToCloudOperation.init(context, objectID: objectID!)
//                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newJournalToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedProjectSendToCloud(nc: Notification) {
            if let userInfo = nc.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
//                    let newJournalToCloud = NewJournalToCloudOperation.init(context, objectID: objectID!)
//                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newJournalToCloud)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        /*   @objc private func modifiedJournalsSendToCloud(notification: Notification) {
         if let userInfo = notification.userInfo as! [String: Any]? {
         let objectIDs:[NSManagedObjectID] = userInfo["objectIDs"] as! [NSManagedObjectID]
         pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
         if objectIDs.isEmpty {
         print("no objectIDs that need backup")
         return
         } else {
         let modifiedJournalsToCloud = AllModifiedJournalsToCloudOperation.init(context, objectIDs: objectIDs)
         pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedJournalsToCloud)
         }
         pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
         }
         }
         */
        
        //    MARK: -USER TO CLOUD-
        @objc private func newFireJournalUserSendToTheCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                if objectID != nil {
                    let newFireJournalUserToCloudOperation = NewFireJournalUserSendToCloudOperation.init(context, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(newFireJournalUserToCloudOperation)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifiedFireJournalUserSendToTheCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                print("here we are in cloudkit ModifiedFireJournalUserSendToCloudOperation")
                if objectID != nil {
                    theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
                    let modifiedFireJournalUserToCloudOperation = ModifiedFireJournalUserSendToCloudOperation.init(theUserContext, objectID: objectID!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(modifiedFireJournalUserToCloudOperation)
                }
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        //    MARK: -CLEAN UP ATTENDEES-
        @objc private func cleanUpUserAttendees(notification: Notification) {
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
            let cleanUpUserAttendeesOperation = CleanUpUserAttendees.init(context)
            pendingOperations.nfirsIncidentTypeQueue.addOperation(cleanUpUserAttendeesOperation)
            pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
        }
        
        //   MARK: -USER RESOURCES TO CLOUD-
        @objc private func userFDResourceSyncFromCloud(notification: Notification) {
            if !fjUserFDResourcesRs.isEmpty {
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                let userFDResourcesSyncFromCloudOperation = FJUserFDResourcesSyncFromCloudOperation.init(context, ckArray: fjUserResourceRs)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userFDResourcesSyncFromCloudOperation)
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        
        @objc private func newUserResourceToCloud(notification: Notification ) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                let userUSERResourcesNew2CloudOperation = NewUserResourceToCloudOperation.init(context, objectID: objectID!)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userUSERResourcesNew2CloudOperation)
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func newUserFDResourceToCloud(notification: Notification ) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                let userFDResourcesNew2CloudOperation = NewUserFDResourcesOperation.init(context, objectID: objectID!)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(userFDResourcesNew2CloudOperation)
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func modifyUserFDResourceToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let objectID = userInfo["objectID"] as? NSManagedObjectID
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                let modifyUserFDResourcesToCloudOperation = ModifyUserFDResourcesOperation.init(context, objectID: objectID!)
                pendingOperations.nfirsIncidentTypeQueue.addOperation(modifyUserFDResourcesToCloudOperation)
                pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
            }
        }
        
        @objc private func deleteUserFDResourceToCloud(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let guid = userInfo["guid"] as? String
                if guid != "" {
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                    let deleteUserFDResourceToCloud = DeleteUserFDResourcesSyncOperation.init(context, modifyDelete: true, guid: guid ?? "" )
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteUserFDResourceToCloud)
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
                }
            }
        }
        
        @objc private func runUserResourcesCustomTrueFalse(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                guard let customOrNot = userInfo["customOrNot"] as? Bool else { return  }
                if customOrNot {
                    print("Custom User Resources have been covered./")
                } else {
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                    let updateUserResourcesWithCustomBoolOperation = UpdateUserResourcesWithCustomBoolOperation.init(context)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(updateUserResourcesWithCustomBoolOperation)
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
                }
            }
        }
        
        //    MARK: -DELETE FROM LIST-
        @objc private func deleteFromList(notification: Notification) {
            if let userInfo = notification.userInfo as! [String: Any]? {
                let ckrObject = userInfo["ckrObject"] as? Data
                if ckrObject != nil {
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = true
                    let deleteFromListOperation = DeleteFromListOperation.init(context, dataObject: ckrObject!)
                    pendingOperations.nfirsIncidentTypeQueue.addOperation(deleteFromListOperation)
                    pendingOperations.nfirsIncidentTypeQueue.isSuspended = false
                }
            }
        }
        
        //    MARK: -FEETCH CHANGES MISSED-
        func fetchAnyChangesWeMissed()->Void {
//            registerBackgroundTask()
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
                        self.endBackgroundTask()
                    }
                    return
                }
                self.sharedDBChangeToken = newToken
                print("here is the new token \(String(describing: self.sharedDBChangeToken))")
                self.addTokenToDefaults()
                print(self.zoneIDs)
                self.getCloudKitChanges(zoneIDs: self.zoneIDs)
                //            self.endBackgroundTask()
            }
            
            privateDatabase.add(changesOperation)
        }
        
        // MARK: -
        // MARK: Notification Handling
        @objc func managedObjectContextDidSave(notification: Notification) {
            DispatchQueue.main.async {
                self.context.mergeChanges(fromContextDidSave: notification)
            }
        }
        
        
    }
