//
//  ICS214EditHeaderVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/20/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol ICS214EditHeaderVCDelegate: AnyObject {
    func editHeaderCancelled()
    func editHeaderSaved(_ theics214FormOID: NSManagedObjectID)
}

class ICS214EditHeaderVC: UIViewController {
    
    weak var delegate: ICS214EditHeaderVCDelegate? = nil
    
    var theICS214Form: ICS214Form!
    var theICS214OID: NSManagedObjectID!
    var masterOrNot: Bool = false
    
    var headerTitle: String = """
Edit Form Header
"""
    var ics214ModalHeaderV: ModalHeaderSaveDismiss!
    var ics214TableView: UITableView!
    
    lazy var theICS214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICS214ProviderContext: NSManagedObjectContext!
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var theTypeOfForm: TypeOfForm = TypeOfForm.incidentForm
    var type: TypeOfForm = TypeOfForm.incidentForm {
        didSet {
            self.theTypeOfForm = self.type
        }
    }
    
    let nc = NotificationCenter.default
    
    var placeholderSuggestion: String = ""
    
    var theICs214Forms = [ICS214Form]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nc.addObserver(self, selector:#selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    
        // MARK: -
        // MARK: Notification Handling
    @objc func managedObjectContextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
}

extension ICS214EditHeaderVC {
    
    func configure(_ theICS214OID: NSManagedObjectID) {
    
        self.theICS214OID = theICS214OID
        self.theICS214Form = context.object(with: self.theICS214OID) as? ICS214Form
        theICS214ProviderContext = theICS214Provider.persistentContainer.newBackgroundContext()
        
        if let theType = theICS214Form.ics214Effort {
            type = theICS214Provider.determineICS214TypeFromString(theType: theType)
        }
        masterOrNot = theICS214Form.ics214EffortMaster
        let result = theICS214Form.master?.allObjects as! [ICS214Form]
        if !result.isEmpty {
            theICs214Forms = result
        }
        
        configureModalHeaderSaveDismiss()
        configureics214TableView()

    }
    
    
    
}

extension ICS214EditHeaderVC {
    
//    MARK: -CONFIGURE HEADER AND TABLE VIEW-
    
    func configureModalHeaderSaveDismiss() {
        ics214ModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        ics214ModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(ics214ModalHeaderV)
        ics214ModalHeaderV.modalHTitleL.textColor = UIColor.white
        ics214ModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        ics214ModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        ics214ModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        ics214ModalHeaderV.modalHTitleL.text = headerTitle
        ics214ModalHeaderV.infoB.setTitle("", for: .normal)
        ics214ModalHeaderV.infoB.isEnabled = false
        ics214ModalHeaderV.infoB.isHidden = true
        if let color = UIColor(named: "FJIconRed") {
            ics214ModalHeaderV.contentView.backgroundColor = color
        }
        ics214ModalHeaderV.myShift = MenuItems.incidents
        ics214ModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            ics214ModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ics214ModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ics214ModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            ics214ModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureics214TableView() {
        ics214TableView = UITableView(frame: .zero)
        registerCellsForTable()
        ics214TableView.translatesAutoresizingMaskIntoConstraints = false
        ics214TableView.backgroundColor = .systemBackground
        view.addSubview(ics214TableView)
        ics214TableView.delegate = self
        ics214TableView.dataSource = self
        ics214TableView.separatorStyle = .none
        
        ics214TableView.rowHeight = UITableView.automaticDimension
        ics214TableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            ics214TableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            ics214TableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            ics214TableView.topAnchor.constraint(equalTo: ics214ModalHeaderV.bottomAnchor, constant: 5),
            ics214TableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60),
        ])
        
        
    }
    
