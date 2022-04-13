//
//  RankTVCell.swift
//  StationCommand
//
//  Created by DuRand Jones on 7/27/21.
//

import UIKit
import Foundation

protocol RankTVCellDelegate: AnyObject {
    func theButtonChoiceWasMade(_ text: String, index: IndexPath, tag: Int)
}

class RankTVCell: UITableViewCell {
    
    let newB = UIButton(primaryAction: nil)
    let theSubjectTF = UITextField()
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var type: IncidentTypes? = nil
    var isOfficer: Bool = false
    
    weak var delegate: RankTVCellDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        theSubjectTF.delegate = self
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
     
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension RankTVCell: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        delegate?.theButtonChoiceWasMade(text, index: indexPath, tag: self.tag)
        return true
    }
    
}

extension RankTVCell {
    
    func configureTheButton() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            switch type {
            case .rank, .theRanks:
                config.image = UIImage(systemName: "person.crop.square.fill.and.at.rectangle")
                config.title = " Rank"
            case .platoon:
                config.image = UIImage(systemName: "calendar")
                config.title = " Assigned Platoon"
            case .ems:
                config.image = UIImage(systemName: "person.crop.square.fill.and.at.rectangle")
                config.title = " EMS Certification"
            case .fireFighter:
                config.image = UIImage(systemName: "person.crop.square.fill.and.at.rectangle")
                config.title = " FF Certification"
            case .languages:
                config.image = UIImage(systemName: "figure.stand.line.dotted.figure.stand")
                config.title = " Languages"
            case .qualfications:
                config.image = UIImage(systemName: "q.square")
                config.title = " Qualifications"
            case .stationType:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Type of Station"
            case .leaveWork:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Leave work early"
            case .assignment:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Assignment"
            case .apparatus:
                config.image = UIImage(systemName: "car.2")
                config.title = " Apparatus"
            default: break
            }
            switch type {
            case .rank, .platoon, .ems, .fireFighter, .languages, .qualfications, .assignment, .apparatus, .theRanks:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            case .leaveWork:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            case .stationType:
                config.baseBackgroundColor = UIColor(named: "FJIconRed")
            default: break
            }
            config.baseForegroundColor = .white
            newB.configuration = config
            
            
            let theClosure = {(action: UIAction) in
                self.theButtonMenuChange(action.title)
            }
            
