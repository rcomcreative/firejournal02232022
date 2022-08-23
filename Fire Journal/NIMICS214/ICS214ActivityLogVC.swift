    //
    //  ICS214ActivityLogVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/14/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import CoreData

protocol ICS214ActivityLogVCDelegate: AnyObject {
    func theICS214ActivityLogCancelled()
    func theICS214ActivityLogCreated()
}

class ICS214ActivityLogVC: UIViewController {
    
    weak var delegate: ICS214ActivityLogVCDelegate? = nil
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    let nc = NotificationCenter.default
    
    var index: IndexPath!
    
    var alertUp: Bool = false
    
    var headerTitle: String = """
Notable Activity
"""
    var activityLogModalHeaderV: ModalHeaderSaveDismiss!
    var activityLogTableView: UITableView!
    var ics214Form: ICS214Form!
    var ics214ActivityLog: ICS214ActivityLog!
    var ics214FormOID: NSManagedObjectID!
    var theICS214ActivityLog: ICS214ActivityLog!
    var ics214ActivityLogOID: NSManagedObjectID!
    
    var backgroundContext: NSManagedObjectContext!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ics214FormOID != nil {
            ics214Form = context.object(with: ics214FormOID) as? ICS214Form
            if ics214ActivityLogOID != nil {
                if ics214Form.ics214ActivityDetail != nil {
                    let result = ics214Form.ics214ActivityDetail?.allObjects as [ICS214ActivityLog]
                    if !result.isEmpty {
                        let log = result.filter { $0.objectID == ics214ActivityLogOID }
                        if !log.isEmpty {
                            theICS214ActivityLog = log.last
                        }
                    }
                }
            } else {
                theICS214ActivityLog = ICS214ActivityLog(context: context)
                let creationDate: Date = Date()
                var uuidA:String = NSUUID().uuidString.lowercased()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYDDDHHmmAAAAAAAA"
                let dateFrom = dateFormatter.string(from: creationDate)
                uuidA = uuidA+dateFrom
                let logGuid = "81."+uuidA
                theICS214ActivityLog.ics214ActivityGuid = logGuid
                theICS214ActivityLog.ics214Guid = ics214Form.ics214Guid
                theICS214ActivityLog.ics214ActivityCreationDate = creationDate
                theICS214ActivityLog.ics214AcivityModDate = creationDate
                ics214Form.addToIcs214ActivityDetail(theICS214ActivityLog)
            }
        }
        
        
        configureModalHeaderSaveDismiss()
        configureactivityLogTableView()
    }
    
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func infoAlert() {
        let theSubject: String = ""
        let theMessage: String = ""
        let alert = UIAlertController.init(title: theSubject, message: theMessage, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Got it!", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ICS214ActivityLogVC {
    
    func configureModalHeaderSaveDismiss() {
        activityLogModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        activityLogModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(activityLogModalHeaderV)
        activityLogModalHeaderV.modalHTitleL.textColor = UIColor.white
        activityLogModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        activityLogModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        activityLogModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        activityLogModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        activityLogModalHeaderV.modalHTitleL.text = headerTitle
        activityLogModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            activityLogModalHeaderV.contentView.backgroundColor = color
        }
        activityLogModalHeaderV.myShift = MenuItems.incidents
        activityLogModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            activityLogModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            activityLogModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            activityLogModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            activityLogModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureactivityLogTableView() {
        activityLogTableView = UITableView(frame: .zero)
        registerCellsForTable()
        activityLogTableView.translatesAutoresizingMaskIntoConstraints = false
        activityLogTableView.backgroundColor = .systemBackground
        view.addSubview(activityLogTableView)
        activityLogTableView.delegate = self
        activityLogTableView.dataSource = self
        activityLogTableView.separatorStyle = .none
        
        activityLogTableView.rowHeight = UITableView.automaticDimension
        activityLogTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            activityLogTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            activityLogTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            activityLogTableView.topAnchor.constraint(equalTo: activityLogModalHeaderV.bottomAnchor, constant: 5),
            activityLogTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension ICS214ActivityLogVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        delegate?.theICS214ActivityLogCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        let cell = tableView(activityLogTableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ICS214TextViewTVCell
        _ = cell.textViewShouldEndEditing(cell.theTextView)
        saveToCoreData {
            delegate?.theICS214ActivityLogCreated()
        }
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        infoAlert()
    }
    
    func saveToCoreData(completion: () -> Void) {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object:self.context,userInfo:["info":"ICS214ActivityLogVC merge that"])
            }
            let objectID = theICS214ActivityLog.objectID
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkNEWICS214ACTIVITYLOG_TOCLOUDKIT),
                             object: nil, userInfo: ["objectID":objectID])
            }
            completion()
        } catch let error as NSError {
            print("ICS214ActivityLogVC line 140 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
}

extension ICS214ActivityLogVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        activityLogTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
        activityLogTableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        activityLogTableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        activityLogTableView.register(ICS214TextViewTVCell.self, forCellReuseIdentifier: "ICS214TextViewTVCell")
    }
    
}

extension ICS214ActivityLogVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            if Device.IS_IPHONE {
                return 100
            } else {
                return 60
            }
        case 1:
            return 200
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
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
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "ICS214TextViewTVCell", for: indexPath) as! ICS214TextViewTVCell
            cell = configureICS214TextViewTVCell(cell, index: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell.subjectL.isHidden = true
            cell.subjectL.text = ""
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
            return cell
        }
        
    }
    
    func configureICS214TextViewTVCell(_ cell: ICS214TextViewTVCell, index: IndexPath) -> ICS214TextViewTVCell {
        cell.selectionStyle = .none
        cell.index = index
        if let theText = theICS214ActivityLog.ics214ActivityLog {
            cell.log = theText
        }
        cell.delegate = self
        cell.configure()
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
            case 0:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theICS214ActivityLog != nil {
                    if let dateTime = theICS214ActivityLog.ics214ActivityDate {
                        cell.theFirstDose = dateTime
                    } else {
                        if let modTime = theICS214ActivityLog.ics214AcivityModDate {
                            cell.theFirstDose = modTime
                            theICS214ActivityLog.ics214ActivityDate = modTime
                        }
                    }
                }
            default: break
            }
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
            case 0:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "Date/Time"
                if theICS214ActivityLog != nil {
                    if let logDate = theICS214ActivityLog.ics214ActivityDate {
                        cell.theFirstDose = logDate
                    } else {
                        if let modTime = theICS214ActivityLog.ics214AcivityModDate {
                            cell.theFirstDose = modTime
                            theICS214ActivityLog.ics214ActivityDate = modTime
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

extension ICS214ActivityLogVC: ICS214TextViewTVCellDelegate {
    
    func theTextViewTextHasChanged(_ theText: String, index: IndexPath) {
        theICS214ActivityLog.ics214ActivityLog = theText
    }
    
}

extension ICS214ActivityLogVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        theICS214ActivityLog.ics214ActivityDate = theDate
    }
    
}

extension ICS214ActivityLogVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        theICS214ActivityLog.ics214ActivityDate = date
    }
    
    
}

