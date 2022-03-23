//
//  ResourceVC.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/3/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ResourceVCDelegate: AnyObject {
    func resourceSaveTapped(resource: UserFDResource,row: Int)
    func resourceCancelTapped()
}

class ResourceVC: UIViewController {
    
    //    MARK: -OBJECTS-
    @IBOutlet weak var tableView: UITableView!
    
    //    MARK: -PROPERTIES-
    var row: Int = 0
    var alertUp: Bool = false
    weak var delegate: ResourceVCDelegate? = nil
    var type: Int64 = 0002
    var imageName: String = "GreenAvailable"
    var iconImageName: String = ""
    var resource: UserFDResource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        roundViews()
        registerCells()
        switch resource.resourceType {
        case 0002:
            imageName = "GreenAvailable"
        case 0003:
            imageName = "YellowConditional"
        case 0004:
            imageName = "BlackOutOfService"
        default:
            break
        }
        iconImageName = resource?.resource ?? ""
    }
    
    func roundViews() {
        tableView.layer.cornerRadius = 20
        tableView.clipsToBounds = true
    }
    
    fileprivate func registerCells() {
        tableView.register(UINib(nibName: "ResourceSegmentTVCell", bundle: nil), forCellReuseIdentifier: "ResourceSegmentTVCell")
        tableView.register(UINib(nibName: "ResourceLabelTextFieldTVCell", bundle: nil), forCellReuseIdentifier: "ResourceLabelTextFieldTVCell")
        tableView.register(UINib(nibName: "ResourceLabelTextViewTVCell", bundle: nil), forCellReuseIdentifier: "ResourceLabelTextViewTVCell")
        tableView.register(UINib(nibName: "ResourcePersonnelCountTVCell", bundle: nil), forCellReuseIdentifier: "ResourcePersonnelCountTVCell")
        tableView.register(UINib(nibName: "LabelCell", bundle: nil), forCellReuseIdentifier: "LabelCell")
    }
    
    
}

extension ResourceVC: ResourceHeaderDelegate {
    func resourceSaveBTapped() {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath) as! ResourcePersonnelCountTVCell
        _ = cell.textFieldShouldEndEditing(cell.personnelNumberTF)
        let cellArray3 = [2,3,4,5,6,7,8]
        for c in cellArray3 {
            var indexPath: IndexPath!
            if c == 8 {
                indexPath = IndexPath(row:c, section: 0)
                let cell = self.tableView.cellForRow(at: indexPath) as! ResourceLabelTextViewTVCell
                _ = cell.textViewShouldEndEditing(cell.subjectTV)
            } else {
                let indexPath = IndexPath(row: c, section: 0)
                let cell = self.tableView.cellForRow(at: indexPath) as! ResourceLabelTextFieldTVCell
                _ = cell.textFieldShouldEndEditing(cell.subjectTF)
            }
        }
        delegate?.resourceSaveTapped(resource: resource,row: row)
    }
    
    func resourceCancelBTapped() {
        delegate?.resourceCancelTapped()
    }
    
    func resourceInfoBTapped() {
        if !alertUp {
            presentAlert()
        }
    }
    
    func presentAlert() {
        let title: InfoBodyText = .resourceSupportNotesSubject
        let message: InfoBodyText = .resourceSupportNotes
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    func moveTheView(orientation: Int) {
        if Device.IS_IPHONE {
            //            if orientation == 3 || orientation == 4 {
            //                let frame = self.tableView.frame
            //                let frame.orgin.y =
            //                UIView.animate(withDuration: 0.2, animations: {
            //
            //                })
            //            }
        }
    }
    
    
}

