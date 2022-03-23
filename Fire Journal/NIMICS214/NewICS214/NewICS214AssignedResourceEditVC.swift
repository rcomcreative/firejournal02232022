//
//  NewICS214AssignedResourceEditVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/14/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol NewICS214AssignedResourceEditVCDelegate: AnyObject {
    func theCancelTapped()
    func theAssignedResourceEditSaveTapped(member: UserAttendees,path: IndexPath)
}

class NewICS214AssignedResourceEditVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: NewICS214AssignedResourceEditVCDelegate? = nil
    var alertUp: Bool = false
    
    private var crew: UserAttendees!
    var cMember: UserAttendees? {
        didSet {
            self.crew = self.cMember
        }
    }
    
    private var indexPath: IndexPath!
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(row: 0, section: 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        registerCells()
        roundViews()
    }
    
    func roundViews() {
        tableView.layer.cornerRadius = 20
        tableView.clipsToBounds = true
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "NewICS214LabelTextFieldCell",bundle: nil), forCellReuseIdentifier: "NewICS214LabelTextFieldCell")
    }
    
}

extension NewICS214AssignedResourceEditVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("NewICS214ResourceAssignedHeader", owner: self, options: nil)?.first as! NewICS214ResourceAssignedHeader
        headerV.delegate = self
        return headerV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewICS214LabelTextFieldCell", for: indexPath) as! NewICS214LabelTextFieldCell
        let tfCell = configureNewICS214LabelTextFieldCell(cell, at: indexPath, tag: tag)
        return tfCell
    }
    
    
}

extension NewICS214AssignedResourceEditVC {
    
    func configureNewICS214LabelTextFieldCell(_ cell: NewICS214LabelTextFieldCell, at indexPath: IndexPath, tag: Int)->NewICS214LabelTextFieldCell {
        cell.delegate = self
        cell.tag = tag
        switch tag {
        case 0:
            cell.label = "Name:"
            if let name = crew.attendee {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .words
            cell.path = indexPath
        case 1:
            cell.label = "ICS Position:"
            if let name = crew.attendeeICSPosition {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .words
            cell.path = indexPath
        case 2:
            cell.label = "Home Agency:"
            if let name = crew.attendeeHomeAgency {
                cell.described = name
            }
            cell.descriptionTF.autocapitalizationType = .allCharacters
            cell.path = indexPath
        case 3:
            cell.label = "Phone:"
            if let name = crew.attendeePhone {
                cell.described = name
            }
            cell.descriptionTF.keyboardType = .numbersAndPunctuation
            cell.path = indexPath
        case 4:
            cell.label = "Email:"
            if let name = crew.attendeeEmail {
                cell.described = name
            }
            cell.descriptionTF.keyboardType = .emailAddress
            cell.path = indexPath
        default:
            break
        }
        return cell
    }
}

extension NewICS214AssignedResourceEditVC: NewICS214LabelTextFieldCellDelegate {
    
    func theTextFieldHasChanged(text: String, indexPath: IndexPath, tag: Int) {
        let row = indexPath.row
        switch row {
        case 0:
            crew.attendee = text
        case 1:
            crew.attendeeICSPosition = text
        case 2:
            crew.attendeeHomeAgency = text
        case 3:
            crew.attendeePhone = text
        case 4:
            crew.attendeeEmail = text
        default: break
        }
    }
    
}

extension NewICS214AssignedResourceEditVC: NewICS214ResourceAssignedHeaderDelegate {
    func NewICS214ResourceAssignedHeaderCancelTapped() {
        delegate?.theCancelTapped()
    }
    
    func NewICS214ResourceAssignedHeaderSaveTapped() {
        let cellArray = [0,1,2,3,4]
        for c in cellArray {
                let indexPath = IndexPath(row: c, section: 0)
                let cell = self.tableView.cellForRow(at: indexPath) as! NewICS214LabelTextFieldCell
                _ = cell.textFieldShouldEndEditing(cell.descriptionTF)
        }
        delegate?.theAssignedResourceEditSaveTapped(member: crew, path: indexPath)
    }
    
    func NewICS214ResourceAssignedHeaderInfoTapped() {
        if !alertUp {
            presentAlert(info: "Info")
        }
    }
    
    func presentAlert(info: String ) {
        var message: InfoBodyText!
        var title: InfoBodyText!
        
        message = .ics214ResourceAssignedEditNotes
        title = .ics214ResourceAssignedEditSubject
        
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
