    //
    //  IncidentVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/14/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

class IncidentVC:  SpinnerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    lazy var tagProvider: TagProvider = {
        let provider = TagProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theTagContext: NSManagedObjectContext!
    
    lazy var nfirsActionTakenProvider: NFIRSActionTakenProvider = {
        let provider = NFIRSActionTakenProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theActionsTakenContext: NSManagedObjectContext!
    
    lazy var localIncidentProvider: LocalIncidentProvider = {
        let provider = LocalIncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theLocalIncidentContext: NSManagedObjectContext!
    
    lazy var nfirsIncidentTypeProvider: NFIRSIncidentTypeProvider = {
        let provider = NFIRSIncidentTypeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var nfirsIncidentTypeContext: NSManagedObjectContext!
    
    lazy var photoProvider: PhotoProvider = {
        let provider = PhotoProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var itemProvider: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    var child: SpinnerViewController!
    var childAdded: Bool = false
    var photosAvailable: Bool = false
    var journalImage: UIImage!
    var cameraType: Bool = false
    
    var id: NSManagedObjectID!
    var theUserTime: UserTime!
    var theUser: FireJournalUser!
    var theIncident: Incident!
    var theIncidentLocation: FCLocation!
    var theIncidentTime: IncidentTimer!
    var theIncidentAddress: IncidentAddress!
    var theIncidentLocal: IncidentLocal!
    var theIncidentNFIRS: IncidentNFIRS!
    var theIncidentNotes: IncidentNotes!
    var theIncidentTags = [Tag]()
    var theActionsTaken: ActionsTaken!
    var theIncidentMap: IncidentMap!
    var theIncidentNFIRSCompleteMods: IncidentNFIRSCompleteMods!
    var theIncidentNFIRSKSec: IncidentNFIRSKSec!
    var theIncidentNFIRSRequiredModules: IncidentNFIRSRequiredModules!
    var theIncidentNFIRSsecL: IncidentNFIRSsecL!
    var theIncidentNFIRSsecM: IncidentNFIRSsecM!
    var thePhoto: Photo!
    var theJournal: Journal!
    var validPhotos = [Photo]()
    var theTags = [Tag]()
    var theNFIRsActionsTaken = [NFIRSActionsTaken]()
    var theNFIRSIncidentTypes = [NFIRSIncidentType]()
    var theLocalIncidentTypes = [UserLocalIncidentType]()
    var utGuid: String = ""
    var compact:SizeTrait = .regular
    var dataTVC: ModalDataTVC!

    
    var alertUp: Bool = false
    var incidentTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .fire
    var dateFormatter = DateFormatter()
    var typeNameA = ["100515IconSet_092016_fireboard","100515IconSet_092016_emsboard","100515IconSet_092016_rescueboard"]
    var incidentEditVC: IncidentEditVC!
    var nfirsIncidentType: Bool = false
    var theNFIRSIncidentTypeText: String = ""
    var theNFIRSIncidentTypeHeight: CGFloat = 0
    var theLocalIncidentType: Bool = false
    var theLocalIncidentTypeText: String = ""
    
//    MARK: -TIME OBJECTS-
    var theAlarmDate: Date!
    var theAlarmNotes: String = " "
    var theAlarmNotesAvailable: Bool = false
    var theAlarmNotesHeight: CGFloat = 0
    var theArrivalDate: Date!
    var theArrivalDateAvailable: Bool = false
    var theArrivalNotes: String = " "
    var theArrivalNotesAvailable: Bool = false
    var theArrivalNotesHeight: CGFloat = 0
    var theControlledDate: Date!
    var theControlledDateAvailable: Bool = false
    var theControlledNotes: String = " "
    var theControlledNotesAvailable: Bool = false
    var theControlledNotesHeight: CGFloat = 0
    var theLastUnitDate: Date!
    var theLastUnitDateAvailable: Bool = false
    var theLastUnitNotes: String = " "
    var theLastUnitNotesAvailable: Bool = false
    var theLastUnitNotesHeight: CGFloat = 0
    var theIncidentNote: String = " "
    var theIncidentNotesAvailable: Bool = false
    var theIncidentNotesHeight: CGFloat = 0
    var theAction1: String = " "
    var theAction1Available: Bool = false
    var theAction1Height: CGFloat = 0
    var theAction2: String = " "
    var theAction2Available: Bool = false
    var theAction2Height: CGFloat = 0
    var theAction3: String = " "
    var theAction3Available: Bool = false
    var theAction3Height: CGFloat = 0
    var theTagString: String = " "
    var theTagsAvailable: Bool = false
    var theTagsHeight: CGFloat = 0
    
    var fromMap: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
            //        MARK: additional notifications
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        
        setUpNavigationButton()
        
        getTheTags()
        getTheActionsTaken()
        getTheNFIRSIncidentType()
        getTheLocalIncidentTypes()
        
        if id != nil {
            getUserLocation.determineLocation()
            buildTheIncident()
            configureIncidentTableView()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func setUpNavigationButton() {
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveIncident(_:)))
        
        navigationItem.rightBarButtonItem = saveButton
        
        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Incident", style: .plain, target: self, action: #selector(returnToList(_:)))
            navigationItem.leftBarButtonItem = listButton
            navigationItem.setLeftBarButtonItems([listButton], animated: true)
            navigationItem.leftItemsSupplementBackButton = false
            let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
            ]
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
        }
        
        
        if (Device.IS_IPHONE){self.navigationController?.navigationBar.barTintColor = UIColor(named: "FJIconRed")
            self.navigationController?.navigationBar.isTranslucent = false
            let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
            ]
            saveButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
            saveButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
        } else {
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
    }
    
    @objc private func saveIncident(_ sender:Any) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated Incident merge that"])
            }
            let objectID = theIncident.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue :FJkCKModifyIncidentToCloud),
                             object: nil,
                             userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            theAlert(message: "The incident data has been saved.")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "IncidentEdit saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    @objc private func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue:FJkINCIDENTLISTCALLED),
                             object: nil,
                             userInfo: nil)
            }
        }
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact Incident")
            case .regular:
                print("regular Incident")
            }
        }
    }
    
    
    func buildTheIncident() {
        
        theIncident = context.object(with: id) as? Incident
        
        if theIncident.incidentGuid == nil {
            theIncident.incidentGuid = UUID()
        }
        
        if theIncident.theLocation != nil {
            theIncidentLocation = theIncident.theLocation
        } else {
            theIncidentLocation = FCLocation(context: context)
            theIncidentLocation.guid = UUID()
            theIncidentLocation.incident = theIncident
        }
        if theIncident.incidentAddressDetails != nil {
            theIncidentAddress = theIncident.incidentAddressDetails
        }
        if theIncident.incidentMapDetails != nil {
            theIncidentMap = theIncident.incidentMapDetails
        }
        if theIncident.incidentTimerDetails != nil {
            theIncidentTime = theIncident.incidentTimerDetails
            if let alarmNote = theIncidentTime.incidentAlarmNotesSC as? String {
                theAlarmNotes = alarmNote
                theAlarmNotesAvailable = true
                theAlarmNotesHeight = configureLabelHeight(text: alarmNote)
                theAlarmDate = theIncidentTime.incidentAlarmDateTime
            }
            if let arrivalNote = theIncidentTime.incidentArrivalNotesSC as? String {
                theArrivalNotes = arrivalNote
                theArrivalNotesAvailable = true
                theArrivalNotesHeight = configureLabelHeight(text: arrivalNote)
                if let theDate = theIncidentTime.incidentArrivalDateTime {
                    theArrivalDate = theDate
                }
            }
            if let controlledNote = theIncidentTime.incidentControlledNotesSC as? String {
                theControlledNotes = controlledNote
                theControlledNotesAvailable = true
                theControlledNotesHeight = configureLabelHeight(text: controlledNote)
                if let theDate = theIncidentTime.incidentControlDateTime {
                    theControlledDate = theDate
                }
            }
            if let lastUnitNote = theIncidentTime.incidentLastUnitClearedNotesSC as? String {
                theLastUnitNotes = lastUnitNote
                theLastUnitDateAvailable = true
                theLastUnitNotesHeight = configureLabelHeight(text: lastUnitNote)
                if let theDate = theIncidentTime.incidentLastUnitDateTime {
                    theLastUnitDate = theDate
                }
            }
        }
        if theIncident.incidentLocalDetails != nil {
            theIncidentLocal = theIncident.incidentLocalDetails
        }
        if theIncident.incidentNFIRSDetails != nil {
            theIncidentNFIRS = theIncident.incidentNFIRSDetails
            if let text = theIncidentNFIRS.incidentTypeTextNFRIS {
                nfirsIncidentType = true
                theNFIRSIncidentTypeText = text
                theNFIRSIncidentTypeHeight = configureLabelHeight(text: text)
            }
        }
        if theIncident.incidentTagDetails != nil {
            theIncidentTags = theIncident.tags?.allObjects as! [Tag]
            theTagsAvailable = true
            theIncidentTags = theIncidentTags.sorted { $0.name! < $1.name! }
            let count = theIncidentTags.count
            let counted = count / 6
            theTagsHeight = CGFloat(counted * 44)
            if theTagsHeight < 100 {
                theTagsHeight = 88
            }
        }
        if theIncident.actionsTakenDetails != nil {
            theActionsTaken = theIncident.actionsTakenDetails
            var action1: String = ""
            var action2: String = ""
            var action3: String = ""
            if let action1number = theActionsTaken.primaryActionNumber {
                action1 = action1number
                if let action1text = theActionsTaken.primaryAction {
                    action1 = action1 + " " + action1text
                    theAction1 = action1
                    theAction1Available = true
                    theAction1Height = configureLabelHeight(text: action1)
                }
            }
            if let action2number = theActionsTaken.additionalTwoNumber {
                action2 = action2number
                if let action2text = theActionsTaken.additionalTwo {
                    action2 = action2 + " " + action2text
                    theAction2 = action2
                    theAction2Available = true
                    theAction2Height = configureLabelHeight(text: action2)
                }
            }
            if let action3number = theActionsTaken.additionalThreeNumber {
                action3 = action3number
                if let action3text = theActionsTaken.additionalThree {
                    action3 = action3 + " " + action3text
                    theAction3 = action3
                    theAction3Available = true
                    theAction3Height = configureLabelHeight(text: action3)
                }
            }
        }
        if theIncident.incidentNotesDetails != nil {
            theIncidentNotes = theIncident.incidentNotesDetails
            if let note = theIncidentNotes.incidentNote {
                theIncidentNote = note
                theIncidentNotesAvailable = true
                theIncidentNotesHeight = configureLabelHeight(text: note)
            }
        }
        getTheUser()
        getTheLastUserTime()
    }
    
    func saveIncident(_ sender:Any, completionBlock: () -> ()) {
        do {
            try context.save()
            self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
            if !self.validPhotos.isEmpty {
                self.photoProvider.saveImageDataiIfNeeded(for: self.theJournal.photo!, taskContext: self.taskContext)  {
                    DispatchQueue.main.async {
                        self.nc.post(name: .fireJournalCameraPhotoSaved, object: nil)
                    }
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated journal merge that"])
            }
            completionBlock()
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "Journal saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
}

