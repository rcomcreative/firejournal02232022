//
//  NewPromotionVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/20/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

protocol NewPromotionVCDelegate: AnyObject {
    func newPromotionCanceled()
    func newPromotionCreated(objectID: NSManagedObjectID)
}

class NewPromotionVC: UIViewController {
    
    weak var delegate: NewPromotionVCDelegate? = nil
    
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
    var theJournalLocation: FCLocation!
    var thePhoto: Photo!
    var thePromotion: PromotionJournal!
    var utGuid: String = ""
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
New Project
"""
    var promotionModalHeaderV: ModalHeaderSaveDismiss!
    var promotionTableView: UITableView!
    var yesNo: Bool = false
    var segmentType: MenuItems = .station
    
    var theOverviewNotes: String = " "
    var theOverviewNotesAvailable: Bool = false
    var theOverviewNotesHeight: CGFloat = 0


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
            delegate?.newPromotionCanceled()
        }
        
        getTheUser()
        if theUser == nil {
            delegate?.newPromotionCanceled()
        }
        
        roundViews()
        getUserLocation.determineLocation()
        buildTheProject()
        configurePromotionModalHeaderV()
        configurePromotionTableView()
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
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            print("Notification: Keyboard will show")
            promotionTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        promotionTableView.setBottomInset(to: 0.0)
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
        let title: InfoBodyText = .newProjectSubject
        let message: InfoBodyText = .newProjectDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Got it!", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func buildTheProject() {
        thePromotion = PromotionJournal(context: context)
        let promotionDate = Date()
        thePromotion.guid = UUID.init()
        thePromotion.promotionDate = promotionDate
        let jGuidDate = GuidFormatter.init(date: promotionDate)
        let jGuid:String = jGuidDate.formatGuid()
        thePromotion.projectGuid = "99."+jGuid
        if theUser != nil {
            thePromotion.user = theUser
        }
        if theUserTime != nil {
            thePromotion.shift = theUserTime
        }
        thePromotion.locationAvailable = false
        thePromotion.projectTagsAvailable = false
        thePromotion.projectPhotosAvailable = false
    }

}