extension ResourceVC: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    // MARK: - Table view data source// MARK: - Table View
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = Bundle.main.loadNibNamed("ResourceHeader", owner: self, options: nil)?.first as! ResourceHeader
        headerV.delegate = self
        headerV.resourceStatusIV.image = UIImage(named: imageName)
        if resource?.custom != false {
            headerV.resourceIconIV.image = UIImage(named: "RESOURCEWHITE")
            headerV.resourceCustomL.text = resource?.resource
        } else {
            headerV.resourceIconIV.image = UIImage(named: resource!.resource)
        }
        //        headerV.resourceInfoB.tintColor = UIColor.white
        return headerV
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 110
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row = indexPath.row
        switch row {
        case 8:
            return 110
        case 9:
            return 200
        default:
            if Device.IS_IPAD {
                return 38
            } else {
                return 38
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceSegmentTVCell", for: indexPath) as! ResourceSegmentTVCell
            cell.delegate = self
            if resource != nil {
                switch resource?.resourceType {
                case 0002:
                    cell.resourceSegment.selectedSegmentIndex = 0
                case 0003:
                    cell.resourceSegment.selectedSegmentIndex = 1
                case 0004:
                    cell.resourceSegment.selectedSegmentIndex = 2
                default: break
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourcePersonnelCountTVCell", for: indexPath) as! ResourcePersonnelCountTVCell
            cell.subjectL.text = "Positions:"
            cell.personnelNumberTF.keyboardType = .numbersAndPunctuation
            if let count = resource?.resourcePersonnelCount {
                cell.personnelNumberTF.text = String(count)
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "Year:"
            cell.subjectTF.keyboardType = .numbersAndPunctuation
            if let year = resource?.resourceYear {
                cell.subjectTF.text = year
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "Manufacturer:"
            cell.subjectTF.keyboardType = .default
            if let manufacturer = resource?.resourceManufacturer {
                cell.subjectTF.text = manufacturer
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "ID:"
            cell.subjectTF.keyboardType = .default
            if let id = resource?.resourceID {
                cell.subjectTF.text = id
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "Shop Number:"
            cell.subjectTF.keyboardType = .default
            if let number = resource?.resourceShopNumber {
                cell.subjectTF.text = number
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "Apparatus:"
            cell.subjectTF.keyboardType = .default
            if let apparatus = resource?.resourceApparatus {
                cell.subjectTF.text = apparatus
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextFieldTVCell", for: indexPath) as! ResourceLabelTextFieldTVCell
            cell.subjectL.text = "Specialities:"
            cell.subjectTF.keyboardType = .default
            if let speciality = resource?.resourceSpecialities {
                cell.subjectTF.text = speciality
            }
            cell.row = row
            cell.delegate = self
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceLabelTextViewTVCell", for: indexPath) as! ResourceLabelTextViewTVCell
            cell.subjectL.text = "Description:"
            if let description = resource?.resourceDescription {
                cell.subjectTV.text = description
            }
            cell.delegate = self
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
            cell.modalTitleL.text = ""
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
            return cell
        }
    }
}

extension ResourceVC: ResourceLabelTextViewTVCellDelegate {
    func ResourceTextViewEditing(text: String) {
        resource.resourceDescription = text
    }
    
    func ResourceTextViewEnded(text: String) {
        let indexPath = IndexPath(row: 7, section: 0)
        resource.resourceDescription = text
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
}

extension ResourceVC: ResourceLabelTextFieldTVCellDelegate {
    
    func resourceTFStartedEditing(text: String, row: Int) {
        //        let indexPath = IndexPath(row: row, section: 0)
        switch row {
        case 2:
            resource.resourceYear = text
        case 3:
            resource.resourceManufacturer = text
        case 4:
            resource.resourceID = text
        case 5:
            resource.resourceShopNumber = text
        case 6:
            resource.resourceApparatus = text
        case 7:
            resource.resourceSpecialities = text
        default: break
        }
    }
    
    func resourceTFEndedEditing(text: String, row: Int) {
        //        let indexPath = IndexPath(row: row, section: 0)
        switch row {
        case 2:
            resource.resourceYear = text
        case 3:
            resource.resourceManufacturer = text
        case 4:
            resource.resourceID = text
        case 5:
            resource.resourceShopNumber = text
        case 6:
            resource.resourceApparatus = text
        case 7:
            resource.resourceSpecialities = text
        default: break
        }
    }
    
    
}

extension ResourceVC: ResourceSegmentTVCellDelegate {
    func resourceSegmentTapped(type: Int64, imageName: String) {
        self.type = type
        self.imageName = imageName
        resource.resourceStatusImageName = imageName
        resource.resourceType = type
        tableView.reloadData()
    }
    
    
}

extension ResourceVC: ResourcePersonnelCountTVCellDelegate {
    func resourcePersonnelStartedEditing(text: String, row: Int) {
        resource.resourcePersonnelCount = Int64(text) ?? 0
    }
    
    func resourcePersonnelEndedEditing(text: String, row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        resource.resourcePersonnelCount = Int64(text) ?? 0
        //        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}
