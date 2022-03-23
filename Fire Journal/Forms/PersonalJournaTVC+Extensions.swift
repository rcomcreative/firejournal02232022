//
//  PersonalJournaTVC+Extensions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/20/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

extension PersonalJournalTVC {
    //    MARK: - SAVE FROM NAV
    private func theCountForTags(guid: String, tag: String)->Int {
        let attribute = "journalGuid"
        let entity = "JournalTags"
        let subAttribute = "journalTag"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity )
        let predicate = NSPredicate(format: "%K == %@", attribute, guid)
        let predicate2 = NSPredicate(format: "%K == %@", subAttribute, tag)
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate,predicate2])
        fetchRequest.predicate = predicateCan
        do {
            let count = try context.count(for:fetchRequest)
            return count
        } catch let error as NSError {
            print("JournalTVC line 632 Fetch Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    @objc func savePersonalJournal(_ sender:Any) {
        journal.journalOverview = journalStructure.journalOverview  as NSObject
        if incidentPOV {
            journal.journalDiscussion = journalStructure.journalDiscussion as NSObject
        } else {
            journal.journalSummary = journalStructure.journalSummary as NSObject
        }
        journal.journalEntryType = journalStructure.journalType
        journal.journalModDate = Date()
        
        if !journalStructure.journalTagsA.isEmpty {
            for tag in journalStructure.journalTagsA {
                let result = tagsA.filter { $0 == tag }
                if result.isEmpty {
                    let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
                    fjuJournalTags.journalTag = tag
                    fjuJournalTags.journalTagBackUp = false
                    fjuJournalTags.journalTagModDate = Date()
                    fjuJournalTags.journalGuid = journal.fjpJGuidForReference
                    journal.addToJournalTagDetails(fjuJournalTags)
                }
            }
        }
        //        for ( _, tag ) in journalStructure.journalTagsA.enumerated() {
        //            let count = theCountForTags(guid: journal.fjpJGuidForReference ?? "", tag: tag)
        //            if count == 0 {
        //                let fjuJournalTags = JournalTags.init(entity: NSEntityDescription.entity(forEntityName: "JournalTags", in: context)!, insertInto: context)
        //                fjuJournalTags.journalTag = tag
        //                fjuJournalTags.journalTagBackUp = false
        //                fjuJournalTags.journalTagModDate = Date()
        //                fjuJournalTags.journalGuid = journal.fjpJGuidForReference
        //                journal.addToJournalTagDetails(fjuJournalTags)
        //            }
        //        }
        
        journal.journalBackedUp = false
        saveToCD()
    }
    
    //    MARK: -SAVE TO CD AND CLOUD
    fileprivate func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"PersonalJournal merge that"])
            }
            self.tableView.reloadData()
            DispatchQueue.main.async {
                //                self.getTheLastSaved()
                self.nc.post(name:Notification.Name(rawValue:FJkCKModifyJournalToCloud),
                             object: nil,
                             userInfo: ["objectID":self.id])
            }
            
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.personal])
            }
            delegate?.thePersonalJournalEntrySaved()
            
        }   catch let error as NSError {
            let nserror = error
            
            let errorMessage = "JOURNALTVC SAVETOCD Unresolved error \(nserror) \(nserror.localizedDescription) \(String(describing: nserror._userInfo))"
            print(errorMessage)
            
        }
    }
    
    private func getTheLastSaved() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        let predicate = NSPredicate(format: "%K != %@", "fjpJGuidForReference", "")
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 20
        do {
            self.fetched = try context.fetch(fetchRequest) as! [Journal]
            let journal = self.fetched.last as! Journal
            self.objectID = journal.objectID
        } catch let error as NSError {
            print("JournalTVC line 698 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    func registerTheCells() {
        tableView.register(UINib(nibName: "ControllerLabelCell", bundle: nil), forCellReuseIdentifier: "ControllerLabelCell")
        tableView.register(UINib(nibName: "LabelTextViewCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewCell")
        tableView.register(UINib(nibName: "LabelTextViewTimeStampCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewTimeStampCell")
        tableView.register(UINib(nibName: "LabelTextViewDirectionalCell",bundle: nil), forCellReuseIdentifier: "LabelTextViewDirectionalCell")
    }
    
    @objc func compactOrRegular(ns: Notification) {
        if let userInfo = ns.userInfo as! [String: Any]?
        {
            compact = userInfo["compact"] as? SizeTrait ?? .regular
            switch compact {
            case .compact:
                print("compact Personal JOURNAL")
            case .regular:
                print("regular Personal JOURNAL")
            }
        }
        self.tableView.reloadData()
    }
    
    func builtTheJournal(id: NSManagedObjectID) {
        journal = context.object(with: id) as? Journal
        journalStructure.journalTitle = journal.journalHeader ?? ""
        if let overView = journal.journalOverview as? String {
            journalStructure.journalOverview = overView
        }
        let jDate = journal.journalCreationDate
        let fullyFormattedDate = FullDateFormat.init(date:jDate ?? Date())
        let journalDate:String = fullyFormattedDate.formatFullyTheDate()
        journalStructure.journalDate = jDate
        journalStructure.journalCreationDate = journalDate
        journalStructure.journalSummary = journal.journalSummary as? String ?? ""
        journalStructure.journalUserGuid = journal.fjpUserReference ?? ""
        journalStructure.journalGuid = journal.fjpJGuidForReference ?? ""
        let guid = journalStructure.journalGuid
        let prefix = guid.prefix(10)
        if prefix == "01.INCPOV." {
            incidentPOV = true
            journalStructure.journalDiscussion = journal.journalDiscussion as? String ?? ""
        }
        if journal.fireJournalUserInfo != nil {
            fju = journal.fireJournalUserInfo
            journalStructure.journalUser = fju.userName ?? ""
        }
        for tags in journal.journalTagDetails  as! Set<JournalTags> {
            let tag = tags.journalTag ?? ""
            tagsA.append(tag)
        }
        tagsA = tagsA.filter { $0 != ""}
        tagsA = Array(NSOrderedSet(array: tagsA)) as! [String]
        journalStructure.journalTagsA = tagsA
        let tag:String = tagsA.joined(separator: ", ")
        journalStructure.journalTags = tag
    }
    
    private func presentTags(menuType:MenuItems, title:String, type:JournalTypes) {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let dataTVC = storyBoard.instantiateViewController(withIdentifier: "TagsTVC") as! TagsTVC
        dataTVC.delegate = self
        dataTVC.transitioningDelegate = slideInTransitioningDelgate
        if journalStructure.journalTagsA.count != 0 {
            dataTVC.selected = journalStructure.journalTagsA
        }
        dataTVC.modalPresentationStyle = .custom
        self.present(dataTVC, animated: true, completion: nil)
    }
    
}

extension PersonalJournalTVC: LabelTextViewDirectionalCellDelegate {
    func theDirectionalButtonWasTapped(type: JournalTypes) {
        switch type {
        case .tags:
            presentTags(menuType: myShift, title: "Tags", type: type)
        default: break
        }
    }
    
    func theTextViewIsFinishedEditing(type: JournalTypes, text: String) {
        //    TODO: -THE DELEGATE EXTENSIONS
    }
    
    
}

extension PersonalJournalTVC: LabelTextViewCellDelegate {
    
    //    MARK: -THE DELEGATE EXTENSIONS
    func textViewEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        journalStructure.journalOverview = text
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        overViewHeight = estimatedSize.height + 52.5
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    func textViewDoneEditing(text: String, myShift: MenuItems,journalType:JournalTypes) {
        journalStructure.journalOverview = text
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        overViewHeight = estimatedSize.height + 52.5
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    func textViewEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {
        //    TODO: -THE DELEGATE EXTENSIONS
    }
    
    func textViewDoneEditing(text: String, myShift: MenuItems, incidentType: IncidentTypes) {
        //    TODO: -THE DELEGATE EXTENSIONS
    }
}

extension PersonalJournalTVC: LabelTextViewTimeStampCellDelegate {
    
    func timeStampTapped(type: JournalTypes) {
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tableView.cellForRow(at: indexPath)! as! LabelTextViewTimeStampCell
        let text = cell.descriptionTV.text ?? ""
        if text != "" {
            let name = journalStructure.journalUser
            let timeStamp = vcLaunch.timeStamp(date: Date(), user: name )
            if incidentPOV {
                cell.journalType = JournalTypes.discussion
                journalStructure.journalDiscussion = "\(text) \n \(timeStamp)"
            } else {
                cell.journalType = .summary
                journalStructure.journalSummary = "\(text) \n \(timeStamp)"
            }
            updateDiscussionTextView()
            savePersonalJournal(self)
        } else {
            let name = journalStructure.journalUser
            let timeStamp = vcLaunch.timeStamp(date: Date(), user: name )
            if incidentPOV {
                cell.journalType = JournalTypes.discussion
                journalStructure.journalDiscussion = "\(timeStamp)\n"
            } else {
                cell.journalType = .summary
                journalStructure.journalSummary = "\(timeStamp)\n"
            }
            updateDiscussionTextView()
            savePersonalJournal(self)
        }
    }
    
    private func updateDiscussionTextView() {
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! LabelTextViewTimeStampCell
        let size = CGSize(width: cell.descriptionTV.frame.width, height: .infinity)
        let estimatedSize = cell.descriptionTV.sizeThatFits(size)
        
        discussionHeight = estimatedSize.height + 80
        tableView.beginUpdates()
        cell.descriptionTV.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if Device.IS_IPAD {
                    constraint.constant = estimatedSize.height
                } else {
                    if estimatedSize.height < 400 {
                        constraint.constant = estimatedSize.height
                    } else {
                        constraint.constant = 400
                    }
                }
            }
            
        }
        tableView.endUpdates()
    }
    
    func tsTextViewEdited(text: String, journalType: JournalTypes, myShift: MenuItems) {
        if incidentPOV {
            journalStructure.journalDiscussion = text
        } else {
            journalStructure.journalSummary = text
        }
        //        updateDiscussionTextView()
        //        savePersonalJournal(self)
    }
    
    func tsTextViewEndedEditing(text: String, journalType: JournalTypes, myShift: MenuItems) {
        self.resignFirstResponder()
        if incidentPOV {
            journalStructure.journalDiscussion = text
        } else {
            journalStructure.journalSummary = text
        }
        updateDiscussionTextView()
    }
    
}

extension PersonalJournalTVC: TagsTVCDelegate {
    
    func theCancelTagsBTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func theTagsHaveBeenChosen(tags: Array<String>) {
        theTags = tags.filter { $0 != "" }
        let tag:String = theTags.joined(separator: ", ")
        journalStructure.journalTags = tag
        journalStructure.journalTagsA = theTags
        tableView.reloadData()
    }
    
}
