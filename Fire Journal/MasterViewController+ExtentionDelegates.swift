//
//  MasterViewController+ExtentionDelegates.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/23/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import StoreKit

extension MasterViewController: ListTVCDelegate {
    
    func incidentTappedForMap(objectID: NSManagedObjectID, compact: SizeTrait) {
    }
    
    func journalObjectChosen(type:MenuItems,id:NSManagedObjectID,compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        switch type {
        case .journal:
            switch compact {
            case .compact:
                vcLaunch.journalCalledFromList(sizeTrait:compact,id: id)
            case .regular:
                vcLaunch.journalCalled(sizeTrait: compact, id: id)
            }
        case .incidents:
            switch compact {
            case .compact:
                vcLaunch.incidentCalledFromList(sizeTrait:compact,id: id)
            case .regular:
                vcLaunch.incidentCalled(sizeTrait: compact, id: id)
            }
        case .personal:
            switch compact {
            case .compact:
                vcLaunch.personalCalledFromList(sizeTrait: compact, id: id)
            case .regular:
                vcLaunch.personalCalled(sizeTrait: compact, id: id)
            }
        case .maps:
            vcLaunch.mapCalledFromList(sizeTrait: compact)
        case .ics214:
            switch compact {
            case .compact:
                vcLaunch.ics214CalledFromList(sizeTrait: compact, id: id)
            case .regular:
                vcLaunch.personalCalled(sizeTrait: compact, id: id)
            }
        case .arcForm:
            switch compact {
            case .compact:
                vcLaunch.arcFormCalledFromList(sizeTrait: compact, id: id)
            case .regular:
                vcLaunch.personalCalled(sizeTrait: compact, id: id)
            }
        default:
            print("nothing here")
        }
    }
    
    func menuWasTapped() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
    func theJournalWasTapped() {
    }
    
}

extension MasterViewController: OpenModalScrollVCDelegate {
    
        //    MARK: -OpenModalScrollVCDelegate
    func allCompleted(yesNo: Bool) {
        self.dismiss(animated: true, completion: {
            self.userDefaults.set(true, forKey: FJkFIRSTRUNFORDATAFROMCLOUDKIT)
            self.userDefaults.synchronize()
            self.theAgreementsAccepted()
            self.freshDeskRequest()
            self.appDelegate.fetchAnyChangesWeMissed(firstRun: true)
        })
        
    }
    
    func errorOnFormLoad(errorInCD: String) {
        dismiss(animated: true, completion: {
            let title:String = "Error in Core Data"
            let message:String = errorInCD
            let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
                self.alertUp = false
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            self.alertUp = true
        })
    }
    
}

extension MasterViewController: SettingsTVCDelegate {
    
        //    MARK: -SettingsTVCDelegate
    func settingsTapped() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func settingsLoadPage(settings: FJSettings) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        let collapsed = userDefaults.bool(forKey: FJkFJISCOLLAPSED)
        switch settings {
        case .myProfile:
            let vc:SettingsTheProfileTVC = vcLaunch.modalSettingsProfileCalled()
            vc.delegate = self
            vc.titleName = "My Profile"
            vc.compact = compact
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .cloud:
            let vc:SettingsInfoTVC = vcLaunch.modalSettingsCloudCalled()
            vc.titleName = "Fire Journal Cloud"
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.cloud
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .crewMembers:
            let vc:SettingsCrewTVC = vcLaunch.modalSettingsCrewCalled()
            vc.titleName = "Fire Journal Crews"
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.crewMembers
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .tags:
            let vc:SettingsDataTVC = vcLaunch.modalSettingsDataCalled(settings:FJSettings.tags)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.tags
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .rank:
            let vc:SettingsDataTVC = vcLaunch.modalSettingsDataCalled(settings:FJSettings.rank)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.rank
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .platoon:
            let vc:SettingsDataTVC = vcLaunch.modalSettingsDataCalled(settings:FJSettings.platoon)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.platoon
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .fireStationResources:
            let vc: SettingsMyResourcesTVC = vcLaunch.modalSettingsMyFDResourcesCalled(setting: FJSettings.fireStationResources)
            vc.settingsType = FJSettings.fireStationResources
            vc.titleName = ""
            vc.compact = compact
            vc.delegate = self
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .resources:
            let vc: SettingsUserFDResourcesTVC = vcLaunch.modalSettingsUserFDResourcesCalled(setting:FJSettings.resources)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.resources
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .streetTypes:
            let vc:SettingsDataTVC = vcLaunch.modalSettingsDataCalled(settings:FJSettings.streetTypes)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.streetTypes
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .localIncidentTypes:
            let vc:SettingsDataTVC = vcLaunch.modalSettingsDataCalled(settings:FJSettings.localIncidentTypes)
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.localIncidentTypes
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .terms:
            let vc:SettingsInfoTVC = vcLaunch.modalSettingsCloudCalled()
            vc.titleName = "Fire Journal Cloud"
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.terms
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .privacy:
            let vc:SettingsInfoTVC = vcLaunch.modalSettingsCloudCalled()
            vc.titleName = "Fire Journal Cloud"
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.privacy
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .contacts:
            let vc:SettingsContactsTVC = vcLaunch.modalSettingsCrewToContactsCalled()
            vc.compact = compact
            vc.collapsed = collapsed
            vc.delegate = self
            vc.settingType = FJSettings.contacts
            let navigator = UINavigationController.init(rootViewController: vc)
            self.present(navigator, animated: true, completion: nil)
        case .resetData:break
        default:
            break
        }
    }
    
}

