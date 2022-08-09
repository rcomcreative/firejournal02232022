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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        signatureImage = nil
        
        grabTheManagedObjects()
        
        buildNavigation()
        
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
    
    func saveToCD() {
        
    }
    
}
