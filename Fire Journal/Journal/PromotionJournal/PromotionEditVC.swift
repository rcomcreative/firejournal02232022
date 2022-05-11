//
//  PromotionEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 5/4/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

protocol PromotionEditVCDelegate: AnyObject {
    func promotionEditSaveTapped(objectID: NSManagedObjectID)
    func promotionEditCancelTapped()
}

class PromotionEditVC: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var objectID: NSManagedObjectID!
    var theProject: PromotionJournal!
    var alertUp: Bool = false
    let nc = NotificationCenter.default
    
    weak var delegate: PromotionEditVCDelegate? = nil
    
    var headerTitle: String = """
Edit Project
"""
    var projectModalHeaderV: ModalHeaderSaveDismiss!
    var projectTableView: UITableView!
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
            theProject = context.object(with: objectID) as? PromotionJournal
        } else {
            dismiss(animated: true, completion: nil)
        }
        configureModalHeaderSaveDismiss()
        configureProjectTableView()
        
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
            projectTableView.setBottomInset(to: keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print("Notification: Keyboard will hide")
        projectTableView.setBottomInset(to: 0.0)
    }
    
        /// Used with gesture recognizer for dismissing keyboard
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension PromotionEditVC {
    
        //    MARK: -CONFIGURE-BODY-
            func configureModalHeaderSaveDismiss() {
                projectModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
                projectModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(projectModalHeaderV)
                projectModalHeaderV.modalHTitleL.textColor = UIColor.white
                projectModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
                projectModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
                projectModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
                projectModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
                projectModalHeaderV.modalHTitleL.text = headerTitle
                projectModalHeaderV.infoB.setTitle("", for: .normal)
                if let color = UIColor(named: "FJBlueColor") {
                    projectModalHeaderV.contentView.backgroundColor = color
                }
                projectModalHeaderV.myShift = MenuItems.incidents
                projectModalHeaderV.delegate = self
                
                NSLayoutConstraint.activate([
                    projectModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    projectModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                    projectModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                    projectModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
                ])
            }
            
            func configureProjectTableView() {
                projectTableView = UITableView(frame: .zero)
                registerCellsForTable()
                projectTableView.translatesAutoresizingMaskIntoConstraints = false
                projectTableView.backgroundColor = .systemBackground
                view.addSubview(projectTableView)
                projectTableView.delegate = self
                projectTableView.dataSource = self
                projectTableView.separatorStyle = .none
                
                projectTableView.rowHeight = UITableView.automaticDimension
                projectTableView.estimatedRowHeight = 300
                
                NSLayoutConstraint.activate([
                    projectTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
                    projectTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
                    projectTableView.topAnchor.constraint(equalTo: projectModalHeaderV.bottomAnchor, constant: 5),
                    projectTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
                ])
            }
    
}

extension PromotionEditVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        delegate?.promotionEditCancelTapped()
    }
    
    func modalSave(myShift: MenuItems) {
        if context.hasChanges {
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"Promotion journal edit merge that"])
                }
//                DispatchQueue.main.async {
//                    self.nc.post(name:Notification.Name(rawValue:FJkCKModifyJournalToCloud),
//                                 object: nil,
//                                 userInfo: ["objectID": self.objectID as NSManagedObjectID])
//                }
                DispatchQueue.main.async {
                    self.nc.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
                }
                delegate?.promotionEditSaveTapped(objectID: self.objectID)
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
        let message: InfoBodyText = .editProjectHeaderSubject
        let title: InfoBodyText = .editProjectHeaderDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
}

extension PromotionEditVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        projectTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        projectTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        projectTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
    }
    
}

extension PromotionEditVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
                if theProject != nil {
                    if let theDate = theProject.promotionDate {
                        cell.theFirstDose = theDate
                    } else {
                        if let createDate = theProject.promotionDate {
                            cell.theFirstDose = createDate
                            theProject.promotionDate = createDate
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
            if let topic = theProject.projectName {
                cell.descriptionTF.text = topic
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: "Project name",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
            }
            cell.descriptionTF.keyboardType = .alphabet
            return cell
        default: break
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
                if theProject != nil {
                    if let theDate = theProject.promotionDate {
                        cell.theFirstDose = theDate
                    } else {
                        if let createDate = theProject.promotionDate {
                            cell.theFirstDose = createDate
                            theProject.promotionDate = createDate
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

extension PromotionEditVC: LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {}
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        theProject.projectName = text
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        theProject.projectName = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {}
    
}

extension PromotionEditVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theProject.promotionDate = theDate
    }
    
}

extension PromotionEditVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theProject.promotionDate = date
    }
    
}


