//
//  VCLaunch.swift
//  dashboard
//
//  Created by DuRand Jones on 9/5/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class VCLaunch:  SettingsTVCDelegate,MapTVCDelegate,IncidentTVCDelegate,JournalTVCDelegate,NFIRSBasic1FormTVCDelegate,ICS214FormTVCDelegate,MapVCDelegate,ModalTVCDelegate,ListTVCDelegate,ICS214DetailViewControllerDelegate,SettingsProfileTVCDelegate,TheStoreDelegate,NewICS214ModalTVCDelegate,PersonalJournalDelegate {
    
    //    MARK: -PersonalJournalDelegate
    
    func thePersonalJournalEntrySaved(){}
    func thePersonalJournalCancel(){}
    
    //    MARK: -NewICS214ModalTVCDelegate
    func theCancelCalledOnNewICS214Modal() {
        //            //    MARK: -TODO-
    }
    
    //    TheStoreDelegate,
    
    //    MARK: -TheStoreDelegate
    func newSubscriptionPurchased() {}
    func closeTheStore() {}
    
    func incidentTappedForMap(objectID: NSManagedObjectID, compact: SizeTrait) {
        //            //    MARK: -TODO-
    }
    
    
    //    MARK: -SettingsProfileTVCDelegate-
    func profileReturnToSettings(compact:SizeTrait) {
        self.splitVC.dismiss(animated: true, completion: nil)
        self.splitVC.navigationController?.popToRootViewController(animated: true)
        if userID != nil {
            settingsCalled(sizeTrait:compact, objectID: userID)
        }
    }
    
    
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait){}
    
    func profileSavedNowGoToSettings(compact:SizeTrait) {
        if userID != nil {
            settingsCalled(sizeTrait:compact, objectID: userID)
        }
    }
    
    //    MARK: -SETTINGSTVCDELEGATE
    func settingsLoadPage(settings: FJSettings, userObjectID: NSManagedObjectID) {
        //            //    MARK: -TODO-
    }
    
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {
        //            //    MARK: -TODO-
    }
    
    //    MARK: -ICS214DetailViewControllerDelegate
    func completeChanged() {
        
    }
    //    Mark: -ARCFormDetailTVCDelegate
    func arcFormCancelled(){
        //
    }
    //    AppDelegate,
    func journalObjectChosen(type:MenuItems,id:NSManagedObjectID,compact:SizeTrait) {
        //            //    MARK: -TODO-
    }
    
    func menuWasTapped() {
        //            //    MARK: -TODO-
    }
    
    func presentNewIncidentModal()->NewerIncidentModalTVC {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let newIncidentTVC = storyBoard.instantiateViewController(withIdentifier: "NewerIncidentModalTVC") as! NewerIncidentModalTVC
        newIncidentTVC.transitioningDelegate = slideInTransitioningDelgate
        newIncidentTVC.modalPresentationStyle = .custom
        return newIncidentTVC
    }
    
    
    func presentModal(menuType: MenuItems, title: String) -> ModalTVC {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC = storyBoard.instantiateViewController(withIdentifier: "ModalTVC") as! ModalTVC
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        switch menuType {
        case .personal:
            let shift:MenuItems = .personal
            modalTVC.myShift = shift
        case .journal:
            let shift:MenuItems = .journal
            modalTVC.myShift = shift
        case .incidents:
            let shift:MenuItems = .incidents
            modalTVC.myShift = shift
        default:
            print("no data")
        }
        modalTVC.modalPresentationStyle = .custom
        return modalTVC
    }
    
    func presentSettingsModal(menuType: MenuItems, title: String) -> SettingsTheProfileTVC {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let modalTVC:SettingsTheProfileTVC = storyBoard.instantiateViewController(withIdentifier: "SettingsTheProfileTVC") as! SettingsTheProfileTVC
        modalTVC.transitioningDelegate = slideInTransitioningDelgate
        modalTVC.title = title
        modalTVC.modalPresentationStyle = .custom
        return modalTVC
    }
    
    func dismissTapped(shift: MenuItems) {
        //            //    MARK: -TODO-
    }
    
    
    func saveBTapped(shift: MenuItems) {
        //            //    MARK: -TODO-
    }
    func journalSaved(id:NSManagedObjectID,shift:MenuItems) {
    }
    
    func formTypedTapped(shift: MenuItems) {
        //            //    MARK: -TODO-
    }
    
    func theJournalWasTapped() {
        //            //    MARK: -TODO-
    }
    
    func mapTapped() {
        //            //    MARK: -TODO-
    }
    
    var theSizeTrait:SizeTrait!
    let nc = NotificationCenter.default
    //    MARK: - presentation Delegate
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    var alertI:Int = 0
    var userID: NSManagedObjectID!
    
    func journalSaveTapped() {
        //            //    MARK: -TODO-
    }
    
    
    func journalBackToList(){}
    
    func arcFormTapped() {
        //            //    MARK: -TODO-
    }
    
    func ics214Tapped() {
        //            //    MARK: -TODO-
    }
    
    func nfirsTapped() {
        //            //    MARK: -TODO-
    }
    
    func goBack() {
        //            //    MARK: -TODO-
    }
    
    func incidentTapped() {
        //            //    MARK: -TODO-
    }
    
    func maptapped() {
        //            //    MARK: -TODO-
    }
    
    var splitVC: UISplitViewController!
    
    func settingsTapped() {
        //
    }
    //    func profileCalled() {
    //
    //    }
    func storeTapped() {
        //        //    MARK: -TODO-
    }
    
    func timeStamp()->String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
        return dateFormatter.string(from: date)
    }
    
    func dateString()->String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func incidentFullDate(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MM/dd/YYYY HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func fullDateString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func monthString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: date)
    }
    
    func dayString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    func yearString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY"
        return dateFormatter.string(from: date)
    }
    
    func hourString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: date)
    }
    
    func minuteString(date:Date)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: date)
    }
    
    func timeStamp(date:Date,user:String)->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM dd,YYYY HH:mm:ss"
        let stringDate = dateFormatter.string(from: date)
        let fjuser = user
        return "Time Stamped: \(stringDate) By: \(fjuser)"
    }
    
    func threeComponentsDate(date: Date) -> [String] {
        var threeCountArray = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        threeCountArray.append(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "dd"
        threeCountArray.append(dateFormatter.string(from: date))
        dateFormatter.dateFormat = "YYYY"
        threeCountArray.append(dateFormatter.string(from: date))
        return threeCountArray
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        switch self.splitVC.displayMode {
        case .allVisible:
            theSizeTrait = .compact
            nc.post(name:Notification.Name(rawValue:"FJkCOMPACTORREGULAR"),
                    object: nil,
                    userInfo: ["compact":theSizeTrait!])
        case .primaryHidden:
            theSizeTrait = .regular
            nc.post(name:Notification.Name(rawValue:"FJkCOMPACTORREGULAR"),
                    object: nil,
                    userInfo: ["compact":theSizeTrait!])
        case .automatic:
            print("no trait")
        case .primaryOverlay:
            print("no trait")
        default: break
        }
    }
    
    func settingsCalled(sizeTrait: SizeTrait, objectID: NSManagedObjectID)->Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsTVC = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.delegate = self
        controller.myShift = .settings
        controller.titleName = "Settings"
        controller.userObjectID = objectID
//        let navigationBarAppearace = UINavigationBar.appearance()
//        if #available(iOS 13.0, *) {
//            navigationBarAppearace.barTintColor = UIColor.systemBackground
//            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
//            navigationBarAppearace.tintColor = .link
//        } else {
//            navigationBarAppearace.barTintColor = UIColor.black
//            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
//        }
        
        let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
        ]
        navigator.navigationItem.leftBarButtonItem?.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
        navigator.navigationItem.leftBarButtonItem?.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
        let navigationBarAppearace = UINavigationBar.appearance()
        if #available(iOS 13.0, *) {
            navigationBarAppearace.barTintColor = UIColor.systemBackground
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
            navigationBarAppearace.tintColor = .link
        } else {
            navigationBarAppearace.barTintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        self.splitVC?.show(navigator, sender:self)
    }
    
    func modalSettingsCalled() -> SettingsTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsTVC = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTVC
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.myShift = .settings
        controller.titleName = "Settings"
        return controller
    }
    
    func modalSettingsProfileCalled() -> SettingsTheProfileTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsTheProfileTVC = storyboard.instantiateViewController(withIdentifier:"SettingsTheProfileTVC") as! SettingsTheProfileTVC
        controller.transitioningDelegate = slideInTransitioningDelgate
        //        controller.delegate = self
        controller.titleName = "My Profile"
        return controller
    }
    
    func modalSettingsCloudCalled() -> SettingsInfoVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.settingsType = FJSettings.cloud
        return controller
    }
    
    func modalICS214NewCalled() ->NewICS214ModalTVC {
        let storyboard = UIStoryboard(name: "ICS214Form", bundle: nil)
        let controller:NewICS214ModalTVC = storyboard.instantiateViewController(withIdentifier: "NewICS214ModalTVC") as! NewICS214ModalTVC
        return controller
    }
    
    func modalARCFormNewCalled() ->ARC_ViewController {
        //        let storyboard = UIStoryboard(name: "ARCForm", bundle: nil)
        //        let controller: NewARCFormModalTVC = storyboard.instantiateViewController(withIdentifier: "NewARCFormModalTVC") as! NewARCFormModalTVC
        let storyboard = UIStoryboard(name: "ARCFormMain", bundle: nil)
        let controller: ARC_ViewController = storyboard.instantiateViewController(withIdentifier: "ARC_ViewController" ) as! ARC_ViewController
        return controller
    }
    
    func modalSettingsTermsCalled() -> SettingsInfoVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.settingsType = FJSettings.terms
        return controller
    }
    
    func modalSettingsPrivacyCalled() -> SettingsInfoVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.settingsType = FJSettings.privacy
        return controller
    }
    
    func modalSettingsCrewCalled() -> SettingsCrewTVC {
        
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsCrewTVC = storyboard.instantiateViewController(withIdentifier:"SettingsCrewTVC") as! SettingsCrewTVC
        controller.titleName = "Fire Journal Crew"
        controller.settingType = FJSettings.crewMembers
        return controller
    }
    
    func modalSettingsCrewToContactsCalled() ->SettingsContactsTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsContactsTVC = storyboard.instantiateViewController(withIdentifier:"SettingsContactsTVC") as! SettingsContactsTVC
        controller.titleName = "Fire Journal Contacts"
        controller.settingType = FJSettings.contacts
        controller.collapsed = true
        return controller
    }
    
    func modalSettingsMyFDResourcesCalled(setting: FJSettings) ->SettingsMyResourcesTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "SettingsMyResources", bundle: nil)
        let controller:SettingsMyResourcesTVC = storyboard.instantiateViewController(withIdentifier:"SettingsMyResourcesTVC") as! SettingsMyResourcesTVC
        controller.titleName = "My Fire Station Resources"
        controller.settingsType = FJSettings.fireStationResources
        return controller
    }
    
    func modalSettingsUserFDResourcesCalled(setting:FJSettings) -> SettingsUserFDResourcesTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsUserFDResourcesTVC = storyboard.instantiateViewController(withIdentifier:"SettingsUserFDResourcesTVC") as! SettingsUserFDResourcesTVC
        controller.titleName = "Fire/EMS Resources"
        controller.settingType = FJSettings.resources
        return controller
    }
    
    func modalSettingsDataCalled(settings:FJSettings) -> SettingsDataTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        switch settings {
        case .tags:
            controller.titleName = "Fire Journal Tags"
            controller.settingType = FJSettings.tags
        case .rank:
            controller.titleName = "Rank"
            controller.settingType = FJSettings.rank
        case .platoon:
            controller.titleName = "Platoon"
            controller.settingType = FJSettings.platoon
        case .resources:break
        case .streetTypes:
            controller.titleName = "NFIRS Street Types"
            controller.settingType = FJSettings.streetTypes
        case .localIncidentTypes:
            controller.titleName = "Local Incident Types"
            controller.settingType = FJSettings.localIncidentTypes
        default: break
        }
        return controller
    }
    
    
    func modalSettingsProfileDataCalled(settings:FJSettings) -> SettingsProfileDataTVC {
        slideInTransitioningDelgate.direction = .right
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsProfileDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsProfileDataTVC") as! SettingsProfileDataTVC
        switch settings {
        case .tags:
            controller.titleName = "Fire Journal Tags"
            controller.type = FJSettings.tags
        case .rank:
            controller.titleName = "Rank"
            controller.type = FJSettings.rank
        case .platoon:
            controller.titleName = "Platoon"
            controller.type = FJSettings.platoon
        case .resources:
            controller.titleName = "Resources"
            controller.type = FJSettings.resources
        case .streetTypes:
            controller.titleName = "NFIRS Street Types"
            controller.type = FJSettings.streetTypes
        case .localIncidentTypes:
            controller.titleName = "Local Incident Types"
            controller.type = FJSettings.localIncidentTypes
        case .assignment:
            controller.titleName = "Fire Journal Assignments"
            controller.type = FJSettings.assignment
        case .apparatus:
            controller.titleName = "Fire Journal Apparatus"
            controller.type = FJSettings.apparatus
        case .fdid:
            controller.titleName = "Fire Journal FDID"
            controller.type = FJSettings.fdid
        default: break
        }
        return controller
    }
    
    //    MARK: -IMPORTANT-
    //    MARK: -SWITCH FROM BETA TO STORE WHEN SENDING OUT-
    /// Either use the NewStoreBetaVC for Beta Testing - has monthly subscription
    /// or use the NewStoreVC for sending to AppStore for distribution
    func storeCalled()->Void {
        let storyboard = UIStoryboard(name: "TheStore", bundle: nil)
        //        let controller:NewStoreBetaVC = storyboard.instantiateViewController(withIdentifier: "NewStoreBetaVC") as! NewStoreBetaVC
        let controller: TheStoreVC = storyboard.instantiateViewController(withIdentifier: "TheStoreVC") as! TheStoreVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.delegate = self
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func mapCalled(type: IncidentTypes )->Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:MapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.delegate = self
        controller.myShift = .maps
        controller.titleName = "Maps"
        controller.incidentType = type
        self.splitVC?.showDetailViewController(navigator, sender:self)
        nc.post(name:Notification.Name(rawValue:"FJkMAPSLISTCALLED"),
                object: nil,
                userInfo: nil)
    }
    
    func mapCalledPhone(type: IncidentTypes)->Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:MapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.delegate = self
        controller.myShift = .maps
        controller.titleName = "Maps"
        controller.incidentType = type
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func mapCalledFromList(sizeTrait: SizeTrait)->Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:MapVC = storyboard.instantiateViewController(withIdentifier: "MapVC") as! MapVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.delegate = self
        controller.myShift = .maps
        controller.titleName = "Maps"
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func incidentCalled(sizeTrait: SizeTrait,id: NSManagedObjectID)->Void {
        if Device.IS_IPAD {
            let storyboard = UIStoryboard(name: "IncidentVC", bundle: nil)
            let controller:IncidentVC = storyboard.instantiateViewController(withIdentifier: "IncidentVC") as! IncidentVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.id = id
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
        nc.post(name:Notification.Name(rawValue:"FJkINCIDENTLISTCALLED"),
                object: nil,
                userInfo: nil)
    }
    
    func incidentCalledFromList(sizeTrait: SizeTrait,id:NSManagedObjectID)->Void {
        let storyboard = UIStoryboard(name: "IncidentVC", bundle: nil)
        let controller:IncidentVC = storyboard.instantiateViewController(withIdentifier: "IncidentVC") as! IncidentVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.id = id
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func journalCalled(sizeTrait: SizeTrait,id: NSManagedObjectID) -> Void {
        if Device.IS_IPAD {
            let storyboard = UIStoryboard(name: "TheJournal", bundle: nil)
            let controller:JournalVC = storyboard.instantiateViewController(withIdentifier: "JournalVC") as! JournalVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.id = id
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
        nc.post(name:Notification.Name(rawValue: "FJkJOURNALLISTSEGUE"),
                object: nil,
                userInfo: nil)
    }
    
    func journalCalledFromList(sizeTrait: SizeTrait,id: NSManagedObjectID) -> Void {
        let storyboard = UIStoryboard(name: "TheJournal", bundle: nil)
        let controller:JournalVC = storyboard.instantiateViewController(withIdentifier: "JournalVC") as! JournalVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.id = id
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    
    @objc func nfirsB1Called()-> Void{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:NFIRSBasic1FormTVC = storyboard.instantiateViewController(withIdentifier: "NFIRSBasic1FormTVC") as! NFIRSBasic1FormTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.delegate = self
        controller.myShift = .nfirs
        controller.titleName = "NFIRS BASIC 1"
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func arcFormCalledFromList(sizeTrait: SizeTrait,id: NSManagedObjectID)-> Void {
        let storyboard = UIStoryboard(name: "Form", bundle: nil)
        let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.objectID = id
        controller.delegate = self
        //        controller.titleName = "CRR Smoke Alarm Inspection Form"
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func ics214CalledFromList(sizeTrait: SizeTrait,id: NSManagedObjectID)-> Void {
        
        let storyboard = UIStoryboard(name: "NewICS214", bundle: nil)
        let controller  = storyboard.instantiateViewController(identifier: "NewICS214DetailTVC") as! NewICS214DetailTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        
        controller.objectID = id
        controller.delegate = self
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    @objc func ics214Called(objectID: NSManagedObjectID)-> Void{
        
        if Device.IS_IPAD {
            let storyboard = UIStoryboard(name: "NewICS214", bundle: nil)
            let controller  = storyboard.instantiateViewController(identifier: "NewICS214DetailTVC") as! NewICS214DetailTVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.delegate = self
            controller.objectID = objectID
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
        nc.post(name:Notification.Name(rawValue:"FJkICS214FORMLISTCALLED"),
                object: nil,
                userInfo: nil)
    }
    
    @objc func alarmFormCalled(object: NSManagedObjectID)-> Void{
        if Device.IS_IPAD {
            let storyboard = UIStoryboard(name: "Form", bundle: nil)
            let controller: ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.objectID = object
            controller.delegate = self
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
        nc.post(name:Notification.Name(rawValue:"FJkARCFORMLISTCALLED"),
                object: nil,
                userInfo: nil)
    }
    
    func projectCalled(sizeTrait: SizeTrait, id: NSManagedObjectID) -> Void {
        if Device.IS_IPAD {
            let storyboard = UIStoryboard(name: "Promotion", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PromotionJournalVC") as! PromotionJournalVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.id = id
            self.splitVC?.showDetailViewController(navigator, sender:self)
        }
        nc.post(name: .fireJournalProjectListCalled, object: nil, userInfo: nil)
    }
    
    func projectCalledFromList(sizeTrait: SizeTrait, id: NSManagedObjectID) -> Void {
        let storyboard = UIStoryboard(name: "Promotion", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PromotionJournalVC") as! PromotionJournalVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.id = id
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func personalCalled(sizeTrait: SizeTrait,id: NSManagedObjectID) -> Void {
        print("hey let's go journal")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:PersonalJournalTVC = storyboard.instantiateViewController(withIdentifier: "PersonalJournalTVC") as! PersonalJournalTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        controller.id = id
        controller.sizeTrait = sizeTrait
        controller.myShift = .personal
        controller.delegate = self
        controller.titleName = "Personal Journal"
        self.splitVC?.showDetailViewController(navigator, sender:self)
        nc.post(name:Notification.Name(rawValue: FJkPERSONALLISTCALLED ),
                object: nil,
                userInfo: nil)
    }
    
    func personalCalledFromList(sizeTrait: SizeTrait,id: NSManagedObjectID) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:PersonalJournalTVC = storyboard.instantiateViewController(withIdentifier: "PersonalJournalTVC") as! PersonalJournalTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.navigationItem.leftItemsSupplementBackButton = true
        controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
        //        controller.managedObjectContext = context
        controller.id = id
        controller.sizeTrait = sizeTrait
        controller.myShift = .personal
        controller.delegate = self
        controller.titleName = "Personal Journal"
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func myProfileCalled(compact: SizeTrait)-> SettingsTheProfileTVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsTheProfileTVC = storyboard.instantiateViewController(withIdentifier:"SettingsTheProfileTVC") as! SettingsTheProfileTVC
        return controller
    }
    
    func settingsCloudCalled(compact: SizeTrait, objectID: NSManagedObjectID)-> Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.settingsType = FJSettings.cloud
        controller.compact = compact
        controller.userObjectID = self.userID
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsCrewCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsCrewTVC = storyboard.instantiateViewController(withIdentifier:"SettingsCrewTVC") as! SettingsCrewTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Crew"
        controller.settingType = FJSettings.crewMembers
        controller.compact = compact
        controller.splitVC = self.splitVC
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsTagsCalled(compact: SizeTrait, objectID: NSManagedObjectID)-> Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Tags"
        controller.settingType = FJSettings.tags
        controller.compact = compact
        controller.objectID = self.userID
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsRankCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Rank"
        controller.settingType = FJSettings.rank
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsPlatoonCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Platoon"
        controller.settingType = FJSettings.platoon
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsMyFireStationResourcesCalled(compact: SizeTrait) -> Void {
        let storyboard = UIStoryboard(name: "SettingsMyResources", bundle: nil)
        let controller:SettingsMyResourcesTVC = storyboard.instantiateViewController(withIdentifier:"SettingsMyResourcesTVC") as! SettingsMyResourcesTVC
        controller.titleName = "My Fire Station Resources"
        controller.settingsType = FJSettings.fireStationResources
        controller.compact = compact
        let navigator = UINavigationController.init(rootViewController: controller)
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsResourcesCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsUserFDResourcesTVC = storyboard.instantiateViewController(withIdentifier:"SettingsUserFDResourcesTVC") as! SettingsUserFDResourcesTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Department Resources"
        controller.settingType = FJSettings.resources
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsStreetTypeCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal NFIRS Street Types"
        controller.settingType = FJSettings.streetTypes
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsLocalIncidentTypesCalled(compact: SizeTrait, objectID: NSManagedObjectID)-> Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsDataTVC") as! SettingsDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Local Incident Types"
        controller.settingType = FJSettings.localIncidentTypes
        controller.compact = compact
        controller.objectID = self.userID
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsTermsCalled(compact: SizeTrait, objectID: NSManagedObjectID)-> Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.settingsType = FJSettings.terms
        controller.compact = compact
        controller.userObjectID = self.userID
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsPrivacyCalled(compact: SizeTrait, objectID: NSManagedObjectID)-> Void {
        self.userID = objectID
        let storyboard = UIStoryboard(name: "SettingsInfo", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier:"SettingsInfoVC") as! SettingsInfoVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.settingsType = FJSettings.privacy
        controller.compact = compact
        controller.userObjectID = self.userID
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsResetDataCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsResetTVC = storyboard.instantiateViewController(withIdentifier:"SettingsResetTVC") as! SettingsResetTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Reset Data"
        controller.settingType = FJSettings.resetData
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsContactsCalled(compact: SizeTrait)-> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsContactsTVC = storyboard.instantiateViewController(withIdentifier:"SettingsContactsTVC") as! SettingsContactsTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        controller.titleName = "Fire Journal Contacts"
        controller.settingType = FJSettings.contacts
        controller.compact = compact
        controller.splitVC = self.splitVC
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func settingsProfileDataCalled(type:FJSettings,compact: SizeTrait)->Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:SettingsProfileDataTVC = storyboard.instantiateViewController(withIdentifier:"SettingsProfileDataTVC") as! SettingsProfileDataTVC
        let navigator = UINavigationController.init(rootViewController: controller)
        switch type {
        case .platoon:
            controller.titleName = "Fire Journal Platoons"
            controller.type = FJSettings.platoon
        case .rank:
            controller.titleName = "Fire Journal Ranks"
            controller.type = FJSettings.rank
        case .assignment:
            controller.titleName = "Fire Journal Assignments"
            controller.type = FJSettings.assignment
        case .fdid:
            controller.titleName = "Fire Journal FDIDs"
            controller.type = FJSettings.fdid
        case .apparatus:
            controller.titleName = "Fire Journal Apparatus"
            controller.type = FJSettings.apparatus
        default: break
        }
        controller.compact = compact
        self.splitVC?.showDetailViewController(navigator, sender:self)
    }
    
    func networkUnavailable()->UIAlertController {
        let title = "Internet Activity"
        let errorString = "This app is not connected to the internet at this time."
        let alert = UIAlertController.init(title: title, message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Thanks", style: .default, handler: {_ in
        })
        alert.addAction(okAction)
        self.alertI = 1
        return alert
    }
    
}

extension VCLaunch: NewStoreVCDelegate {
    func closeTheNewStore() {
        //    MARK: -TODO-
    }
    
    func quarterlyTappedNewStore() {
        //    MARK: -TODO-
    }
    
    func annualTappedNewStore() {
        //    MARK: -TODO-
    }
    
    func loginTappedNewStore() {
        //    MARK: -TODO-
    }
    
    func restoreTappedNewStore() {
        //    MARK: -TODO-
    }
    
    
}

extension VCLaunch: NewStoreBetaVCDelegate {
    
    func closeTheBetaStore() {
        print("closeTheBetaStore()")
    }
    
    func betaMonthTapped() {
        print("betaMonthTapped()")
    }
    
    func betaQuarterlyTapped() {
        print("betaQuarterlyTapped()")
    }
    
    func betaAnnualTapped() {
        print("betaAnnualTapped()")
    }
    
    func betaLoginTapped() {
        print("betaLoginTapped()")
    }
    
    func betaRestoreTapped() {
        print("betaRestoredTapped()")
    }
    
    
}

extension VCLaunch: NewICS214DetailTVCDelegate {
    func theCampaignHasChanged() {}
}

extension VCLaunch: ARC_FormDelegate {
    func theFormHasCancelled() {
        //        <#code#>
    }
    
    func theFormHasBeenSaved() {
        //        <#code#>
    }
    
    func theFormWantsNewForm() {
        //        <#code#>
    }
    
    
}

extension VCLaunch: TheStoreVCDelegate {
    
    func theStoreSubscriptionPurchased() {
//        <#code#>
    }
    
    
}