extension MasterViewController: SettingsProfileTVCDelegate {
    
        //    MARK: -SettingsTheProfileDelegate
    func profileReturnToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
    func profileSavedNowGoToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
    }
    
    
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait) {
        let settings:FJSettings = type
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
            controller.titleName = "Assignments"
            controller.type = FJSettings.assignment
        case .apparatus:
            controller.titleName = "Apparatus"
            controller.type = FJSettings.apparatus
        case .fdid:
            controller.titleName = "FDID"
            controller.type = FJSettings.fdid
        default: break
        }
        controller.delegate = self
        controller.compact = self.compact
        let navigator = UINavigationController.init(rootViewController: controller)
        navigator.navigationItem.leftItemsSupplementBackButton = true
        navigator.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        let navigationBarAppearace = UINavigationBar.appearance()
        if #available(iOS 13.0, *) {
            navigationBarAppearace.barTintColor = UIColor.systemBackground
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
            navigationBarAppearace.tintColor = .link
        } else {
            navigationBarAppearace.barTintColor = UIColor.black
            navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        self.splitViewController?.showDetailViewController(navigator, sender:self)
    }
    
}

extension MasterViewController: SettingsInfoDelegate {
    
        //    MARK: -SettingsInfoDelegage
    func returnToSettings() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
}

extension MasterViewController: SettingsCrewDelegate {
    
        //    MARK: -SettingsCrewDelegate
    func crewSettingsToSettings() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
    func crewAskingForContactList(settings: FJSettings) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        settingsLoadPage(settings:settings)
    }
    
}

extension MasterViewController: SettingsDataDelegate {
    
        //    MARK: -SettingsDataDelegate
    func settingsDataBackToSettings() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
}

extension MasterViewController: SettingsContactsDelegate {
    
        //    MARK: -SettingContactsDelegate
    func settingsContactCancelled() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            self.settingsLoadPage(settings:FJSettings.crewMembers)
        }
    }
    
    
    func settingsContactSaved(crew:Array<CrewFromContact>) {
        self.dismiss(animated: true, completion: {
            for ( _, item ) in crew.enumerated() {
                let group = item
                let name = group.name
                    //            TODO: save each CrewFromContact to UserAttendee
                let fjUserAttendee = UserAttendees.init(entity: NSEntityDescription.entity(forEntityName: "UserAttendees", in: self.managedObjectContext!)!, insertInto: self.managedObjectContext!)
                group.createGuid()
                fjUserAttendee.attendee = name
                fjUserAttendee.attendeeEmail = group.email
                fjUserAttendee.attendeePhone = group.phone
                fjUserAttendee.attendeeModDate = group.attendeeDate
                fjUserAttendee.attendeeGuid = group.attendeeGuid
                fjUserAttendee.defaultCrewMember = group.overtimeB
                self.saveToCD(guid: group.attendeeGuid)
            }
        })
        self.navigationController?.popToRootViewController(animated: true)
        DispatchQueue.main.async {
            self.settingsLoadPage(settings:FJSettings.crewMembers)
        }
    }
    
}

extension MasterViewController: MapVCDelegate {
    
    func mapTapped() {
    }
    
}
extension MasterViewController: SettingsTheProfileDelegate {
    
    func theProfileReturnToSettings(compact: SizeTrait) {
//        <#code#>
    }
    
    func theProfileSavedNowGoToSettings(compact: SizeTrait) {
//        <#code#>
    }
    
    
}

