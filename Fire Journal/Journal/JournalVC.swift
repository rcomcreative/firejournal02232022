//
//  JournalVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

class JournalVC: SpinnerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    lazy var photoProvider: PhotoProvider = {
        let provider = PhotoProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    lazy var tagProvider: TagProvider = {
        let provider = TagProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theTagContext: NSManagedObjectContext!
    
    var itemProvider: [NSItemProvider] = []
    var iterator: IndexingIterator<[NSItemProvider]>?
    var child: SpinnerViewController!
    var childAdded: Bool = false
    var photosAvailable: Bool = false
    var journalImage: UIImage!
    var cameraType: Bool = false
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var id: NSManagedObjectID!
    var theUserTime: UserTime!
    var theUser: FireJournalUser!
    var theJournal: Journal!
    var theJournalLocation: FCLocation!
    var theJournalTags = [JournalTags]()
    var thePhoto: Photo!
    var theTags = [Tag]()
    var validPhotos = [Photo]()
    var utGuid: String = ""
    var compact:SizeTrait = .regular
    var dataTVC: ModalDataTVC!
    
    var alertUp: Bool = false
    var journalTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .station
    var dateFormatter = DateFormatter()
    var typeNameA = ["100515IconSet_092016_Stationboard c0l0r","ICONS_communityboard color","ICONS_Membersboard color","ICONS_training"]
    var journalEditVC: JournalEditVC!
    
    
    var theOverviewNotes: String = " "
    var theOverviewNotesAvailable: Bool = false
    var theOverviewNotesHeight: CGFloat = 0
    
    var theDiscussionNotes: String = " "
    var theDiscussionNotesAvailable: Bool = false
    var theDiscussionNotesHeight: CGFloat = 0
    
    var theNextStepsNotes: String = " "
    var theNextStepsNotesAvailable: Bool = false
    var theNextStepsNotesHeight: CGFloat = 0
    
    var theSummaryNotes: String = " "
    var theSummaryNotesAvailable: Bool = false
    var theSummaryNotesHeight: CGFloat = 0
    
    var theTagString: String = " "
    var theTagsAvailable: Bool = false
    var theTagsHeight: CGFloat = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
            //        MARK: additional notifications
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(photoErrorAlert(notification:)), name: .fireJournalPhotoErrorCalled, object: nil)
        nc.addObserver(self, selector: #selector(getThePhotos(notification:)), name: .fireJournalCameraPhotoSaved, object: nil)
        
         setUpNavigationButton()
        
        getTheTags()
        
        
        if id != nil {
            getUserLocation.determineLocation()
            buildTheJournal()
            configureJournalTableView()
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
    
    @objc func photoErrorAlert(notification: Notification) {
        if let userInfo = notification.userInfo as! [String: Any]? {
            if let errorMessage = userInfo["errorMessage"] as? String {
                errorAlert(errorMessage: errorMessage)
            }
        }
    }
    
    func setUpNavigationButton() {
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedJournal(_:)))
        
        navigationItem.rightBarButtonItem = saveButton
        
        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Journal", style: .plain, target: self, action: #selector(returnToList(_:)))
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
        
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.barTintColor = UIColor(named: "FJBlueColor")
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
            navigationBarAppearace.isTranslucent = false
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
    }
    
    @objc func getThePhotos(notification: Notification)  {
        guard let attachments = self.theJournal.photo?.allObjects as? [Photo] else { return }
        self.validPhotos.removeAll()
        self.validPhotos = attachments.filter { return !($0.imageData == nil) }
        self.validPhotos = self.validPhotos.sorted(by: { $0.photoDate! < $1.photoDate! })
        self.journalTableView.reloadRows(at: [IndexPath.init(row: 8, section: 0)], with: .automatic)
        print("this is for the save!!!!")
    }
    
