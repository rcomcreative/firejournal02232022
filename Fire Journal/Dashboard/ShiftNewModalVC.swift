    //
    //  ShiftNewModalVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/10/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol ShiftNewModalVCDelegate: AnyObject {
    func dismissShiftStartModal()
    func noUserFound()
    func shiftCancelled()
}

class ShiftNewModalVC: UIViewController {
    
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
    
    weak var delegate: ShiftNewModalVCDelegate? = nil
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!

    
    var theUserTime: UserTime!
    var theStatus: Status!
    var theStatusOID: NSManagedObjectID!
    var theUser: FireJournalUser!
    var theJournal: Journal!
    var utGuid: String = ""
    var relieveAvailable: Bool = false
    var superAvailable: Bool = false
    var discussionAvailable: Bool = false
    var discussionHeight: CGFloat = 0.0
    var discussionNote: String = ""
    
    var alertUp: Bool = false
    
    var shiftModalHeaderV: ShiftModalHeaderV!
    var shiftTableView: UITableView!
    
    var headerTitle: String = """
Start
Shift
"""
    
        //    MARK: -BOOL-
    var showPicker: Bool = false
    var updateCV: Bool = false
    var shiftAMorRelief = false
    var relieveOrSupervisor: String = ""
    var relievedByGuid: String = ""
    var userTimeObjID: NSManagedObjectID!
    
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
        
        if let sOID = theStatusOID {
            theStatus = context.object(with: sOID) as? Status
        }
        
        if let obj = userTimeObjID {
            theUserTime = context.object(with: obj) as? UserTime
        } else {
            getTheLastUserTime()
            if theUserTime == nil {
                dismiss(animated: true)
            }
        }
        
        getTheUser()
        if theUser == nil {
            delegate?.noUserFound()
        }
        
        roundViews()
        configureshiftModalHeaderV()
        configureshiftTableView()
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
    
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            shiftTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        shiftTableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension ShiftNewModalVC {
    
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
    
    func getTheLastUserTime() {
        userTimeContext = userTimeProvider.persistentContainer.newBackgroundContext()
        guard let userTime = userTimeProvider.getLastShiftNotCompleted(userTimeContext) else {
            let errorMessage = "A start shift is needed to retrieve the incidents of the day"
            errorAlert(errorMessage: errorMessage)
            return
        }
        let ut = userTime.last
        if let userTime = ut {
            let objectID = userTime.objectID
            theUserTime = context.object(with: objectID) as? UserTime
        }
    }
    
//    MARK: -CONFIGURATIONS
    func configureshiftModalHeaderV() {
        shiftModalHeaderV = Bundle.main.loadNibNamed("ShiftModalHeaderV", owner: self, options: nil)?.first as? ShiftModalHeaderV
        shiftModalHeaderV.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 120)
        shiftModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(shiftModalHeaderV)
        shiftModalHeaderV.aTitle = headerTitle
        shiftModalHeaderV.contentView.backgroundColor = .systemGray2
        shiftModalHeaderV.cancelB.setTitleColor(.black, for: .normal)
        shiftModalHeaderV.saveB.setTitleColor(.black, for: .normal)
        shiftModalHeaderV.delegate = self
        shiftModalHeaderV.infoB.tintColor = UIColor(named: "FJGreenColor")
        shiftModalHeaderV.backgroundIV.image = UIImage(named: "EDF0F6-D8E7FA_CellBkgrnd4sq")
        NSLayoutConstraint.activate([
            shiftModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            shiftModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            shiftModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            shiftModalHeaderV.heightAnchor.constraint(equalToConstant: 120),
        ])
    }
    
    func configureshiftTableView() {
        shiftTableView = UITableView(frame: .zero)
        registerCellsForTable()
        shiftTableView.translatesAutoresizingMaskIntoConstraints = false
        shiftTableView.backgroundColor = .systemBackground
        view.addSubview(shiftTableView)
        shiftTableView.delegate = self
        shiftTableView.dataSource = self
        shiftTableView.separatorStyle = .none
        shiftTableView.allowsSelection = true
        
        shiftTableView.rowHeight = UITableView.automaticDimension
        shiftTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            shiftTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            shiftTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            shiftTableView.topAnchor.constraint(equalTo: shiftModalHeaderV.bottomAnchor, constant: 5),
            shiftTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
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
        let message: InfoBodyText = .startShiftRecordedSubject
        let title: InfoBodyText = .startShiftRecorded
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}
