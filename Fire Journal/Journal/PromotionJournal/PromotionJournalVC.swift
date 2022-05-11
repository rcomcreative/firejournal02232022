//
//  PromotionJournalVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/19/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import PhotosUI

class PromotionJournalVC: SpinnerViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var theProject: PromotionJournal!
    var theLocation: FCLocation!
    var locationAvailable: Bool = false
    var theProjectTags = [PromotionJournalTags]()
    var thePhoto: Photo!
    var theTags = [Tag]()
    var validPhotos = [Photo]()
    var utGuid: String = ""
    var compact: SizeTrait = .regular
    
    var alertUp: Bool = false
    var projectTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .station
    var dateFormatter = DateFormatter()
    var typeNameA = ["ICONS_training"]
    
    var theOverviewNotes: String = " "
    var theOverviewNotesAvailable: Bool = false
    var theOverviewNotesHeight: CGFloat = 0
    
    var theProjectNotes: String = " "
    var theProjectNotesAvailable: Bool = false
    var theProjectNotesHeight: CGFloat = 0
    
    var theProjectCrew: String = ""
    var theProjectCrewAvailable: Bool = false
    var theProjectCrewA = [PromotionCrew]()
    var theProjectCrewNames = [String]()
    
    var theTagString: String = " "
    var theTagsAvailable: Bool = false
    var theTagsHeight: CGFloat = 0
    var thePromotionEditVC: PromotionEditVC!
    
    var projectImageName: String = "ICONS_training"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
            //        MARK: additional notifications
        nc.addObserver(self, selector: #selector(compactOrRegular(ns:)), name:NSNotification.Name(rawValue: FJkCOMPACTORREGULAR), object: nil)
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        nc.addObserver(self, selector: #selector(photoErrorAlert(notification:)), name: .fireJournalPhotoErrorCalled, object: nil)
        
        setUpNavigationButton()
        getTheTags()
        
        if id != nil {
            getUserLocation.determineLocation()
            buildTheProject()
            if theProject != nil {
                configureTheProjectTableView()
            }
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
    
    func setUpNavigationButton() {
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savedProject(_:)))
        
        navigationItem.rightBarButtonItem = saveButton
        
        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Projects", style: .plain, target: self, action: #selector(returnToList(_:)))
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
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
    }
    
    func buildTheProject() {
        
        theProject = context.object(with: id) as? PromotionJournal
        if theProject != nil {
            if theProject.user != nil {
                theUser = theProject.user
            }
            if theProject.shift != nil {
                theUserTime = theProject.shift
            }
            if theProject.theLocation != nil {
                theLocation = theProject.theLocation
                if let guid = theProject.projectGuid {
                    theLocation.promotionGuid = guid
                }
                locationAvailable = true
            } else {
                theLocation = FCLocation(context: context)
                theLocation.guid = UUID()
                if let guid = theProject.projectGuid {
                    theLocation.promotionGuid = guid
                }
                theProject.theLocation = theLocation
            }
            
            if theProject.tags != nil {
                theProjectTags = theProject.promotionTag?.allObjects as! [PromotionJournalTags]
                theTagsAvailable = true
                theProjectTags = theProjectTags.sorted { $0.tag! < $1.tag! }
                let count = theProjectTags.count
                let counted = count / 6
                theTagsHeight = CGFloat(counted * 44)
                if theTagsHeight < 100 {
                    theTagsHeight = 88
                }
            }
            
            if let overview = theProject.overview as? String {
                theOverviewNotes = overview
                theOverviewNotesAvailable = true
                theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            }
            
            if let projectNotes = theProject.studyClassNote as? String {
                theProjectNotes = projectNotes
                theProjectNotesAvailable = true
                theProjectNotesHeight = configureLabelHeight(text: theProjectNotes)
            }
            
            
            guard let attachments = self.theProject.photos?.allObjects as? [Photo] else { return }
            self.validPhotos.removeAll()
            self.validPhotos = attachments.filter { return !($0.imageData == nil) }
            self.validPhotos = self.validPhotos.sorted(by: { $0.photoDate! < $1.photoDate! })
            if !self.validPhotos.isEmpty {
                self.photosAvailable = true
            }
            
            if theProject.crew != nil {
                theProjectCrewAvailable = true
                theProjectCrew = ""
                if let theCrew = theProject.crew?.allObjects as? [PromotionCrew] {
                    for crew in theCrew {
                        var theName: String = ""
                        var theRank: String = ""
                        if let fullname = crew.fullName {
                            theName = fullname
                        }
                        if theName == "" {
                            if let first = crew.first {
                                theName = first
                            }
                            if let last = crew.last {
                                theName = theName + " " + last
                            }
                        }
                        if let rank = crew.rank {
                            theRank = rank
                        }
                        if theName != "" {
                            theProjectCrewNames.append(theName)
                        }
                        let result = theProjectCrewA.filter { $0 == crew }
                        if result.isEmpty {
                            theProjectCrewA.append(crew)
                        }
                    }
                    if !theProjectCrewA.isEmpty {
                        theProjectCrew = theProjectCrewNames.joined(separator: ", ")
                    }
                }
            }
            
        }
    }
    
    @objc func savedProject(_ sender: Any) {
        do {
            try context.save()
            if !self.validPhotos.isEmpty {
                DispatchQueue.global(qos: .background).async {
                    self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                    self.photoProvider.saveImageDataiIfNeeded(for: self.theProject.photos!, taskContext: self.taskContext)  {
                        DispatchQueue.main.async {
                            self.nc.post(name: .fireJournalCameraPhotoSaved, object: nil)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Updated project merge that"])
            }
            let objectID = theProject.objectID
            DispatchQueue.main.async {
                self.nc.post(name: .fireJournalProjectModifiedSendToCloud,
                             object: nil,
                             userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            
            DispatchQueue.main.async {
                let objectID = self.theLocation.objectID
                    self.nc.post(name: .fireJournalModifyFCLocationToCloud, object: nil, userInfo: ["objectID": objectID as NSManagedObjectID])
            }
            
            theAlert(message: "The projectl data has been saved.")
        } catch let error as NSError {
            let nserror = error
            
            let errorMessage = "Journal saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
            print(errorMessage)
        }
    }
    
    func savePromotion(_ sender: Any, completionBlock: () -> ()) {
        do {
            try context.save()
            if !self.validPhotos.isEmpty {
                DispatchQueue.global(qos: .background).async {
                    self.taskContext = self.photoProvider.persistentContainer.newBackgroundContext()
                    self.photoProvider.saveImageDataiIfNeeded(for: self.theProject.photos!, taskContext: self.taskContext)  {
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
                self.nc.post(name: .fireJournalProjectListCalled, object: nil, userInfo: nil)
            }
        }
    }
    
        //    MARK: -ALERTS-
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func theAlert(message: String) {
        let alert = UIAlertController.init(title: "Update", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert() {
        let message: InfoBodyText = .newIncidentSubject
        let title: InfoBodyText = .newIncident
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapAlert() {
        let subject = InfoBodyText.mapErrorSubject.rawValue
        let message = InfoBodyText.mapErrorDescription.rawValue
        let alert = UIAlertController.init(title: subject, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func photoErrorAlert(notification: Notification) {
        if let userInfo = notification.userInfo as! [String: Any]? {
            if let errorMessage = userInfo["errorMessage"] as? String {
                errorAlert(errorMessage: errorMessage)
            }
        }
    }

}
