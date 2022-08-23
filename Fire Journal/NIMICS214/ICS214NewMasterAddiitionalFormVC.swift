//
//  ICS214NewMasterAddiitionalFormVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/3/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MapKit
import CoreLocation

protocol ICS214NewMasterAddiitionalFormVCDelegate: AnyObject {
    func newMasterAdditionalFormCanceled()
    func newMasterAdditionalFormSaved(_ newICS214FormOID: NSManagedObjectID)
}

class ICS214NewMasterAddiitionalFormVC: UIViewController {

    weak var delegate: ICS214NewMasterAddiitionalFormVCDelegate? = nil
    
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
    var theIncidents = [Incident]()
    var theIncident: Incident!
    var theIncidentNotes: IncidentNotes!
    
    let dateFormatter = DateFormatter()
    
    var theICS214Location: FCLocation!
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
    var theICS214ActivityLog: ICS214ActivityLog!
    var theICS214Personnel: ICS214Personnel!
    
    var theTypeOfForm: TypeOfForm = TypeOfForm.incidentForm
    var type: TypeOfForm = TypeOfForm.incidentForm {
        didSet {
            self.theTypeOfForm = self.type
        }
    }
    
    var fetched = [ICS214Form]()
    
    var masterOrNot: Bool = false
    var theMasterGuid: String = ""

    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New ICS214
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
    var ics214NewVC: ICS214NewVC!
    var ics214NewIncidentVC: ICS214NewIncidentVC!
    var ics214NewFSOVC: ICS214NewFSOVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        
        addObservers()
        getTheLastMaster()
        _ = buildCellParts()
        
        configureModalHeaderSaveDismiss()
        configureics214TableView()
        
        
        
    }
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
//    MARK: -HIDE KEYBOARD-
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
    
    func errorAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    

}
