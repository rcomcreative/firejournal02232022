//
//  JournalNewModalVC_Extesions.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/26/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CloudKit
import MapKit
import CoreLocation

extension JournalNewModalVC {
    
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
    
        //    MARK: -CONFIGUREHEIGHT-
    
        /// find the height for text area using the string associated with input
        /// - Parameter text: text entered in modals for form
        /// - Returns: returns the height for the label cell
    func configureLabelHeight(text: String ) -> CGFloat {
        var theFloat: CGFloat = 0.0
        let frame = self.view.frame
        let width = frame.width - 70
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = .systemFont(ofSize: 18)
        label.text = text
        label.sizeToFit()
        let labelFrame = label.frame
        theFloat = labelFrame.height
        label.removeFromSuperview()
        if theFloat < 44 {
            theFloat = 88
        }
        return theFloat
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
        let message: InfoBodyText = .newIncidentSubject
        let title: InfoBodyText = .newIncident
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
//    MARK: -CONFIGURE-BODY-
    func configureModalHeaderSaveDismiss() {
        journalModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        journalModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(journalModalHeaderV)
        journalModalHeaderV.modalHTitleL.textColor = UIColor.white
        journalModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        journalModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        journalModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        journalModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        journalModalHeaderV.modalHTitleL.text = headerTitle
        journalModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJBlueColor") {
            journalModalHeaderV.contentView.backgroundColor = color
        }
        journalModalHeaderV.myShift = MenuItems.incidents
        journalModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            journalModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            journalModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            journalModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            journalModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureJournalTableView() {
        journalTableView = UITableView(frame: .zero)
        registerCellsForTable()
        journalTableView.translatesAutoresizingMaskIntoConstraints = false
        journalTableView.backgroundColor = .systemBackground
        view.addSubview(journalTableView)
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.separatorStyle = .none
        
        journalTableView.rowHeight = UITableView.automaticDimension
        journalTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            journalTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            journalTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            journalTableView.topAnchor.constraint(equalTo: journalModalHeaderV.bottomAnchor, constant: 5),
            journalTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension JournalNewModalVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        if theJournal != nil {
            context.delete(theJournal)
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New Journal delete merge that"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "journalNew deleteJournalEntry The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            theJournal = nil
        }
        delegate?.journalNewCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        if theJournal.journalHeader == nil || theJournal.journalHeader == "" {
            let cell = journalTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LabelTextFieldCell
            if let header = cell.descriptionTF.text {
                theJournal.journalHeader = header
            } else {
                theJournal.journalHeader = ""
            }
        }
        if theJournal.journalHeader != "" {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New Journal entry merge that"])
                }
                let objectID = theJournal.objectID
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKNewJournalCreated),
                                 object: nil,
                                 userInfo: ["objectID": objectID as NSManagedObjectID])
                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.journalNewSaved(objectID: objectID)
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "JournalNew saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        } else {
            var message: String = "The following is needed to complete\n\n"
            var messagesA = [String]()
            if theJournal.journalHeader == "" {
                let error: String = "The title for the journal entry is needed."
                messagesA.append(error)
            }
            let theMessage = messagesA.joined(separator: "\n")
            message = message + theMessage
            errorAlert(errorMessage: message)
        }
        
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
}

extension JournalNewModalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        journalTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        journalTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        journalTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        journalTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        journalTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        journalTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
    }
    
}