            switch type {
            case .rank:
                if isOfficer {
                    newB.menu = UIMenu(children: [
                        UIAction(title: "Lieutenant", handler: theClosure),
                           UIAction(title: "Captain", handler: theClosure),
                        UIAction(title: "EMS Supervisor", handler: theClosure),
                        UIAction(title: "Battalion Chief", handler: theClosure),
                        UIAction(title: "Assistant Chief", handler: theClosure),
                        UIAction(title: "Deputy Chief", handler: theClosure),
                        UIAction(title: "Deputy EMS Chief", handler: theClosure),
                        UIAction(title: "Assistant Deputy Chief", handler: theClosure),
                        UIAction(title: "Chief Deputy", handler: theClosure),
                           UIAction(title: "Commissioner", handler: theClosure),
                           UIAction(title: "Fire Commissioner", handler: theClosure),
                        ])
                } else {
                    newB.menu = UIMenu(children: [
                        UIAction(title: "FireFighter", handler: theClosure),
                        UIAction(title: "Volunteer Firefighter", handler: theClosure),
                        UIAction(title: "Firefighter/EMT", handler: theClosure),
                        UIAction(title: "Firefighter/Paramedic", handler: theClosure),
                        UIAction(title: "EMT", handler: theClosure),
                        UIAction(title: "Paramedic", handler: theClosure),
                        UIAction(title: "Inspector", handler: theClosure),
                        UIAction(title: "Chauffeur", handler: theClosure),
                        UIAction(title: "Apparatus Operator", handler: theClosure),
                        UIAction(title: "Engineer / Driver", handler: theClosure),
                        ])
                }
            case .theRanks:
                newB.menu = UIMenu(children: [
                    UIAction(title: "Lieutenant", handler: theClosure),
                       UIAction(title: "Captain", handler: theClosure),
                    UIAction(title: "EMS Supervisor", handler: theClosure),
                    UIAction(title: "Battalion Chief", handler: theClosure),
                    UIAction(title: "Assistant Chief", handler: theClosure),
                    UIAction(title: "Deputy Chief", handler: theClosure),
                    UIAction(title: "Deputy EMS Chief", handler: theClosure),
                    UIAction(title: "Assistant Deputy Chief", handler: theClosure),
                    UIAction(title: "Chief Deputy", handler: theClosure),
                       UIAction(title: "Commissioner", handler: theClosure),
                       UIAction(title: "Fire Commissioner", handler: theClosure),
                    UIAction(title: "FireFighter", handler: theClosure),
                    UIAction(title: "Volunteer Firefighter", handler: theClosure),
                    UIAction(title: "Firefighter/EMT", handler: theClosure),
                    UIAction(title: "Firefighter/Paramedic", handler: theClosure),
                    UIAction(title: "EMT", handler: theClosure),
                    UIAction(title: "Paramedic", handler: theClosure),
                    UIAction(title: "Inspector", handler: theClosure),
                    UIAction(title: "Chauffeur", handler: theClosure),
                    UIAction(title: "Apparatus Operator", handler: theClosure),
                    UIAction(title: "Engineer / Driver", handler: theClosure),
                    ])
            case .apparatus:
                newB.menu = UIMenu(children: [
                    UIAction(title: "Air Ambulance", handler: theClosure),
                    UIAction(title: "Battalion Sedan", handler: theClosure),
                    UIAction(title: "Bike Team", handler: theClosure),
                    UIAction(title: "Brush Truck", handler: theClosure),
                    UIAction(title: "Chief Officer", handler: theClosure),
                    UIAction(title: "Command Vehicle", handler: theClosure),
                    UIAction(title: "Communications Unit", handler: theClosure),
                    UIAction(title: "Engine", handler: theClosure),
                    UIAction(title: "Fire Boat", handler: theClosure),
                    UIAction(title: "Gator", handler: theClosure),
                    UIAction(title: "Haz Mat", handler: theClosure),
                    UIAction(title: "Helicopter", handler: theClosure),
                    UIAction(title: "Ladder Truck", handler: theClosure),
                    UIAction(title: "Mobile Command Post", handler: theClosure),
                    UIAction(title: "Mobile Repair Unit", handler: theClosure),
                    UIAction(title: "Plug Buggy", handler: theClosure),
                    UIAction(title: "Quint", handler: theClosure),
                    UIAction(title: "Rehabilitation Unit", handler: theClosure),
                    UIAction(title: "Rescue Ambulance", handler: theClosure),
                    UIAction(title: "SUV", handler: theClosure),
                    UIAction(title: "Swift Water Rescue", handler: theClosure),
                    UIAction(title: "Tractor", handler: theClosure),
                    UIAction(title: "Tunnel Rescue", handler: theClosure),
                    UIAction(title: "US R", handler: theClosure),
                ])
            case .platoon:
                newB.menu = UIMenu(children: [
                       UIAction(title: "A Platoon", handler: theClosure),
                       UIAction(title: "B Platoon", handler: theClosure),
                       UIAction(title: "C Platoon", handler: theClosure),
                       UIAction(title: "D Platoon", handler: theClosure)
                   ])
            case .ems:
                newB.menu = UIMenu(children: [
                       UIAction(title: "NONE", handler: theClosure),
                       UIAction(title: "EMT", handler: theClosure),
                       UIAction(title: "PARAMEDIC", handler: theClosure),
                       UIAction(title: "PHYSICIAN’S ASSISTANT", handler: theClosure),
                       UIAction(title: "NURSE", handler: theClosure),
                       UIAction(title: "PHYSICIAN", handler: theClosure),
                   ])
            case .fireFighter:
                newB.menu = UIMenu(children: [
                       UIAction(title: "Firefighter I", handler: theClosure),
                       UIAction(title: "Firefighter II", handler: theClosure),
                       UIAction(title: "Firefighter III", handler: theClosure),
                   ])
            case .languages:
                    newB.menu = UIMenu(children: [
                        UIAction(title: "English", handler: theClosure),
                        UIAction(title: "Spanish", handler: theClosure),
                        UIAction(title: "Korean", handler: theClosure),
                        UIAction(title: "German", handler: theClosure),
                        UIAction(title: "French", handler: theClosure),
                        UIAction(title: "Chinese", handler: theClosure),
                        UIAction(title: "Russian", handler: theClosure),
                        ])
            case .qualfications:
                newB.menu = UIMenu(children: [
                    UIAction(title: "FF-III", handler: theClosure),
                    UIAction(title: "FFPM", handler: theClosure),
                    ])
            case .stationType:
                newB.menu = UIMenu(children: [
                    UIAction(title: "Single Engine and EMS", handler: theClosure),
                    UIAction(title: "EMS Only", handler: theClosure),
                    UIAction(title: "Engine, Truck, EMS", handler: theClosure),
                    UIAction(title: "Specialty", handler: theClosure),
                    UIAction(title: "Battalion", handler: theClosure),
                ])
            case .leaveWork:
                newB.menu = UIMenu(children: [
                    UIAction(title: "Sick", handler: theClosure),
                    UIAction(title: "Family", handler: theClosure),
                    UIAction(title: "Personal", handler: theClosure),
                    UIAction(title: "Other", handler: theClosure),
                ])
            case .assignment:
                newB.menu = UIMenu(children: [
                    UIAction(title: "Aide/Staff Assistant/Emergency Incident Technician", handler: theClosure),
                    UIAction(title: "Apparatus Operator / Chauffer", handler: theClosure),
                    UIAction(title: "Attendant", handler: theClosure),
                    UIAction(title: "Bureau Commander", handler: theClosure),
                    UIAction(title: "Company Commander", handler: theClosure),
                    UIAction(title: "Battalion Commander", handler: theClosure),
                    UIAction(title: "Division Commander", handler: theClosure),
                    UIAction(title: "Chief Officer", handler: theClosure),
                    UIAction(title: "Driver", handler: theClosure),
                    UIAction(title: "Engine", handler: theClosure),
                    UIAction(title: "Engineer", handler: theClosure),
                    UIAction(title: "Hydrant", handler: theClosure),
                    UIAction(title: "Inside Man", handler: theClosure),
                    UIAction(title: "Nozzle", handler: theClosure),
                    UIAction(title: "Rescue Ambulance", handler: theClosure),
                    UIAction(title: "Special Duty", handler: theClosure),
                    UIAction(title: "Temporary Assignment", handler: theClosure),
                    UIAction(title: "Tiller", handler: theClosure),
                    UIAction(title: "Top Man", handler: theClosure),
                    UIAction(title: "Truck", handler: theClosure),
                ])
            default: break
            }
            
