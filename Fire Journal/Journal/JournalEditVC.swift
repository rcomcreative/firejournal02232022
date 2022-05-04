//
//  JournalEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/3/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

protocol JournalEditVCDelegate: AnyObject {
    func journalEditSaveTapped(objectID: NSManagedObjectID)
    func journalEditCancelTapped()
}

class JournalEditVC: UIViewController {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var objectID: NSManagedObjectID!
    var theJournal: Journal!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    weak var delegate: JournalEditVCDelegate? = nil
    
    var headerTitle: String = """
Edit Journal
"""
    var journalModalHeaderV: ModalHeaderSaveDismiss!
    var journalTableView: UITableView!
    var segmentType: MenuItems!
    
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!

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
        
        if objectID != nil {
            theJournal = context.object(with: objectID) as? Journal
        } else {
            dismiss(animated: true, completion: nil)
        }
        configureModalHeaderSaveDismiss()
        configureJournalTableView()
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
            journalTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        journalTableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}

extension JournalEditVC {
    
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

extension JournalEditVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        delegate?.journalEditCancelTapped()
    }
    
    func modalSave(myShift: MenuItems) {
        if context.hasChanges {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"New Journal entry merge that"])
                }
                DispatchQueue.main.async {
                    self.nc.post(name:Notification.Name(rawValue:FJkCKModifyJournalToCloud),
                                 object: nil,
                                 userInfo: ["objectID": self.objectID as NSManagedObjectID])
                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.journalEditSaveTapped(objectID: self.objectID)
            } catch let error as NSError {
                let nserror = error
                
                let errorMessage = "JournalNew saveToCD The context was unable to save due to \(nserror), \(nserror.userInfo)"
                print(errorMessage)
            }
        }
        
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    func presentAlert() {
        let message: InfoBodyText = .editJournalHeaderSubject
        let title: InfoBodyText = .editJournalHeaderDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension JournalEditVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        journalTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        journalTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        journalTableView.register(UINib(nibName: "SegmentCell", bundle: nil), forCellReuseIdentifier: "SegmentCell")
        journalTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
    }
    
}

extension JournalEditVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
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
    
    func configureSegmentCell(_ cell: SegmentCell, index: IndexPath) -> SegmentCell {
        let tag = index.row
        cell.tag = tag
        cell.delegate = self
        cell.subjectL.text = "Journal Type"
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
    
}

extension JournalEditVC: LabelTextFieldCellDelegate {
    
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

extension JournalEditVC: SegmentCellDelegate {
    
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

extension JournalEditVC: LabelDateiPhoneTVCellDelegate {
   
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theJournal.journalModDate = theDate
    }
    
}

extension JournalEditVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theJournal.journalModDate = date
    }
    
}
