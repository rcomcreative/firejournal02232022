//
//  ViewController.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 8/19/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol ARC_ViewControllerDelegate: AnyObject {
    func singleBTapped()
    func noCampaignSendSingle(single: String)
}

class ARC_ViewController: UIViewController {
    
    //    MARK: -Objects-
    @IBOutlet weak var logoIV: UIImageView!
    @IBOutlet weak var campaignB: UIButton!
    @IBOutlet weak var singleB: UIButton!
    @IBOutlet weak var listB: UIButton!
    @IBOutlet weak var mapB: UIButton!
    @IBOutlet weak var termsB: UIButton!
    
    //    MARK: -PROPERTIES-
    weak var delegate: ARC_ViewControllerDelegate? = nil
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var segue: String = ""
    let userDefaults = UserDefaults.standard
    var isOnboard: Bool = false
    let nc = NotificationCenter.default
    var objectID: NSManagedObjectID!
    var alertUp: Bool = false
    var networkAlert: NetworkAlert!
    var cloudKitAlert: CloudKitAlert!
    var userName: String = ""
    var userEmail: String = ""
    var lockDown: Bool = false
    var dataDownloaded: Bool = false
    var userSkipped: Bool = false
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let cloud = (UIApplication.shared.delegate as! AppDelegate).cloud
    var child: SpinnerViewController!
    var childAdded: Bool = false
    var singleOrCampaign: String = "Single"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloud.context = context
        dataDownloaded = userDefaults.bool(forKey: FJkFireJournalDataDownloaded)
        userSkipped = userDefaults.bool(forKey: FJkUSERSKIPPEDSIGNIN)
        networkAlert = NetworkAlert.init(name: "Internet Activity")
        cloudKitAlert = CloudKitAlert.init(name: "Your Fire Journal Data")
        nc.addObserver(self, selector:#selector(getTheForm(notification:)),name:NSNotification.Name(rawValue: FJkNEWFormCreated ), object: nil)
        nc.addObserver(self, selector:#selector(noConnectionCalled(ns:)),name:NSNotification.Name(rawValue: kHAVENO_CONNECTIONALERT), object: nil)
        nc.addObserver(self, selector:#selector(alertDown(ns:)),name:NSNotification.Name(rawValue: FJkAlertISReleased), object: nil)
        nc.addObserver(self, selector:#selector(releaseOnboard(ns:)),name:NSNotification.Name(rawValue: FJkReleaseOnboard), object: nil)
        nc.addObserver(self, selector:#selector(nameAndEmailRetrieved(ns:)),name:NSNotification.Name(rawValue: FJkFJUSERSEmailWasAvailable), object: nil)
        nc.addObserver(self, selector:#selector(dontUseCloudKitAccount(ns:)),name:NSNotification.Name(rawValue: FJkNOUseCloudData), object: nil)
        nc.addObserver(self, selector:#selector(useCloudKitAccount(ns:)),name:NSNotification.Name(rawValue: FJkYESUseCloudData), object: nil)
        nc.addObserver(self, selector:#selector(dropTheSpinner(nc:)),name:NSNotification.Name(rawValue: FJkDROPTHESPINNER), object: nil)
        if dataDownloaded {
            //            TODO: load up count of incomplete forms there are and how many complete forms there are
        } else {
            //            if userSkipped {
            //                userDefaults.set(false, forKey: FJkFirstRun )
            //                userDefaults.synchronize()
            //            } else {
            //                downloadUsersData()
            //            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        //        if !isOnboard {
        //            segue = "OnboardSegue"
        //            performSegue(withIdentifier: segue, sender: self)
        //            userDefaults.set(true, forKey: FJkOnBoardHasShown)
        //        }
    }
    
    override func viewDidLayoutSubviews() {
//        logoIV.layer.cornerRadius = 8
//        logoIV.clipsToBounds = true
        campaignB.layer.cornerRadius = 8
        campaignB.clipsToBounds = true
        singleB.layer.cornerRadius = 8
        singleB.clipsToBounds = true
//        listB.layer.cornerRadius = 8
//        listB.clipsToBounds = true
//        mapB.layer.cornerRadius = 8
//        mapB.clipsToBounds = true
    }
    
    func downloadUsersData() {
        if !alertUp {
            let downloaded = userDefaults.bool(forKey: FJkFireJournalDataDownloaded)
            if !downloaded {
                let title = FJkCloudDataSubject
                let message = FJkCloudData
                let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                    self.alertUp = false
                    self.createSpinnerView()
                    
                    //                    FJkLOCKMASTERDOWNFORDOWNLOAD
                })
                alert.addAction(okAction)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func createSpinnerView() {
        child = SpinnerViewController()
        childAdded = true
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        nc.post(name:Notification.Name(rawValue: FJkLOCKMASTERDOWNFORDOWNLOAD),
                object: nil,
                userInfo: nil)
    }
    
    @objc func dropTheSpinner(nc: Notification) {
        if childAdded {
            DispatchQueue.main.async {
                // then remove the spinner view controller
                self.child.willMove(toParent: nil)
                self.child.view.removeFromSuperview()
                self.child.removeFromParent()
            }
            childAdded = false
        }
        if !alertUp {
            let title = FJkCloudDataSubject2
            let message = FJkCloudData2
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func nameAndEmailRetrieved(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]? {
            userName = userInfo["name"] as? String ?? ""
            userEmail = userInfo["email"] as? String ?? ""
            if !alertUp {
                let alert = cloudKitAlert.fireJournalCloudKitAvailable(email: userEmail, name: userName)
                alertUp = true
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func useCloudKitAccount(ns: Notification ) {
        userDefaults.set(true, forKey:  FJkYESUseCloudData)
        userDefaults.synchronize()
        DispatchQueue.main.async {
            self.nc.post(name: NSNotification.Name(rawValue: FJkGetTheDataFromCloudKit), object: nil, userInfo:["errorMessage":""])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dontUseCloudKitAccount(ns: Notification ) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func releaseOnboard(ns: Notification) {
        userSkipped = userDefaults.bool(forKey: FJkUSERSKIPPEDSIGNIN)
        self.dismiss(animated: true, completion: {
            if self.userSkipped {
                self.userDefaults.set(false, forKey: FJkFirstRun )
            } else {
                self.downloadUsersData()
            }
        })
    }
    
    @objc func noConnectionCalled(ns: Notification) {
        if !alertUp {
            let alert = networkAlert.networkUnavailable()
            alertUp = true
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func alertDown(ns: Notification) {
        alertUp = false
    }
    
    @objc func getTheForm(notification: Notification) {
        self.dismiss(animated: true, completion: {
            if let userInfo = notification.userInfo as! [String: Any]? {
                self.objectID = userInfo["objectID"] as? NSManagedObjectID
                DispatchQueue.main.async {
                    self.nc.post(name: NSNotification.Name(rawValue: FJkNEWARCFORMCAMPAIGNCREATED), object: nil, userInfo:["object":self.objectID as Any])
                }
            }
            self.singleOrCampaign = "Campaign"
            self.singleBTapped(self)
        })
    }
    
    @IBAction func campaignBTapped(_ sender: Any) {
        print("campaignTapped")
//        segue = "CampaignSegue"
//        performSegue(withIdentifier: segue, sender: self)
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Campaign", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "CampaignTVC") as! CampaignTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
//        dataTVC.titleName = "Campaign"
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
    
    @IBAction func singleBTapped(_ sender: Any) {
        print("singleTapped")
        if singleOrCampaign == "Campaign" {
            delegate?.singleBTapped()
        } else if singleOrCampaign == "Single" {
            delegate?.noCampaignSendSingle(single: "Single")
        }
    }
    
//    // MARK: - Segues
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "CampaignSegue" {
//            let campaignTVC = segue.destination as! CampaignTVC
//            campaignTVC.delegate = self
//        } else if segue.identifier == "FormSegue" {
//            let formTVC = segue.destination as! ARC_FormTVC
//            formTVC.campaign = false
//            formTVC.delegate = self
//            if let object = objectID {
//                formTVC.objectID = object
//            }
//            objectID = nil
//        }
//    }
    
    
    
}

extension ARC_ViewController: ARC_FormDelegate {
    func theFormWantsNewForm() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theFormHasCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theFormHasBeenSaved() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ARC_ViewController: CampaignDelegate {
    func theCampaignHasBegun() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
