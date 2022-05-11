    //
    //  ListTVC+DelegateExtensions.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 3/24/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //


import UIKit
import Foundation
import CoreData
import CloudKit

extension ListTVC: ModalTVCDelegate {
    
    func dismissTapped(shift: MenuItems) {
        print("here you go damnit")
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveBTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func formTypedTapped(shift: MenuItems) {}
    
    func journalSaved(id:NSManagedObjectID,shift:MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type:shift,id:id,compact: compact)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func incidentSave(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Incident"
        attribute = "incidentDateSearch"
        delegate?.journalObjectChosen(type:shift,id:id,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ListTVC: IncidentTVCDelegate {
    
    func incidentTapped() { }
    
}

extension ListTVC: JournalTVCDelegate {
    
    func goBack() {}
    
    func journalSaveTapped() {}
    
    func journalBackToList(){}
    
}

extension ListTVC: JournalNewModalVCDelegate {
    
    func journalNewCancelled() {
            self.dismiss(animated: true, completion: nil)
    }
    
    func journalNewSaved(objectID: NSManagedObjectID) {
        self.dismiss(animated: true, completion: {
            self.nc.post(name:Notification.Name(rawValue: FJkJOURNAL_FROM_MASTER),object: nil, userInfo: ["sizeTrait":SizeTrait.regular,"objectID": objectID])
            self.tableView.reloadData()
        })
    }
    
    
}

extension ListTVC: SettingsProfileTVCDelegate {
    
    func profileSettingsGetData(type:FJSettings,compact:SizeTrait){}
    
    func profileReturnToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
    }
    
    func profileSavedNowGoToSettings(compact:SizeTrait) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        nc.post(name:Notification.Name(rawValue:FJkSETTINGS_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact])
    }
    
}

extension ListTVC: ICS214DetailViewControllerDelegate {
    
    func completeChanged() {
            //        TODO:
    }
    
}

extension ListTVC: NewICS214ModalTVCDelegate {
    
    func theCancelCalledOnNewICS214Modal() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ListTVC: PersonalJournalDelegate {
    
        //    MARK: -PersonalJournalDelegate
    func thePersonalJournalEntrySaved(){}
    
    func thePersonalJournalCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ListTVC: ARC_ViewControllerDelegate {
    
    func noCampaignSendSingle(single: String) {
        self.dismiss(animated: true, completion: {
            let storyboard = UIStoryboard(name: "Form", bundle: nil)
            let controller:ARC_FormTVC = storyboard.instantiateViewController(withIdentifier: "ARC_FormTVC") as! ARC_FormTVC
            let navigator = UINavigationController.init(rootViewController: controller)
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.navigationItem.leftBarButtonItem = self.splitVC?.displayModeButtonItem
            controller.delegate = self
            controller.objectID = nil
            self.splitVC?.showDetailViewController(navigator, sender:self)
        })
    }
    
    func singleBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension ListTVC: PersonalNewEntryModalTVCDelegate {
    func dismissPJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func personalJournalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type: shift, id: id, compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated:true)
        nc.post(name:Notification.Name(rawValue:FJkPERSONAL_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":id])
    }
    
    
}

extension ListTVC: NewPromotionVCDelegate {
   
    func newPromotionCanceled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func newPromotionCreated(objectID: NSManagedObjectID) {
        entity = "PromotionJournal"
        attribute = "promotionDate"
        let shift = MenuItems.projects
        delegate?.journalObjectChosen(type: shift,id: objectID,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
        nc.post(name: .fireJournalProjectFromMaster, object: nil, userInfo:  ["sizeTrait": compact,"objectID": objectID])
    }
    
    
}

extension ListTVC: IncidentNewModalVCDelegate {
    
    func incidentNewCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func incidentNewSaved(objectID: NSManagedObjectID) {
        entity = "Incident"
        attribute = "incidentDateSearch"
        let shift = MenuItems.incidents
        delegate?.journalObjectChosen(type: shift,id: objectID,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait": compact,"objectID": objectID])
    }
    
}


extension ListTVC: JournalModalTVCDelegate {
    func dismissJModalTapped(shift: MenuItems) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func journalModalSaved(id: NSManagedObjectID, shift: MenuItems) {
        entity = "Journal"
        attribute = "journalDateSearch"
        delegate?.journalObjectChosen(type: shift, id: id, compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated:true)
        nc.post(name:Notification.Name(rawValue:FJkJOURNAL_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":id])
    }
}

extension ListTVC: NewerIncidentModalTVCDelegate {
    func theNewIncidentCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theNewIncidentModalSaved(ojectID: NSManagedObjectID, shift: MenuItems) {
        entity = "Incident"
        attribute = "incidentDateSearch"
        delegate?.journalObjectChosen(type:shift,id:ojectID,compact: compact)
        _ = getTheDataForTheList()
        tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
        nc.post(name:Notification.Name(rawValue:FJkINCIDENT_FROM_MASTER),
                object: nil,
                userInfo: ["sizeTrait":compact,"objectID":ojectID])
    }
    
    
}

extension ListTVC: NewICS214DetailTVCDelegate {
    func theCampaignHasChanged() {}
}

extension ListTVC: ARC_FormDelegate {
    func theFormHasCancelled() {
    }
    
    func theFormHasBeenSaved() {
    }
    
    func theFormWantsNewForm() {
    }
    
    
}

