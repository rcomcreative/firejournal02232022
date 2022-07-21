//
//  IncidentNewModalVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol IncidentNewModalVCDelegate: AnyObject {
    func incidentNewCancelled()
    func incidentNewSaved(objectID: NSManagedObjectID)
}

class IncidentNewModalVC: UIViewController {
    
    lazy var getUserLocation: GetTheUserLocation = { return GetTheUserLocation.init() }()
    var theUserRegion: MKCoordinateRegion?
    
    lazy var userTimeProvider: UserTimeProvider = {
        let provider = UserTimeProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var userTimeContext: NSManagedObjectContext!
    var userTimeObjectID: NSManagedObjectID!
    
    lazy var theUserProvider: FireJournalUserProvider = {
        let provider = FireJournalUserProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theUserContext: NSManagedObjectContext!
    
    weak var delegate: IncidentNewModalVCDelegate? = nil
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var theUserTime: UserTime!
    var theUser: FireJournalUser!
    var theIncident: Incident!
    var theIncidentLocation: FCLocation!
    var theIncidentTime: IncidentTimer!
    var theIncidentAddress: IncidentAddress!
    var theIncidentLocal: IncidentLocal!
    var theIncidentNFIRS: IncidentNFIRS!
    var theIncidentNotes: IncidentNotes!
    var theIncidentTags: IncidentTags!
    var theActionsTaken: ActionsTaken!
    var theIncidentNFIRSCompleteMods: IncidentNFIRSCompleteMods!
    var theIncidentNFIRSKSec: IncidentNFIRSKSec!
    var theIncidentNFIRSRequiredModules: IncidentNFIRSRequiredModules!
    var theIncidentNFIRSsecL: IncidentNFIRSsecL!
    var theIncidentNFIRSsecM: IncidentNFIRSsecM!
    var thePhoto: Photo!
    var theJournal: Journal!
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New Incident
"""
    var incidentModalHeaderV: ModalHeaderSaveDismiss!
    var incidentTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .fire

    override func viewDidLoad() {
        super.viewDidLoad()
        
        vcLaunch.splitVC = self.splitViewController
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        nc.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        if let obj = userTimeObjectID {
            theUserTime = context.object(with: obj) as? UserTime
        }
        if theUserTime == nil {
            dismiss(animated: true)
        }
        
        getTheUser()
        if theUser == nil {
            dismiss(animated: true, completion: nil)
        }
        
        roundViews()
        getUserLocation.determineLocation()
        buildTheIncident()
        configureModalHeaderSaveDismiss()
        configureIncidentTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if getUserLocation.currentLocation == nil {
            getUserLocation.determineLocation()
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            incidentTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        incidentTableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
        // MARK: -context notification
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func buildTheIncident() {
        
        theIncident = Incident(context: context)
        let incidentModDate = Date()
        let iGuidDate = GuidFormatter.init(date:incidentModDate)
        let searchDate = FormattedDate.init(date:incidentModDate)
        let sDate:String = searchDate.formatTheDateAndTime()
        let jGuid:String = iGuidDate.formatGuid()
        theIncident.fjpIncGuidForReference = "02."+jGuid
        theIncident.incidentSearchDate = sDate
        theIncident.incidentDateSearch = sDate
        theIncident.incidentModDate = incidentModDate
        theIncident.incidentCreationDate = incidentModDate
        theIncident.situationIncidentImage = "Fire"
        theIncident.incidentGuid = UUID()
        theIncident.incidentType = "Emergency"
        theUserTime.addToIncident(theIncident)
        theUser.addToFireJournalUserIncDetails(theIncident)
        theIncident.locationAvailable = false
        theIncident.incidentPhotoTaken = false
        theIncident.incidentTagsAvailable = false
        
        theIncidentLocation = FCLocation(context: context)
        theIncidentLocation.guid = UUID()
        theIncidentLocation.modDate = incidentModDate
        theIncidentLocation.incidentGuid = theIncident.fjpIncGuidForReference
        theIncidentLocation.incident = theIncident
        
        theIncidentTime = IncidentTimer(context: context)
        theIncidentTime.incidentTimerInfo = theIncident
        
        
        theIncidentLocal = IncidentLocal(context: context)
        theIncidentLocal.incidentLocalInfo = theIncident
        
        theIncidentNFIRS = IncidentNFIRS(context: context)
        theIncidentNFIRS.incidentNFIRSInfo = theIncident
        
        theIncidentNotes = IncidentNotes(context: context)
        theIncidentNotes.incidentNotesInfo = theIncident
        
        theIncidentTags = IncidentTags(context: context)
        theIncidentTags.addToIncidentTagInfo(theIncident)
        
        theActionsTaken = ActionsTaken(context: context)
        theActionsTaken.actionsTakenInfo = theIncident
        
        theIncidentNFIRSCompleteMods = IncidentNFIRSCompleteMods(context: context)
        theIncidentNFIRSCompleteMods.addToCompletedModuleInfo(theIncident)
        
        theIncidentNFIRSKSec = IncidentNFIRSKSec(context: context)
        theIncidentNFIRSKSec.incidentNFIRSKSecInto = theIncident
        
        theIncidentNFIRSRequiredModules = IncidentNFIRSRequiredModules(context: context)
        theIncidentNFIRSRequiredModules.addToRequiredModuleInfo(theIncident)
        
        theIncidentNFIRSsecL = IncidentNFIRSsecL(context: context)
        theIncidentNFIRSsecL.sectionLInfo = theIncident
        
        theIncidentNFIRSsecM = IncidentNFIRSsecM(context: context)
        theIncidentNFIRSsecM.sectionMInfo = theIncident
        
    }

}

extension IncidentNewModalVC {
    
    func configureModalHeaderSaveDismiss() {
        incidentModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        incidentModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(incidentModalHeaderV)
        incidentModalHeaderV.modalHTitleL.textColor = UIColor.white
        incidentModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        incidentModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        incidentModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        incidentModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        incidentModalHeaderV.modalHTitleL.text = headerTitle
        incidentModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            incidentModalHeaderV.contentView.backgroundColor = color
        }
        incidentModalHeaderV.myShift = MenuItems.incidents
        incidentModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            incidentModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            incidentModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            incidentModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            incidentModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureIncidentTableView() {
        incidentTableView = UITableView(frame: .zero)
        registerCellsForTable()
        incidentTableView.translatesAutoresizingMaskIntoConstraints = false
        incidentTableView.backgroundColor = .systemBackground
        view.addSubview(incidentTableView)
        incidentTableView.delegate = self
        incidentTableView.dataSource = self
        incidentTableView.separatorStyle = .none
        
        incidentTableView.rowHeight = UITableView.automaticDimension
        incidentTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            incidentTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            incidentTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            incidentTableView.topAnchor.constraint(equalTo: incidentModalHeaderV.bottomAnchor, constant: 5),
            incidentTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
    
    
    func getTheUser() {
        theUserContext = theUserProvider.persistentContainer.newBackgroundContext()
        guard let users = theUserProvider.getTheUser(theUserContext) else {
            let errorMessage = "There is no user associated with this end shift"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let aUser = users.last
        if let id = aUser?.objectID {
            theUser = context.object(with: id) as? FireJournalUser
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
    
    
    
    func presentAlert() {
        let title: InfoBodyText = .newIncidentSubject
        let message: InfoBodyText = .newIncident
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
    
    
}