            newB.showsMenuAsPrimaryAction = true
            newB.translatesAutoresizingMaskIntoConstraints = false
            theSubjectTF.translatesAutoresizingMaskIntoConstraints = false
            
            self.contentView.addSubview(newB)
            self.contentView.addSubview(theSubjectTF)
            
            switch type {
            case .platoon:
                theSubjectTF.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
                if theSubjectTF.text == "D Platoon" {
                theSubjectTF.textColor = UIColor(named: "FJOrangeColor")
                } else if theSubjectTF.text == "C Platoon" {
                    theSubjectTF.textColor = UIColor(named: "FJGreenColor")
                } else if theSubjectTF.text == "B Platoon" {
                    theSubjectTF.textColor = UIColor(named: "FJBlueColor")
                } else if theSubjectTF.text == "A Platoon" {
                    theSubjectTF.textColor = UIColor(named: "FJRedColor")
                }
            default:
                theSubjectTF.font = .systemFont(ofSize: 22)
                theSubjectTF.textColor = .label
            }
            
            
            if Device.IS_IPHONE {
                NSLayoutConstraint.activate([
                    
                    newB.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
                    newB.widthAnchor.constraint(equalToConstant: 279),
                    newB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 26),
                    newB.heightAnchor.constraint(equalToConstant: 45),
                    
                    theSubjectTF.topAnchor.constraint(equalTo: newB.bottomAnchor, constant: 10),
                    theSubjectTF.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -35),
                    theSubjectTF.leadingAnchor.constraint(equalTo: newB.leadingAnchor),
                    theSubjectTF.heightAnchor.constraint(equalToConstant: 24),
                    ])
            } else {
            NSLayoutConstraint.activate([
                theSubjectTF.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                theSubjectTF.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -35),
                
                newB.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                newB.trailingAnchor.constraint(equalTo: self.theSubjectTF.leadingAnchor, constant: -35),
                newB.widthAnchor.constraint(equalToConstant: 279),
                newB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 26),
                newB.heightAnchor.constraint(equalToConstant: 45),
                ])
            }
        }
    }
    
    func theButtonMenuChange(_ title: String) {
        if type == .leaveWork {
            theSubjectTF.text = title
        }
        delegate?.theButtonChoiceWasMade(title, index: indexPath, tag: self.tag)
    }
    
}
