    //
    //  ICS214FormDetailVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/9/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation
import Contacts
import ContactsUI
import T1Autograph

protocol ICS214FormDetailVCDelegate: AnyObject {
    func cancelICS214FormDetail()
}

class ICS214FormDetailVC: SpinnerViewController, UINavigationControllerDelegate {
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    weak var delegate: ICS214FormDetailVCDelegate? = nil
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var autograph: T1Autograph = T1Autograph()
    var signatureImage:UIImage!
    let userDefaults = UserDefaults.standard
    let nc = NotificationCenter.default
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var theUserTimeOID: NSManagedObjectID!
    var theUserTime: UserTime!
    
    var theUserOID: NSManagedObjectID!
    var theUser: FireJournalUser!
    
    lazy var theIncidentProvider: IncidentProvider = {
        let provider = IncidentProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theIncidentContext: NSManagedObjectContext!
    var theIncidentOID: NSManagedObjectID!
    var theIncident: Incident!
    var theIncidentNotes: IncidentNotes!
    var theIncidentLocation: FCLocation!
    
    let dateFormatter = DateFormatter()
    
    lazy var theJournalProvider: JournalProvider = {
        let provider = JournalProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theJournalContext: NSManagedObjectContext!
    var theJournalLocation: FCLocation!
    var theJournal: Journal!
    var theJournalOID: NSManagedObjectID!
    
    lazy var theICS214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICS214ProviderContext: NSManagedObjectContext!
    
    var theICS214Form: ICS214Form!
    var theICS214FormOID: NSManagedObjectID!
    var theMasterICS214Form: ICS214Form!
    var theMasterICS214FormOID: NSManagedObjectID!
    var theICS214ActivityLog =  [ICS214ActivityLog]()
    var theICS214Personnel = [ICS214Personnel]()
    var theICS214Location: FCLocation!
    
    var ics214ToCloud: ICS214ToCloud!
    
    var attendeeHeight: CGFloat = 0
    var attendeesAvailable: Bool = false
    var activityHeight: CGFloat = 0
    var activityAvailable: Bool = false
    var signatureAvailable: Bool = false
    
    var personnelTVC: NewICS214ResourcesAssignedTVC!
    var ics214ActivityLogVC: ICS214ActivityLogVC!
    
    lazy var theUserAttendeeProvider: UserAttendeesProvider = {
        let provider = UserAttendeesProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserAttendeeContext: NSManagedObjectContext!
    
    var thePersonnel = [UserAttendees]()
    
    var theTypeOfForm: TypeOfForm = TypeOfForm.incidentForm
    var type: TypeOfForm = TypeOfForm.incidentForm {
        didSet {
            self.theTypeOfForm = self.type
        }
    }
    
    var masterOrNot: Bool = false
    var theMasterGuid: String = ""
    
   let vcLaunch = VCLaunch()
   var launchNC: LaunchNotifications!
    
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
NIMS ICS 214
"""
    var ics214ModalHeaderV: ModalHeaderSaveDismiss!
    var ics214TableView: UITableView!
    var sections: NewMasterSections = NewMasterSections.section1
    var formMaster: String = ""
    var modalCells = [CellParts]()
    var p0, p1, p2, p3, p4: CellParts!
    var dataRetrieved: Bool = false
    var showIncidents: Bool = false
    var showMasters: Bool = false
    
    let calendar = Calendar.init(identifier: .gregorian)
    var imageName: String = ""
    var fromMap: Bool = false
    var saveButton: UIBarButtonItem!
    var pdfLink: String = ""
    var editVC: NewICS214AssignedResourceEditVC!
    var editHeaderVC: ICS214EditHeaderVC!
    
    var subscriptionBought: Bool = false
    
    var child: SpinnerViewController!
    var childAdded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        signatureImage = nil
        
        grabTheManagedObjects()
        
        buildAddObservers()
        
        buildNavigation()
        
        subscriptionBought = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        
        getUserLocation.determineLocation()
        configureics214TableView()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
        //    MARK: -RETURN TO THE LIST
    @objc func returnToList(_ sender:Any) {
        closeItUp()
    }
    
    func closeItUp() {
        if  Device.IS_IPHONE {
            DispatchQueue.main.async {
                self.nc.post(name:Notification.Name(rawValue: "FJkICS214FORMLISTCALLED"),
                             object: nil,
                             userInfo: nil)
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            ics214TableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        ics214TableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
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
    
    func presentAlert() {
        let title: InfoBodyText = .newICS214FormSubject
        let message: InfoBodyText = .newICS214FormDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.createSpinnerView()
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
    
    func shareAlert() {
        let message: String = InfoBodyText.ics214ShareSupportNotes.rawValue
        let title: String = InfoBodyText.ics214ShareSupportSubject.rawValue
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                alert.dismiss(animated: true, completion: nil)
                self.alertUp = false
            })
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func infoAlert() {
        let theSubject: String = InfoBodyText.ics214SupportSubject.rawValue
        let theMessage: String = InfoBodyText.ics214SupportNotes.rawValue
        let alert = UIAlertController.init(title: theSubject, message: theMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Got it!", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
//    MARK: -SPINNER VIEW CONTROLLER-
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
    @objc func removeSpinnerUpdate(ns: Notification) {
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
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
        //    MARK: -SAVE METHODS-
    @objc func saveICS214(_ sender:Any) {
        theICS214Form.ics214ModDate = Date()
        theICS214Form.ics214BackedUp = false
        saveToCD()
    }
    
    @objc func saveICS214Attendees(_ sender:Any) {
        theICS214Form.ics214ModDate = Date()
        theICS214Form.ics214BackedUp = false
        saveToCD()
    }
    
    func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID": self.theICS214FormOID as Any])
                
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
}