extension JournalNewModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 85
        case 1:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 60
            }
        case 2:
            return 84
        case 3:
            return 85
        case 4:
            if theOverviewNotesAvailable {
                return theOverviewNotesHeight
            } else {
                return 0
            }
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch  row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 1:
            if Device.IS_IPHONE {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
                return cell
            } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelSingleDateFieldCell", for: indexPath) as! LabelSingleDateFieldCell
            cell = configureLabelSingleDateFieldCell(cell, index: indexPath)
            cell.configureTheLabel(width: 125)
            cell.configureDatePickersHoldingV()
            return cell
            }
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "SegmentCell", for: indexPath) as! SegmentCell
            cell = configureSegmentCell(cell, index: indexPath)
            return cell
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "MultipleAddButtonTVCell", for: indexPath) as! MultipleAddButtonTVCell
            cell = configureMultipleAddButtonTVCell(cell, index: indexPath)
            cell.configureTheButton()
            return cell
        case 4:
            if theOverviewNotesAvailable {
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
                cell = configureLabelCell(cell, index: indexPath)
                return cell
            } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                    return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
            
        func configureLabelCell(_ cell: LabelCell, index: IndexPath) -> LabelCell {
            cell.tag = index.row
            let row = index.row
            cell.modalTitleL.font = cell.modalTitleL.font.withSize(15)
            cell.modalTitleL.adjustsFontSizeToFitWidth = true
            cell.modalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.modalTitleL.numberOfLines = 0
            cell.infoB.isHidden = true
            cell.infoB.alpha = 0.0
            cell.infoB.isEnabled = false
            switch row {
            case 4:
                cell.modalTitleL.text = theOverviewNotes
            default: break
            }
            cell.modalTitleL.setNeedsDisplay()
            return cell
        }

    
    func configureMultipleAddButtonTVCell(_ cell: MultipleAddButtonTVCell, index: IndexPath) -> MultipleAddButtonTVCell {
        cell.tag = index.row
        cell.indexPath = index
        let section = index.section
        let row = index.row
        cell.delegate = self
        switch section {
        case 0:
            switch row {
            case 3:
                cell.type = IncidentTypes.overview
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureSegmentCell(_ cell: SegmentCell, index: IndexPath) -> SegmentCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Journal Type"
        cell.typeSegment.selectedSegmentTintColor = UIColor(named: "FJBlueColor")
        cell.myShift = .journal
        let normalTextAttributes: [NSAttributedString.Key : AnyObject] = [ NSAttributedString.Key.foregroundColor : UIColor.white,
                        ]
        cell.typeSegment.setTitleTextAttributes(normalTextAttributes, for: .selected)
        cell.typeSegment.selectedSegmentTintColor = UIColor(named: "FJBlueColor")
        cell.typeSegment.removeAllSegments()
        cell.typeSegment.insertSegment(withTitle: "Station", at: 0, animated: false)
        cell.typeSegment.insertSegment(withTitle: "Community", at: 1, animated: false)
        cell.typeSegment.insertSegment(withTitle: "Members", at: 2, animated: false)
        cell.typeSegment.insertSegment(withTitle: "Training", at: 3, animated: false)
        
        
        if let station = theJournal.journalEntryType {
            if station == "Station" {
                segmentType = MenuItems.station
            } else if station == "Community" {
                segmentType = MenuItems.community
            } else if station == "Members" {
                segmentType = MenuItems.members
            } else if station == "Training" {
                segmentType = MenuItems.training
            }
        } else {
            theJournal.journalEntryType = "Station"
            theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            segmentType = MenuItems.station
        }
        
        switch segmentType {
        case .station:
            cell.typeSegment.selectedSegmentIndex = 0
        case .community:
            cell.typeSegment.selectedSegmentIndex = 1
        case .members:
            cell.typeSegment.selectedSegmentIndex = 2
        case .training:
            cell.typeSegment.selectedSegmentIndex = 3
        default:
            cell.typeSegment.selectedSegmentIndex = 0
        }
        return cell
    }
    
    func configureLabelSingleDateFieldCell(_ cell: LabelSingleDateFieldCell, index: IndexPath ) -> LabelSingleDateFieldCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theJournal != nil {
                    if let journalModDate = theJournal.journalModDate {
                        cell.theFirstDose = journalModDate
                    } else {
                        if let createDate = theJournal.journalCreationDate {
                            cell.theFirstDose = createDate
                            theJournal.journalModDate = createDate
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureLabelDateiPhoneTVCell(_ cell: LabelDateiPhoneTVCell, index: IndexPath) -> LabelDateiPhoneTVCell {
        let row = index.row
        cell.tag = row
        cell.delegate = self
        cell.index = index
        let section = index.section
        switch section {
        case 0:
            switch row {
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theJournal != nil {
                    if let journalModDate = theJournal.journalModDate {
                        cell.theFirstDose = journalModDate
                    } else {
                        if let createDate = theJournal.journalCreationDate {
                            cell.theFirstDose = createDate
                            theJournal.journalModDate = createDate
                        }
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        case 0:
            cell.delegate = self
            cell.theShift = MenuItems.journal
            cell.subjectL.text = "Topic/Title"
            cell.descriptionTF.tag = 1
            if let topic = theJournal.journalHeader {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Journal entry title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
            return cell
        default: break
        }
        return cell
    }
    
}

extension JournalNewModalVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 3:
            let storyboard = UIStoryboard(name: "TheJournalNote", bundle: nil)
            if let theJournalNoteVC = storyboard.instantiateViewController(withIdentifier: "TheJournalNoteVC") as? TheJournalNoteVC {
                theJournalNoteVC.modalPresentationStyle = .formSheet
                theJournalNoteVC.isModalInPresentation = true
                theJournalNoteVC.theType = IncidentTypes.overview
                theJournalNoteVC.isIncidentNote = false
                if theJournal != nil {
                    theJournalNoteVC.journalObID = theJournal.objectID
                    theJournalNoteVC.delegate = self
                    theJournalNoteVC.index = index
                    self.present(theJournalNoteVC , animated: true, completion: nil)
                }
            }
        default: break
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
}

extension JournalNewModalVC: TheJournalNoteVCDelegate {
    
    func theJournalNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        let row = index.row
        let indexPath = IndexPath(row: 4, section: 0)
        switch type {
        case .overview:
            theOverviewNotesAvailable = true
            theOverviewNotes = text
            theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            if theJournal != nil {
                theJournal.journalOverviewSC = theOverviewNotes as NSObject
            }
        case .discussion:
            theDiscussionNotesAvailable = true
            theDiscussionNotes = text
            theDiscussionNotesHeight = configureLabelHeight(text: theDiscussionNotes)
            if theJournal != nil {
                theJournal.journalDiscussionSC = theDiscussionNotes as NSObject
            }
        case .nextSteps:
            theNextStepsNotesAvailable = true
            theNextStepsNotes = text
            theNextStepsNotesHeight = configureLabelHeight(text: theNextStepsNotes)
            if theJournal != nil {
                theJournal.journalNextStepsSC = theNextStepsNotes as NSObject
            }
        case .lastUnitStandingNote:
            theSummaryNotesAvailable = true
            theSummaryNotes = text
            theSummaryNotesHeight = configureLabelHeight(text: theSummaryNotes)
            if theJournal != nil {
                theJournal.journalSummarySC = theSummaryNotes as NSObject
            }
        default: break
        }
        journalTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension JournalNewModalVC: SegmentCellDelegate {
    
    func sectionChosen(type: MenuItems) {
        switch type {
        case .station:
            theJournal.journalEntryType = "Station"
            theJournal.journalEntryTypeImageName = "100515IconSet_092016_Stationboard c0l0r"
            segmentType = MenuItems.station
        case .community:
            theJournal.journalEntryType = "Community"
            theJournal.journalEntryTypeImageName = "ICONS_communityboard color"
            segmentType = MenuItems.community
        case .members:
            theJournal.journalEntryType = "Members"
            theJournal.journalEntryTypeImageName = "ICONS_Membersboard color"
            segmentType = MenuItems.members
        case .training:
            theJournal.journalEntryType = "Training"
            theJournal.journalEntryTypeImageName = "ICONS_training"
            segmentType = MenuItems.training
        default: break
        }
    }
    
    
}

extension JournalNewModalVC: LabelDateiPhoneTVCellDelegate {
   
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theJournal.journalModDate = theDate
    }
    
}

extension JournalNewModalVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theJournal.journalModDate = date
    }
    
}


extension JournalNewModalVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        theJournal.journalHeader = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        theJournal.journalHeader = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    
}