extension MasterViewController: SettingsProfileDataDelegate {
    
        //    MARK: -PROFILEDATADELEGATE
    func settingsProfileDataCanceled() {}
    
    func settingsProfileDataChosen(type:FJSettings,_ object:String ) {
        if Device.IS_IPHONE {
                //            self.dismiss(animated: true, completion: {
            let vc:SettingsTheProfileTVC = self.vcLaunch.modalSettingsProfileCalled()
            vc.delegate = self
            vc.titleName = "My Profile"
            vc.compact = self.compact
            let navigator = UINavigationController.init(rootViewController: vc)
            let navigationBarAppearace = UINavigationBar.appearance()
            if #available(iOS 13.0, *) {
                navigationBarAppearace.barTintColor = UIColor.systemBackground
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
                navigationBarAppearace.tintColor = .link
            } else {
                navigationBarAppearace.barTintColor = UIColor.black
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            }
            self.present(navigator, animated: true, completion: nil)
                //            })
        } else {
            let vc:SettingsTheProfileTVC = self.vcLaunch.modalSettingsProfileCalled()
            vc.delegate = self
            vc.titleName = "My Profile"
            vc.compact = self.compact
            let navigator = UINavigationController.init(rootViewController: vc)
            let navigationBarAppearace = UINavigationBar.appearance()
            if #available(iOS 13.0, *) {
                navigationBarAppearace.barTintColor = UIColor.systemBackground
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
                navigationBarAppearace.tintColor = .link
            } else {
                navigationBarAppearace.barTintColor = UIColor.black
                navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            }
            self.present(navigator, animated: true, completion: nil)
        }
    }
    
}

extension MasterViewController: ICS214DetailViewControllerDelegate {
    
}

extension MasterViewController: SettingsUserFDResourcesTVCDelegate  {
    
        //    MARK: -SettingsUserFDResourcesTVCDelegate
    func userFDResourcesBackToSettings() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
}

extension MasterViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}

extension MasterViewController: OpenFDResourcesTVCDelegate {
    
    func openFDResourcesTVCCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openFDResourcesTVCSave() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func openFDResourcesCloseItUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension MasterViewController: SettingsMyResourcesTVCDelegate {
    
    func settingsMyFireStationResourcesBackToSettings() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        myShiftCellTapped(myShift: MenuItems.settings)
    }
    
}

extension MasterViewController: FlameLogoCellDelegate {
    
    func pureCommandBTapped() {
        cloudOrSupport(supportOrCloud: "purecommand")
    }
    
}

extension MasterViewController: MyShiftCellDelegate {
    
