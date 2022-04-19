//
//  FormListModalVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/18/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol FormListModalVCDelegate: AnyObject {
    func formListModalCancelled()
    func formListModalChosen(type: IncidentTypes, index: IndexPath)
}

class FormListModalVC: UIViewController {
    
    weak var delegate: FormListModalVCDelegate? = nil
    
    var userID: NSManagedObjectID!
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    
    var headerTitle: String = """
Forms
"""
    var formModalHeaderV: ModalHeaderSaveDismiss!
    var formTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        roundViews()
        configureModalHeaderSaveDismiss()
        configureFormTableView()
    }
    

}

extension FormListModalVC {
    
    func roundViews() {
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
    }
    
    func configureModalHeaderSaveDismiss() {
        formModalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        formModalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(formModalHeaderV)
        formModalHeaderV.modalHTitleL.textColor = UIColor.white
        formModalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        formModalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        formModalHeaderV.modalHSaveB.setTitle("Save",for: .normal)
        formModalHeaderV.modalHSaveB.setTitleColor(UIColor.white, for: .normal)
        formModalHeaderV.modalHSaveB.isEnabled = false
        formModalHeaderV.modalHSaveB.isHidden = true
        formModalHeaderV.modalHSaveB.alpha = 0.0
        formModalHeaderV.modalHTitleL.text = headerTitle
        formModalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            formModalHeaderV.contentView.backgroundColor = color
        }
        formModalHeaderV.myShift = MenuItems.forms
        formModalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            formModalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            formModalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            formModalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            formModalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureFormTableView() {
        formTableView = UITableView(frame: .zero)
        registerCellsForTable()
        formTableView.translatesAutoresizingMaskIntoConstraints = false
        formTableView.backgroundColor = .systemBackground
        view.addSubview(formTableView)
        formTableView.delegate = self
        formTableView.dataSource = self
        formTableView.separatorStyle = .none
        
        formTableView.rowHeight = UITableView.automaticDimension
        formTableView.estimatedRowHeight = 300
        
        NSLayoutConstraint.activate([
            formTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            formTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            formTableView.topAnchor.constraint(equalTo: formModalHeaderV.bottomAnchor, constant: 5),
            formTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
        ])
    }
    
}

extension FormListModalVC: UITableViewDelegate {
    
    func registerCellsForTable() {
        formTableView.register(FormDescriptionTVCell.self, forCellReuseIdentifier: "FormDescriptionTVCell")
        formTableView.register(UINib(nibName: "LabelTextFieldCell", bundle: nil), forCellReuseIdentifier: "LabelTextFieldCell")
    }
    
}

extension FormListModalVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            if Device.IS_IPHONE {
                return 350
            } else {
            return 275
            }
        case 1:
            if Device.IS_IPHONE {
                return 350
            } else {
                return 275
            }
        default:
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "FormDescriptionTVCell", for: indexPath) as! FormDescriptionTVCell
            cell = configureFormDescriptionTVCell(cell, index: indexPath)
            return cell
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "FormDescriptionTVCell", for: indexPath) as! FormDescriptionTVCell
            cell = configureFormDescriptionTVCell(cell, index: indexPath)
            return cell
        default:
            var cell = tableView.dequeueReusableCell(withIdentifier: "LabelTextFieldCell", for: indexPath) as! LabelTextFieldCell
                cell = configureLabelTextFieldCell(cell, index: indexPath)
                return cell
        }
    }
    
    func configureFormDescriptionTVCell(_ cell: FormDescriptionTVCell, index: IndexPath) -> FormDescriptionTVCell {
        let row = index.row
        cell.tag = row
        cell.index = index
        cell.delegate = self
        switch row {
        case 0:
            cell.theType = IncidentTypes.ics214Form
        case 1:
            cell.theType = IncidentTypes.arcForm
        default: break
        }
        cell.configure()
        return cell
    }
    
    func configureLabelTextFieldCell(_ cell: LabelTextFieldCell, index: IndexPath) -> LabelTextFieldCell {
            cell.subjectL.isHidden = true
            cell.subjectL.alpha = 0.0
            cell.descriptionTF.isHidden = true
            cell.descriptionTF.isEnabled = false
            cell.descriptionTF.alpha = 0.0
        return cell
    }
    
}

extension FormListModalVC: ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalSave(myShift: MenuItems) {
        
    }
    
    func modalInfoBTapped(myShift: MenuItems) {
        print("info")
    }
    
    
}

extension FormListModalVC: FormDescriptionTVCellDelegate {
    
    func theFormChosen(type: IncidentTypes, index: IndexPath) {
        delegate?.formListModalChosen(type: type, index: index)
    }
    
    
}
