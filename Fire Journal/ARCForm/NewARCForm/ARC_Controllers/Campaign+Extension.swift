//
//  Campaign+Extension.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/8/20.
//  Copyright © 2020 com.purecommand.FJARCPlus. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension CampaignTVC {
    
//    MARK: -REGISTER_THE_CELLS-
    func registerTheCells() {
        tableView.register(UINib(nibName: "ARC_ParagraphCell", bundle: nil), forCellReuseIdentifier: "ARC_ParagraphCell")
        tableView.register(UINib(nibName: "ARC_TwoButtonCell", bundle: nil), forCellReuseIdentifier: "ARC_TwoButtonCell")
        tableView.register(UINib(nibName: "ARC_CampaignNameCell", bundle: nil), forCellReuseIdentifier: "ARC_CampaignNameCell")
        tableView.register(UINib(nibName: "ARC_ChooseACampaignCell", bundle: nil), forCellReuseIdentifier: "ARC_ChooseACampaignCell")
        tableView.register(UINib(nibName: "ARC_CampaignCell", bundle: nil), forCellReuseIdentifier: "ARC_CampaignCell")
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
    
    func countAlert(errorMessage: String) {
        let alert = UIAlertController.init(title: "Error", message: errorMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Configure the Paragraphs Cell
    /// - Parameters:
    ///   - cell: Paragraph Cell
    ///   - indexPath: placement of cell in tableview
    ///   - tag: tag designated to the cell
    /// - Returns: a configured Paragraph Cell
    func configureARC_ParagraphCell(_ cell: ARC_ParagraphCell, at indexPath: IndexPath, tag: Int) ->ARC_ParagraphCell {
        cell.path = indexPath
        cell.headerOne = "Purpose:"
        cell.paragraphOne = "The CRR Smoke Alarm Form is for use when inspecting a single family residence (home or apartment) for working smoke alarms. This form will provide for tracking of distribution of smoke alarms, the impact on the family or persons living in the unit described, the location, and other relevant data that will impact Community Risk Reduction efforts."
        cell.headerTwo = "Preparation:"
        cell.paragraphTwo = "A CRR form can be implemented as a one-off individual form. Alternatively, you may create a “campaign” in the event you’re canvassing a neighborhood or a series of residences. Personnel should document as many items within the form as possible, and get each “head of household” to sign the form at the bottom. An installer or member in attendance should also sign the form."
        cell.headerThree = "Distribution:"
        cell.paragraphThree = "Distribution: is available via the Membership module (learn more about membership) and may be sent via email, or printed as a PDF form. The PDF form matches the format as established by the American Red Cross."
        return cell
    }
    
    /// Configure the ARC_TwoButtonCell
    /// - Parameters:
    ///   - cell: ARC_TwoButtonCell
    ///   - indexCell: placement in campaign view table
    ///   - tag: cells tag
    /// - Returns: the configured 2 button cell for master or additional forms with button actions
    func configureARC_TwoButtonCell(_ cell: ARC_TwoButtonCell, at indexCell: IndexPath, tag: Int ) -> ARC_TwoButtonCell {
        cell.path = indexCell
        cell.delegate = self
        return cell
    }
    
    /// Configure the Campaign Name Cell
    /// - Parameters:
    ///   - cell: ARC_CampaignNameCell
    ///   - indexPath: index path in the tableView
    ///   - tag: cells tag
    /// - Returns: returns textfield for creating new campaign name with textfield delegate button forces textfield to end capturing text and sending to delegate new form is created in the delegate campaignNameCreateBTapped(name: String, path: IndexPath)
    func configureARC_CampaignNameCell(_ cell: ARC_CampaignNameCell, at indexPath: IndexPath, tag: Int ) ->ARC_CampaignNameCell {
        cell.path = indexPath
        cell.subject = "Campaign Name:"
        cell.delegate = self
        return cell
    }
    
    /// Configure the 'Choose A Campaign' header cell
    /// - Parameters:
    ///   - cell: ARC_ChooseACampaignCell
    ///   - indexPath: placement in the tableview
    ///   - tag: cells tag
    /// - Returns: returns a red button with "Choose A Campaign" text
    func configureARC_ChooseACampaignCell(_ cell: ARC_ChooseACampaignCell, at indexPath: IndexPath, tag: Int) ->ARC_ChooseACampaignCell {
        return cell
    }
    
    /// Configure the Campaign Cell with the campaign name, address, date and object id to be passed on for building an additional form for the campaign
    /// - Parameters:
    ///   - cell: ARC_CampaignCell
    ///   - indexPath: the indexPath for the cell
    ///   - tag: 4
    ///   - object:objectId for the master campaign
    /// - Returns: a cell configured with address, date, name of campaign and it's object id
    func configureARC_CampaignCell(_ cell: ARC_CampaignCell, at indexPath: IndexPath, tag: Int, object: ARCCampaign4 ) ->ARC_CampaignCell {
        cell.cAddress = object.address
        cell.cDate = object.date
        cell.cName = object.name
        cell.object = object.objectID
        cell.theMasterGuid = object.masterGuid
        cell.iName = "100515IconSet_092016_redCross"
        return cell
    }
    
}

extension CampaignTVC: NSFetchedResultsControllerDelegate {
    
    func buildTheOpenARC_CampaignCells() {
        _ = getTheCampaignData()
        if !fetchedObjects.isEmpty {
            for form in fetchedObjects {
                let cell4 = ARCCampaign4()
                cell4.objectID = form.objectID
                cell4.name = form.campaignName
                cell4.address = form.arcLocationAddress
                if let date = form.arcCreationDate {
                    dateFormatter.dateFormat = "MM/dd/YYYY HH:mm"
                    let creationDate = dateFormatter.string(from: date)
                    cell4.date = creationDate
                }
                cell4.masterGuid = form.arcFormCampaignGuid
                cellsForCampaign.cells.append(cell4)
            }
        } else {
            countAlert(errorMessage: "You need to create an open campaign to be able to use the additional form, or use a single form.")
        }
    }
    
    func buildAdditionalFormFromMaster(object: NSManagedObjectID, address: String, theCampaignName: String, masterGuid: String ) {
        let user = userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
        var summary: String = ""
        var name: String = ""
        if user {
            firejournaluser = getTheUser()
            if let first = firejournaluser.firstName {
                name = first
            }
            if let last = firejournaluser.lastName {
                name = "\(name) \(last)"
            }
        }
        campaignName = theCampaignName
        var count = getTheCampaignCount(masterGuid: masterGuid )
        let creationDate = Date()
        
        self.theForm = ARCrossForm(context: context)
        self.theResidence = Residence(context: context)
        self.theLocalPartners = LocalPartners(context: context)
        self.theNationalPartners = NationalPartners(context: context)
        
        if masterJournal != nil {
            jObjectID = masterJournal.objectID
            masterJournalAvailable = true
        }  else {
            masterJournal = Journal(context: context)
            masterJournal.fjpJGuidForReference = masterJournal.guidForJournal( creationDate, dateFormatter: dateFormatter)
                   masterJournal.journalModDate = creationDate
            masterJournal.arcFormMasterGuid = masterGuid
                   masterJournal.fjpJournalModifiedDate = creationDate
                   masterJournal.journalCreationDate = creationDate
                   self.theForm.journalGuid = masterJournal.fjpJGuidForReference
                   masterJournal.journalEntryTypeImageName = "administrativeNewColor58"
                   masterJournal.journalEntryType = "Station"
                   masterJournal.journalHeader = "Smoke Alarm Installation Form Campaign: \(campaignName)"
                   let timeStamp = masterJournal.journalFullDateFormatted(creationDate, dateFormatter: dateFormatter)
                   let summary = "Time Stamp: \(timeStamp) Smoke Alarm Inspection Form:User Master entered"
                   masterJournal.journalSummary = summary as NSObject
                   let overview = "Smoke Alarm Inspection Form entered"
                   masterJournal.journalOverview = overview as NSObject
                   masterJournal.journalEntryType = "Station"
                   masterJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
                   
                   if firejournaluser != nil {
                       let platoon = firejournaluser.tempPlatoon  ?? ""
                       masterJournal.journalTempPlatoon = platoon
                       let assignment = firejournaluser.tempAssignment ?? ""
                       masterJournal.journalTempAssignment = assignment
                       let apparatus = firejournaluser.tempApparatus ?? ""
                       masterJournal.journalTempApparatus = apparatus
                       let fireStation = firejournaluser.tempFireStation ?? firejournaluser.fireStation ?? ""
                       masterJournal.journalTempFireStation = fireStation
                   }
                   
                   masterJournal.journalDateSearch = timeStamp
                   masterJournal.journalCreationDate = creationDate
                   masterJournal.journalModDate = creationDate
                   masterJournal.arcFormMasterGuid = theForm.arcFormCampaignGuid
                   masterJournal.journalPrivate = true
                   masterJournal.journalBackedUp = false
        }
        count = count + 1
        let count64 = Int64(count)
        self.theForm.arcMaster = false
        self.theForm.arcFormCampaignGuid = masterGuid
        self.theForm.arcFormGuid = self.theForm.guidForARCForm(creationDate, dateFormatter: self.dateFormatter )
        self.theForm.arcCreationDate = creationDate
        self.theForm.cStartDate = creationDate
        self.theForm.arcModDate = creationDate
        self.theForm.receiveSPM = false
        self.theForm.recieveEP = false
        self.theForm.reviewFEPlan = false
        self.theForm.createFEPlan = false
        self.theForm.localHazard = false
        self.theForm.residentContactInfo = false
        self.theForm.residentSigned = false
        self.theForm.installerSigend = false
        self.theForm.arcBackup = false
        self.theForm.arcMaster = false
        self.theForm.campaignCount = count64
        self.theForm.campaign = false
        self.theForm.cComplete = false
        self.theForm.campaignName = campaignName
        self.theForm.arcLocationAptMobile = "NA"
        self.theForm.arcPortalSystem = "ARC ORP"
        self.theForm.addToArCrossFormInfo(theNationalPartners)
        self.theForm.addToLocalPartnerInto(theLocalPartners)
        self.theForm.addToResidentsInfo(theResidence)
        if let sum = masterJournal.journalSummary as? String {
            let timeStamp = masterJournal.journalFullDateFormatted(creationDate, dateFormatter: dateFormatter)
            summary = "\(sum)\nTime Stamp: \(timeStamp) Additional Form added to Campaign by \(name)"
            masterJournal.journalSummary = summary as NSObject
            masterJournal.journalBackedUp = false
            masterJournal.journalModDate = creationDate
            masterJournal.fjpJournalModifiedDate = creationDate
        }
        saveAdditionalForm()
    }
    
    func getJournalWithMasterGuid(masterGuid: String ) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Journal" )
        var predicate = NSPredicate.init()
        predicate = NSPredicate(format: "%K == %@", "arcFormMasterGuid", masterGuid)
        let sectionSortDescriptor = NSSortDescriptor(key: "journalCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            let fetched = try context.fetch(fetchRequest) as! [Journal]
            if !fetched.isEmpty {
                masterJournal = fetched.last
            }
        } catch let error as NSError {
            print("Fetch failed: \(error.localizedDescription)")
        }
    }
    
    //    MARK: -SAVE THE ADDITIONAL FORM AND MASTERJOURNAL-
    fileprivate func saveAdditionalForm() {
        do {
            try context.save()
            print("here we go with the save")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"CampaignTVC merge that"])
                print("letting the context know we are updating")
            }
            if let guid = theForm.arcFormGuid {
                getTheLastSaved(guid: guid)
                if let object = self.objectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWFormCreated ) ,object:self.context,userInfo:["objectID": object ])
                    print("letting the context know we are updating")
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWARCFORMForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            }
           
        } catch let error as NSError {
            print("CampaignTVC line 250 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    //    MARK: -SAVE THE FORM-
    fileprivate func saveToCD() {
        do {
            try context.save()
            print("here we go with the save")
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"CampaignTVC merge that"])
                print("letting the context know we are updating")
            }
            if let guid = theForm.arcFormGuid {
                getTheLastSaved(guid: guid)
                if let object = self.objectID {
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWFormCreated ) ,object:self.context,userInfo:["objectID": object ])
                    print("letting the context know we are updating")
                    }
                    DispatchQueue.main.async {
                        self.nc.post(name: Notification.Name(rawValue: FJkNEWARCFORMForCloudKit), object: nil, userInfo: ["objectID": object])
                    }
                }
            }
        } catch let error as NSError {
            print("CampaignTVC line 93 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    //    MARK: -Get The User-
       func getTheUser() ->FireJournalUser {
           var fju:FireJournalUser? = nil
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FireJournalUser" )
           var predicate = NSPredicate.init()
           predicate = NSPredicate(format: "%K != %@", "userGuid", "")
           let sectionSortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
           let sortDescriptors = [sectionSortDescriptor]
           fetchRequest.sortDescriptors = sortDescriptors
           
           fetchRequest.predicate = predicate
           fetchRequest.fetchBatchSize = 20
           
           do {
               let fetched = try context.fetch(fetchRequest) as! [FireJournalUser]
               if !fetched.isEmpty {
                   fju = fetched.last
               }
           } catch let error as NSError {
               print("Fetch failed: \(error.localizedDescription)")
           }
           return fju!
       }
    
    // MARK: -
    // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    private func getTheCampaignCount(masterGuid: String) ->Int {
        var count: Int = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "arcFormCampaignGuid" , masterGuid)
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [ARCrossForm]
            if !self.fetched.isEmpty {
                count = self.fetched.count
            }
        } catch let error as NSError {
            print("CampaignTVC line 125 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
        return count
    }
    
    private func getTheLastSaved(guid: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ARCrossForm" )
        var predicate = NSPredicate.init()
        predicate =  NSPredicate(format: "%K == %@" , "arcFormGuid" , guid)
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.predicate = predicate
        fetchRequest.fetchBatchSize = 1
        
        do {
            self.fetched = try context.fetch(fetchRequest) as! [ARCrossForm]
                let arcForm = self.fetched.last as! ARCrossForm
                self.objectID = arcForm.objectID
        } catch let error as NSError {
            print("CampaignTVC line 278 Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let error: String = "Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: error)
            }
        }
    }
    
    func getTheCampaignData() -> NSFetchedResultsController<ARCrossForm> {
        
        let fetchRequest: NSFetchRequest<ARCrossForm> = ARCrossForm.fetchRequest()
        
        
        var predicate = NSPredicate.init()
        var predicate2 = NSPredicate.init()
        var predicate3 = NSPredicate.init()
        predicate = NSPredicate(format: "cComplete == %@", NSNumber(value: false ))
        predicate2 = NSPredicate(format: "arcMaster == %@", NSNumber(value:true))
        predicate3 = NSPredicate(format: "campaignName != %@","Single")
        let predicateCan = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate, predicate2, predicate3])
        fetchRequest.predicate = predicateCan
        fetchRequest.fetchBatchSize = 20
        
        let sectionSortDescriptor = NSSortDescriptor(key: "arcCreationDate", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        fetchedResultsController = aFetchedResultsController
        
        do {
            try fetchedResultsController!.performFetch()
        } catch let error as NSError {
            print("ListTVC Fetch Error: \(error.localizedDescription)")
            if !self.alertUp {
                let errorred: String =  "Data Error: \(error.localizedDescription) Try again later."
                self.errorAlert(errorMessage: errorred)
            }
        }
        return fetchedResultsController!
    }
    

}