    @objc func savedJournal(_ sender: Any) {
        do {
            try context.save()
            if !self.validPhotos.isEmpty {
                if self.theJournal.photo != nil {
                    self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                    self.photoProvider.saveImageDataiIfNeeded(for: self.theJournal.photo!, taskContext: self.taskContext)  {
                        print("we saved it all")
                    }
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated jurnal merge that"])
            }
            let objectID = theJournal.objectID
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue :FJkCKModifyJournalToCloud),
                             object: nil,
                             userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            
            DispatchQueue.main.async {
                let objectID = self.theJournalLocation.objectID
                    self.nc.post(name: .fireJournalModifyFCLocationToCloud, object: nil, userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            
            theAlert(message: "The journal data has been saved.")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "Journal saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    func saveJournal(_ sender:Any, completionBlock: () -> ()) {
        do {
            try context.save()
            if !self.validPhotos.isEmpty {
                DispatchQueue.global(qos: .background).async {
                    self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                    self.photoProvider.saveImageDataiIfNeeded(for: self.theJournal.photo!, taskContext: self.taskContext)  {
                        DispatchQueue.main.async {
                            self.nc.post(name: .fireJournalCameraPhotoSaved, object: nil)
                        }
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
    
    @objc private func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: FJkJOURNALLISTSEGUE ),
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
            case .compact: break
            case .regular: break
            }
        }
    }
    
    func buildTheJournal() {
        
        theJournal = context.object(with: id) as? Journal
        if theJournal != nil {
            if theJournal.fireJournalUserInfo != nil {
                theUser = theJournal.fireJournalUserInfo
            } else {
                getTheUser()
            }
            getTheLastUserTime()
            if theJournal.theLocation != nil {
                theJournalLocation = theJournal.theLocation
                if theJournalLocation.journalGuid == nil {
                    if let guid = theJournal.fjpJGuidForReference {
                        theJournalLocation.journalGuid = guid
                    }
                }
            } else {
                theJournalLocation = FCLocation(context: context)
                theJournalLocation.guid = UUID.init()
                theJournalLocation.modDate = theJournal.journalCreationDate
                if let guid = theJournal.fjpJGuidForReference {
                    theJournalLocation.journalGuid = guid
                }
                theJournal.theLocation = theJournalLocation
            }
            
            
            if theJournal.journalTagDetails != nil {
                theJournalTags = theJournal.journalTags?.allObjects as! [JournalTags]
                theTagsAvailable = true
                theJournalTags = theJournalTags.sorted { $0.journalTag! < $1.journalTag! }
                let count = theJournalTags.count
                let counted = count / 6
                theTagsHeight = CGFloat(counted * 44)
                if theTagsHeight < 100 {
                    theTagsHeight = 88
                }
            }
            
            if let overview = theJournal.journalOverviewSC as? String {
                theOverviewNotes = overview
                theOverviewNotesAvailable = true
                theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            }
            
            if let summary = theJournal.journalSummarySC as? String {
                theSummaryNotes = summary
                theSummaryNotesAvailable = true
                theSummaryNotesHeight = configureLabelHeight(text: theSummaryNotes)
            }
            
            if theJournal.journalGuid == nil {
                theJournal.journalGuid = UUID()
            }
            
            guard let attachments = self.theJournal.photo?.allObjects as? [Photo] else { return }
            self.validPhotos.removeAll()
            self.validPhotos = attachments.filter { return !($0.imageData == nil) }
            self.validPhotos = self.validPhotos.sorted(by: { $0.photoDate! < $1.photoDate! })
            if !self.validPhotos.isEmpty {
                self.photosAvailable = true
            }
        
        }
    }
    
        /// creates a spinner view to hold the scene while data is downloaded from cloudkit
        /// posts to master to lock all the buttons down
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
            // add the spinner view controller
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                object: nil,
                userInfo: nil)
    }
    
        /// observer on FJkLocationsAllUpdatedToSC
        /// - Parameter ns: no user info
    func removeSpinnerUpdate() {
        if childAdded {
            DispatchQueue.main.async {
                    // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
                self.nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                             object: nil,
                             userInfo: nil)
                self.nc.post(name:Notification.Name(rawValue: FJkLETSCHECKTHEVERSION),
                             object: nil,
                             userInfo: nil)
            }
            childAdded = false
        }
    }

}