        ///
        ///    MyShiftCell Tapped
        /// - Parameters:
        ///        - myShift: MenuItems
        ///
        /// - Note
        ///    each MenuItem sends info our to DetailViewController
        ///
    func myShiftCellTapped(myShift: MenuItems) {
        shiftMine = myShift
        myShiftForSegue = myShift
        _ = userDefaults.bool(forKey: FJkSETTINGSHASSTATE)
        if lockDown {} else {
            switch myShift {
            case .myShift:
                print("myShift")
                let segue = "showDetail"
                performSegue(withIdentifier: segue, sender: self)
            case .journal:
                print("Journal")
                entity = "Journal"
                attribute = "journalDateSearch"
                getTheData(myShift: myShift)
                if !fetched.isEmpty {
                    let journal = fetched.last as! Journal
                    let id = journal.objectID
                    switch compact {
                    case .compact:
                        vcLaunch.journalCalled(sizeTrait:compact,id: id)
                    case .regular:
                        nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),
                                object: nil,
                                userInfo: ["sizeTrait":compact,"objectID":id])
                    }
                } else {
                    
                }
            case .incidents:
                print("Incidents")
                entity = "Incident"
                attribute = "incidentSearchDate"
                let int = theCount(entity: "Incident")
                if int != 0 {
                    getTheData(myShift: myShift)
                    let incident = fetched.last as! Incident
                    let id = incident.objectID
                    switch compact {
                    case .compact:
                        vcLaunch.incidentCalled(sizeTrait: compact, id: id)
                    case .regular:
                        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER),object: nil, userInfo: ["sizeTrait":compact, "objectID": id])
                    }
                } else {
                    print("needanincident")
                    shiftMine = .incidents
                    let segue = "showDetail"
                    performSegue(withIdentifier: segue, sender: self)
                }
            case .personal:
                print("Personal")
                entity = "Journal"
                attribute = "journalDateSearch"
                let int:Int = theCountPersonal()
                if int != 0 {
                    getTheData(myShift: myShift)
                    let journal = fetched.last as! Journal
                    let id = journal.objectID
                    switch compact {
                    case .compact:
                        vcLaunch.personalCalled(sizeTrait:compact,id: id)
                    case .regular:
                        nc.post(name:Notification.Name(rawValue:FJkPERSONAL_FROM_MASTER),
                                object: nil, userInfo: ["sizeTrait":compact,"objectID": id])
                    }
                } else {
                    print("need a private entry")
                    shiftMine = .personal
                    let segue = "showDetail"
                    performSegue(withIdentifier: segue, sender: self)
                }
            case .maps:
                print("Maps")
                switch compact {
                case .compact:
                    print("Incidents")
                    entity = "Incident"
                    attribute = "incidentSearchDate"
                    let int = theCount(entity: "Incident")
                    if int != 0 {
                            //                getTheMapsList()
                        if (Device.IS_IPHONE) {
                            vcLaunch.mapCalledPhone(type: .allIncidents)
                        } else {
                            vcLaunch.mapCalled(type: .allIncidents)
                        }
                    } else {
                        print("needanincident")
                        shiftMine = .incidents
                        let segue = "showDetail"
                        performSegue(withIdentifier: segue, sender: self)
                    }
                case .regular:
                    print("Incidents")
                    entity = "Incident"
                    attribute = "incidentSearchDate"
                    let int = theCount(entity: "Incident")
                    if int != 0 {
                        if (Device.IS_IPHONE) {
                            vcLaunch.mapCalledPhone(type: .allIncidents)
                        } else {
                            getTheMapsList()
                            nc.post(name:Notification.Name(rawValue:FJkMAPS_FROM_MASTER),
                                    object: nil, userInfo: ["sizeTrait":compact])
                        }
                    } else {
                        print("needanincident")
                        shiftMine = .incidents
                        let segue = "showDetail"
                        performSegue(withIdentifier: segue, sender: self)
                    }
                }
            case .forms:
                if Device.IS_IPHONE {
                    self.myShift = MenuItems.forms
                    let segue = "showDetail"
                    performSegue(withIdentifier: segue, sender: self)
                } else {
                    nc.post(name:Notification.Name(rawValue: FJkLOADFORMMODAL),object:nil)
                }
            case .settings:
                let collaped = self.splitViewController?.isCollapsed
                print("Settings here is collapsed \(String(describing: collaped))")
                if !collaped! {
                    nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                            object: nil,
                            userInfo: ["sizeTrait":compact])
                } else {
                    let title = "Fire Journal Settings"
                    let vc:SettingsTVC = vcLaunch.modalSettingsCalled()
                    vc.delegate = self
                    vc.titleName = title
                    vc.compact = compact
                    let navigator = UINavigationController.init(rootViewController: vc)
                    navigator.navigationItem.leftItemsSupplementBackButton = true
                    navigator.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                    let navigationBarAppearace = UINavigationBar.appearance()
                    if #available(iOS 13.0, *) {
                        navigationBarAppearace.barTintColor = UIColor.systemBackground
                        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
                        navigationBarAppearace.tintColor = .link
                    } else {
                        navigationBarAppearace.barTintColor = UIColor.black
                        navigationBarAppearace.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
                    }
                    self.present(navigator, animated: true, completion: nil)
                }
            case .store:
                print("Store")
                switch compact {
                case .compact:
                    let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
                    if available {
                        vcLaunch.storeCalled()
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
                        self.present(alert,animated: true)
                    }
                case .regular:
                    let available = userDefaults.bool(forKey: FJkInternetConnectionAvailable)
                    if available {
                        nc.post(name:Notification.Name(rawValue:FJkSTORE_FROM_MASTER),
                                object: nil,
                                userInfo: ["objectID":"", "date":"","arcFormGuid":""])
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        let alert = theNetworkUnavailable(errorString: "This app is not connected to the internet at this time.")
                        self.present(alert,animated: true)
                    }
                }
            case .cloud:
                let membership = fjMembershipIsBought()
                if membership {
                    cloudOrSupport(supportOrCloud: "cloud")
                } else {
                    buyAMembership()
                }
            case .support:
                cloudOrSupport(supportOrCloud: "support")
            default:
                print("default")
            }
        }
    }
    
}

extension MasterViewController: JournalTVCDelegate {
    func goBack() {
    }
    
    func journalSaveTapped() {
    }
    
    func journalBackToList() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}