//      MARK: -ARC_TwoButtonCellDelegate-
extension CampaignTVC: ARC_TwoButtonCellDelegate {
    func twoButtonMasterBTapped() {
        masterForm = true
        choiceMade = true
        additionalForm = false
        let path1: IndexPath = IndexPath(item: 1, section: 0)
        let path2: IndexPath = IndexPath(item: 2, section: 0)
        tableView.reloadRows(at: [path1,path2], with: .automatic)
    }
    
    func twoButtonAdditionalBTapped() {
        masterForm = false
        choiceMade = true
        additionalForm = true
        buildTheOpenARC_CampaignCells()
        newTheCells = cellsForCampaign.cells
        tableView.reloadData()
    }

}

//      MARK: -CAMPAIGN NAME CELL DELEGATE-
extension CampaignTVC: ARC_CampaignNameCellDelegate {
    
    func campaignNameCreateBTapped(name: String, path: IndexPath) {
        campaignName = name
        let user = userDefaults.bool(forKey: FJkFJUSERSavedToCoreDataFromCloud)
        if user {
            firejournaluser = getTheUser()
        }
        self.theForm = ARCrossForm(context: context)
        self.theResidence = Residence(context: context)
        self.theLocalPartners = LocalPartners(context: context)
        self.theNationalPartners = NationalPartners(context: context)
        self.theForm.arcMaster = true
        let creationDate = Date()
        self.theForm.arcFormCampaignGuid = self.theForm.guidForCampaign(creationDate, dateFormatter: self.dateFormatter )
        self.theForm.arcFormGuid = self.theForm.guidForARCForm(creationDate, dateFormatter: self.dateFormatter )
        self.theForm.arcCreationDate = creationDate
        self.theForm.cStartDate = creationDate
        self.theForm.arcModDate = creationDate
        self.theForm.receiveSPM = false
        self.theForm.recieveEP = false
        self.theForm.reviewFEPlan = false
        self.theForm.createFEPlan = false
        self.theForm.localHazard = false
        self.theForm.residentContactInfo = false
        self.theForm.residentSigned = false
        self.theForm.installerSigend = false
        self.theForm.arcBackup = false
        self.theForm.arcMaster = true
        self.theForm.campaignCount = 1
        self.theForm.campaign = false
        self.theForm.cComplete = false
        self.theForm.campaignName = campaignName
        self.theForm.arcLocationAptMobile = "NA"
        self.theForm.arcPortalSystem = "ARC ORP"
        self.theForm.addToArCrossFormInfo(theNationalPartners)
        self.theForm.addToLocalPartnerInto(theLocalPartners)
        self.theForm.addToResidentsInfo(theResidence)
        
        journal = Journal(context: context)
        journal.fjpJGuidForReference = journal.guidForJournal( creationDate, dateFormatter: dateFormatter)
        journal.journalModDate = creationDate
        journal.fjpJournalModifiedDate = creationDate
        journal.journalCreationDate = creationDate
        self.theForm.journalGuid = journal.fjpJGuidForReference
        journal.journalEntryTypeImageName = "administrativeNewColor58"
        journal.journalEntryType = "Station"
        journal.journalHeader = "Smoke Alarm Installation Form Campaign: \(campaignName)"
        let timeStamp = journal.journalFullDateFormatted(creationDate, dateFormatter: dateFormatter)
        let summary = "Time Stamp: \(timeStamp) Smoke Alarm Inspection Form:User Master entered by user"
        journal.journalSummary = summary as NSObject
        let overview = "Smoke Alarm Inspection Form entered"
        journal.journalOverview = overview as NSObject
        journal.journalEntryType = "Station"
        journal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
        
        if firejournaluser != nil {
            let platoon = firejournaluser.tempPlatoon  ?? ""
            journal.journalTempPlatoon = platoon
            let assignment = firejournaluser.tempAssignment ?? ""
            journal.journalTempAssignment = assignment
            let apparatus = firejournaluser.tempApparatus ?? ""
            journal.journalTempApparatus = apparatus
            let fireStation = firejournaluser.tempFireStation ?? firejournaluser.fireStation ?? ""
            journal.journalTempFireStation = fireStation
        }
        
        journal.journalDateSearch = timeStamp
        journal.journalCreationDate = creationDate
        journal.journalModDate = creationDate
        journal.arcFormMasterGuid = theForm.arcFormCampaignGuid
        journal.journalPrivate = true
        journal.journalBackedUp = false
        theForm.journalDetail = journal
        saveToCD()
    }
    
    
}
