//
//  NewPromotionVC+Extensions.swift
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

extension NewPromotionVC {
    
    func configurePromotionModalHeaderV() {
        promotionModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        promotionModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(promotionModalHeaderV)
        promotionModalHeaderV.modalHTitleL.textColor = UIColor.white
        promotionModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        promotionModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        promotionModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        promotionModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        promotionModalHeaderV.modalHTitleL.text = headerTitle
        promotionModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJBlueColor") {
            promotionModalHeaderV.contentView.backgroundColor = color
        }
        promotionModalHeaderV.myShift = MenuItems.incidents
        promotionModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            promotionModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            promotionModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            promotionModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            promotionModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configurePromotionTableView() {
        promotionTableView = UITableView(frame: .zero)
        registerCellsForTable()
        promotionTableView.translatesAutoresizingMaskIntoConstraints = false
        promotionTableView.backgroundColor = .systemBackground
        view.addSubview(promotionTableView)
        promotionTableView.delegate = self
        promotionTableView.dataSource = self
        promotionTableView.separatorStyle = .none
        
        promotionTableView.rowHeight = UITableView.automaticDimension
        promotionTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            promotionTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            promotionTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            promotionTableView.topAnchor.constraint(equalTo: promotionModalHeaderV.bottomAnchor, constant: 5),
            promotionTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
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

}

extension NewPromotionVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        promotionTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        promotionTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        promotionTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        promotionTableView.register(MultipleAddButtonTVCell.self, forCellReuseIdentifier: "MultipleAddButtonTVCell")
        promotionTableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
    }
    
}

extension NewPromotionVC: UITableViewDataSource {
    
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
            return 85
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
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell = configureLabelTextFieldCell(cell, index: indexPath)
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
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
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
                cell.type = IncidentTypes.theProjectOverview
                cell.aBackgroundColor = "FJBlueColor"
                cell.aChoice = ""
            default: break
            }
        default: break
        }
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        cell.tag = row
        switch row {
        case 0:
            cell.delegate = self
            cell.theShift = MenuItems.projects
            cell.subjectL.text = "Project"
            cell.descriptionTF.tag = 1
            if let topic = thePromotion.projectName {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Project title",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
            return cell
        case 2:
            cell.delegate = self
            cell.theShift = MenuItems.projects
            cell.subjectL.text = "Project Type"
            cell.descriptionTF.tag = 1
            if let topic = thePromotion.projectType {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Project type: class, training, other ",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
            return cell
        default:
            cell.subjectL.isHidden = true
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
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
                if thePromotion != nil {
                    if let projectDate = thePromotion.promotionDate {
                        cell.theFirstDose = projectDate
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
                if thePromotion != nil {
                    if let projectDate = thePromotion.promotionDate {
                        cell.theFirstDose = projectDate
                    }
                }
            default: break
            }
        default: break
        }
        return cell
    }
    
    
}

extension NewPromotionVC: MultipleAddButtonTVCellDelegate {
    
    func multiAddBTapped(type: IncidentTypes, index: IndexPath) {
        let row = index.row
        switch row {
        case 3:
            let storyboard = UIStoryboard(name: "PromotionNote", bundle: nil)
            if let thePromotionNoteVC = storyboard.instantiateViewController(withIdentifier: "PromotionNoteVC") as? PromotionNoteVC {
                thePromotionNoteVC.modalPresentationStyle = .formSheet
                thePromotionNoteVC.isModalInPresentation = true
                thePromotionNoteVC.theType = IncidentTypes.theProjectOverview
                if thePromotion != nil {
                    thePromotionNoteVC.promotionObID = thePromotion.objectID
                    thePromotionNoteVC.delegate = self
                    thePromotionNoteVC.index = index
                    self.present(thePromotionNoteVC , animated: true, completion: nil)
                }
            }
        default: break
        }
    }
    
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath) {
    }
    
    
}

extension NewPromotionVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 1:
            thePromotion.promotionDate = date
        default: break
        }
    }
    
    
}

extension NewPromotionVC: PromotionNoteVCDelegate {
    
    func thePromotionNoteHasBeenUpdated(text: String, index: IndexPath, type: IncidentTypes) {
        let indexPath = IndexPath(row: 4, section: 0)
        switch type {
        case .theProjectOverview:
            theOverviewNotesAvailable = true
            theOverviewNotes = text
            theOverviewNotesHeight = configureLabelHeight(text: theOverviewNotes)
            if thePromotion != nil {
                thePromotion.overview = theOverviewNotes as NSObject
            }
        default: break
        }
        promotionTableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension NewPromotionVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {}
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        if thePromotion != nil {
            let row = tag
            switch row {
            case 0:
                thePromotion.projectName = text
            case 2:
                thePromotion.projectType = text
            default: break
            }
        }
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    
}

extension NewPromotionVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        let row = index.row
        switch row {
        case 1:
            thePromotion.promotionDate = theDate
        default: break
        }
    }
    
    
}

extension NewPromotionVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        if thePromotion != nil {
            context.delete(thePromotion)
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New Promotion delete merge that"])
                }
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "promotionNew deletePromotionJournalEntry The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
            thePromotion = nil
        }
        delegate?.newPromotionCanceled()
    }
    
    func modalSave(myShift: MenuItems) {
        if thePromotion.projectName == nil || thePromotion.projectName == "" {
            let cell = promotionTableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LabelTextFieldCell
            if let header = cell.descriptionTF.text {
                thePromotion.projectName = header
            } else {
                thePromotion.projectName = ""
            }
        }
        if thePromotion.projectName != "" {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New Journal entry merge that"])
                }
                let objectID = thePromotion.objectID
                DispatchQueue.main.async {
                    self.nc.post(name: .fireJournalNewProjectCreatedSendToCloud,
                                 object: nil,
                                 userInfo: ["objectID": objectID as NSManagedObjectID])
                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.newPromotionCreated(objectID: objectID)
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "Project saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        } else {
            var message: String = "The following is needed to complete\n\n"
            var messagesA = [String]()
            if thePromotion.projectName == "" {
                let error: String = "The title for the project is needed."
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
