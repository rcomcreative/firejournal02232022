//
//  RelieveSupervisorVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/16/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol RelieveSupervisorVCDelegate: AnyObject {
    func relieveSupervisorCancel()
    func relieveSupervisorChosen(relieveSupervisor: [UserAttendees], relieveOrSupervisor: Bool)
}

class RelieveSupervisorVC: UIViewController {
    
    var headerTitle: String = ""
    var relieveSupervisorHeaderV: RelieveSupervisorHeaderV!
    var relieveSupervisorTableView: UITableView!
    
    weak var delegate: RelieveSupervisorVCDelegate? = nil
    
    var type: MenuItems!
    
    let nc = NotificationCenter.default
    let userDefaults = UserDefaults.standard
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let device = (UIApplication.shared.delegate as? AppDelegate)?.device
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var alertUp: Bool = false
    var relievingOrSupervisor: Bool = false
    var menuType: MenuItems!
    var newOfficer: UserAttendees!
    var relieveSupervisorContactsTVC: RelieveSupervisorContactsTVC!
    var staffContactsVC: StaffContactsVC!
    var crew: Bool = false
    
    var imageAvailable: Bool = false
    var contactImage: UIImage!
    var validPhotos = [Photo]()
    var supervisor: Bool = true
    var attendees = [UserAttendees]()
    var cleanedAttendees = [UserAttendees]()
    
    var fetchedResultsController: NSFetchedResultsController<UserAttendees>? = nil
    var _fetchedResultsController: NSFetchedResultsController<UserAttendees> {
        if fetchedResultsController != nil {
            fetchedResultsController?.delegate = self
            return fetchedResultsController!
        }
        return fetchedResultsController!
    }
    
    var fetchedObjects: [UserAttendees] {
        return fetchedResultsController?.fetchedObjects ?? []
    }
    
    lazy var photoProvider: PhotoProvider = {
        let provider = PhotoProvider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var taskContext: NSManagedObjectContext!
    
    var selected = [UserAttendees]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        
        roundViews()
        _ = getAllAttendees(supervisor: supervisor)
        if !supervisor {
            for attendee in fetchedObjects {
                let result = cleanedAttendees.filter { $0.attendee == attendee.attendee }
                if result.isEmpty {
                    cleanedAttendees.append(attendee)
                }
            }
        }
        
        configureRelieveSupervisorHeaderV()
        configureRelieveSupervisorTableView()
    }
    
    func roundViews() {
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
    }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
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
        let title: InfoBodyText = .relievingSupportNotesSubject
        let message: InfoBodyText = .relievingSupportNotes
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }

}