//    MARK: -CONFIGURE CELLS-
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
        let row = index.row
        switch row {
        case 0:
            cell.delegate = self
            
            switch type {
            case .incidentForm:
                cell.theShift = MenuItems.incidentForm
                cell.subjectL.text = "Incident Number"
                placeholderSuggestion = "Incident number"
            case .femaTaskForceForm:
                cell.theShift = MenuItems.femaTask
                cell.subjectL.text = "Effort Name"
                placeholderSuggestion = "FEMA effort name"
            case .strikeForceForm:
                cell.theShift = MenuItems.strikeTeam
                cell.subjectL.text = "Effort Name"
                placeholderSuggestion = "Strike team effort name"
            case .otherForm:
                cell.theShift = MenuItems.otherForm
                cell.subjectL.text = "Effort Name"
                placeholderSuggestion = "Other form effort name"
            }
            
            cell.descriptionTF.tag = 1
            cell.descriptionTF.textColor = .label
            if let effortName = theICS214Form.ics214IncidentName {
                cell.descriptionTF.text = effortName
            } else {
                cell.descriptionTF.attributedPlaceholder = NSAttributedString(string: placeholderSuggestion,attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.51, green: 0.51, blue: 0.51, alpha: 0.85)])
            }
            return cell
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
                cell.theSubject = "From Date/Time"
                if theICS214Form != nil {
                    if let fromTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = fromTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214FromTime = modTime
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
            case 1:
                cell.datePicker.datePickerMode = .dateAndTime
                cell.theSubject = "From Date/Time"
                if theICS214Form != nil {
                    if let fromTime = theICS214Form.ics214FromTime {
                        cell.theFirstDose = fromTime
                    } else {
                        if let modTime = theICS214Form.ics214ModDate {
                            cell.theFirstDose = modTime
                            theICS214Form.ics214FromTime = modTime
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

extension ICS214EditHeaderVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        ics214TableView.register(UINib(nibName: "LabelSingleDateFieldCell", bundle: nil), forCellReuseIdentifier: "LabelSingleDateFieldCell")
        ics214TableView.register(UINib(nibName: "LabelDateiPhoneTVCell", bundle: nil), forCellReuseIdentifier: "LabelDateiPhoneTVCell")
        ics214TableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
    }
    
}

extension ICS214EditHeaderVC: UITableViewDataSource {
    
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
            return 85
        case 1:
                return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
            cell = configureLabelTextFieldCell(cell, index: indexPath)
            return cell
        case 1:
                var cell = tableView.dequeueReusableCell(withIdentifier: "LabelDateiPhoneTVCell", for: indexPath) as! LabelDateiPhoneTVCell
                cell = configureLabelDateiPhoneTVCell(cell, index: indexPath)
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
    
    
}

extension ICS214EditHeaderVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        delegate?.editHeaderCancelled()
    }
    
    func modalSave(myShift: MenuItems) {
        saveICS214(self)
    }
    
    func modalInfoBTapped(myShift: MenuItems) {    }
    
        //    MARK: -SAVE METHODS-
    @objc func saveICS214(_ sender:Any) {
        let modDate = Date()
        theICS214Form.ics214ModDate = modDate
        theICS214Form.ics214BackedUp = false
        if !theICs214Forms.isEmpty {
            for log in theICs214Forms {
                if let effortName = theICS214Form.ics214IncidentName {
                    log.ics214IncidentName = updateEffortNameForAdditionalForms(effortName, log: log)
                    log.ics214ModDate = modDate
                    log.ics214BackedUp = false
                }
            }
        }
        saveToCD()
    }
    
    func updateEffortNameForAdditionalForms(_ newTitle: String, log: ICS214Form) -> String {
        var newTitle = newTitle
        if let theName = log.ics214IncidentName {
            guard let suffix = theName.firstIndex(of: "-") else { return "" }
            let theSuffix = theName.suffix(from: suffix)
            let numString = String(theSuffix)
            newTitle = newTitle + " " +  numString
        }
    return newTitle
    }
    
    func saveToCD() {
        do {
            try context.save()
            DispatchQueue.main.async {
                self.delegate?.editHeaderSaved(self.theICS214OID)
                self.nc.post(name:NSNotification.Name.NSManagedObjectContextDidSave,object: self.theICS214ProviderContext ,userInfo:["info":"NewICS214DetailTVC merge that"])
            }
            DispatchQueue.main.async {
                self.nc.post(name: Notification.Name(rawValue: FJkRELOADTHELIST),
                             object: nil, userInfo: ["shift":MenuItems.ics214])
                
                self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID": self.theICS214OID as Any])
            }
            if !theICs214Forms.isEmpty {
            DispatchQueue.main.async {
                for log in self.theICs214Forms {
                    let id = log.objectID
                        self.nc.post(name: NSNotification.Name(rawValue: FJkMODIFIEDICS214FORM_TOCLOUDKIT), object: nil, userInfo:["objectID": id as Any])
                    }
                }
            }
        } catch let error as NSError {
            print("NewICS214DetailTVC line 236 Fetch Error: \(error.localizedDescription)")
        }
    }
    
    
}

extension ICS214EditHeaderVC: LabelSingleDateFieldCellDelegate {
    
    func singleDatePickerTapped(index: IndexPath, tag: Int, date: Date) {
        let row = index.row
        switch row {
        case 1:
            theICS214Form.ics214FromTime = date
        default: break
        }
    }
    
}


extension ICS214EditHeaderVC: LabelDateiPhoneTVCellDelegate {
    
    func theDatePickerTapped(_ theDate: Date, index: IndexPath) {
        let row = index.row
        switch row {
        case 1:
            theICS214Form.ics214FromTime = theDate
        default: break
        }
    }
    
}

extension ICS214EditHeaderVC:  LabelTextFieldCellDelegate {
    
    func incidentLabelTFEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func incidentLabelTFFinishedEditing(text: String, myShift: MenuItems, type: IncidentTypes) {
    }
    
    func labelTextFieldEditing(text: String, myShift: MenuItems) {
        
    }
    
    func labelTextFieldFinishedEditing(text: String, myShift: MenuItems, tag: Int) {
        theICS214Form.ics214IncidentName = text
    }
    
    func userInfoTextFieldEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
    func userInfoTextFieldFinishedEditing(text: String, myShift: MenuItems, journalType: JournalTypes) {
    }
    
}
