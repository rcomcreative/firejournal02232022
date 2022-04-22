//
//  MultipleAddButtonTVCell.swift
//  MultipleAddButtonTVCell
//
//  Created by DuRand Jones on 8/31/21.
//

import UIKit
import Foundation

protocol MultipleAddButtonTVCellDelegate: AnyObject {
    func multiAddBTapped(type: IncidentTypes, index: IndexPath)
    func multiTitleChosen(type: IncidentTypes, title: String, index: IndexPath)
}

class MultipleAddButtonTVCell: UITableViewCell {
    
    let newB = UIButton(primaryAction: nil)
    let subjectL = UILabel()
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var type: IncidentTypes!
    
    weak var delegate: MultipleAddButtonTVCellDelegate? = nil
    
    private var theBackgroundColor: String = "FJBlue"
    var aBackgroundColor: String = "" {
        didSet {
            self.theBackgroundColor = self.aBackgroundColor
        }
    }
    
    private var theChoice: String = ""
    var aChoice: String = "" {
        didSet {
            self.theChoice = self.aChoice
            self.subjectL.text = self.theChoice
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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

extension MultipleAddButtonTVCell {
    
    func configureTheButton() {
        
        subjectL.textColor = .label
        subjectL.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        self.selectionStyle = .none
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            switch type {
            case .fdid:
                config.image = UIImage(systemName: "list.bullet.rectangle.portrait")
                config.title = " FDID"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .education:
                config.image = UIImage(systemName: "pencil.circle")
                config.title = " Education"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .languages:
                config.image = UIImage(systemName: "list.bullet.rectangle")
                config.title = " Languages"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .qualfications:
                config.image = UIImage(systemName: "list.bullet.rectangle")
                config.title = " Qualfications"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .specialities:
                config.image = UIImage(systemName: "list.bullet.rectangle")
                config.title = " Specialities"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .extrasklls:
                config.image = UIImage(systemName: "list.bullet.rectangle")
                config.title = " Extra Curicullar Skills"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .children:
                config.image = UIImage(systemName: "person.2")
                config.title = " Children"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .otherCerts:
                config.image = UIImage(systemName: "list.bullet.rectangle")
                config.title = " Certificates"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .manditoryTraining:
                config.image = UIImage(systemName: "list.bullet.rectangle.portrait")
                config.title = " Scheduled Training"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .vaccinated:
                config.image = UIImage(systemName: "pills")
                config.title = " Vaccinated"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .injuries:
                config.image = UIImage(systemName: "heart.text.square")
                config.title = " Injuries"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .medicalNotes:
                config.image = UIImage(systemName: "pencil.circle")
                config.title = " Medical Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .officerNotes:
                config.image = UIImage(systemName: "pencil.circle")
                config.title = " Officer Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .assignment:
                config.image = UIImage(systemName: "list.bullet.circle.fill")
                config.title = " Assignment"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .crew:
                config.image = UIImage(systemName: "person.crop.circle.badge.plus")
                config.title = " Crew Working"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .deptMember:
                config.image = UIImage(systemName: "person.badge.clock.fill")
                config.title = " Relieving"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .supervisor:
                config.image = UIImage(systemName: "person.badge.clock.fill")
                config.title = " Supervisor"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .apparatus:
                config.image = UIImage(systemName: "car.2.fill")
                config.title = " Apparatus Status"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .platoonPriorities:
                config.image = UIImage(systemName: "list.bullet.rectangle.fill")
                config.title = " Platoon Priorities"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .stationPriorities:
                config.image = UIImage(systemName: "list.bullet.rectangle.fill")
                config.title = " Station Priorities"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .shiftNotes:
                config.image = UIImage(systemName: "note.text.badge.plus")
                config.title = " Shift Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .startShiftNotes:
                config.image = UIImage(systemName: "note.text.badge.plus")
                config.title = " Start Shift Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .endShiftNotes:
                config.image = UIImage(systemName: "note.text.badge.plus")
                config.title = " End Shift Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .tags:
                config.image = UIImage(systemName: "tag.circle")
                config.title = " Tags"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .allIncidents:
                config.image = UIImage(systemName: "car.2.fill")
                config.title = " Fire/EMS Resources"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .nfirsIncidentType:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Incident Type"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .localIncidentType:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Local Incident Type"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .locationType:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Location Type"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .streetType:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Street Type"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .streetPrefix:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Street Prefix"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .firstAction:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Actions #1"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .secondAction:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Actions #2"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .thirdAction:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " NFIRS Actions #3"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .alarm:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Alarm Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .arrival:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Arrival Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .controlled:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Controlled Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .lastunitstanding:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Last Unit Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .incidentNote:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Incident Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .apparatusAssignedPositions:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Assigned Positions"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .apparatusNotes:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Apparatus Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .apparatusMilage:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Apparatus Mileage"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .apparatusMaintenance:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Apparatus Maintenance"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .fdid:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " FDID"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .leaveWork:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Leave Work Early"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .incidentPhoto:
                config.image = UIImage(systemName: "camera.circle")
                config.title = " Photos"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .overview:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Overview Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .discussion:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Discussion Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .nextSteps:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Next Steps Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .summary:
                config.image = UIImage(systemName: "list.bullet.circle")
                config.title = " Summary Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .theProjectOverview:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Project Overview"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .theProjectClassNote:
                config.image = UIImage(systemName: "square.and.pencil")
                config.title = " Project Notes"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            default: break
            }
            config.baseForegroundColor = .white
            newB.configuration = config
            
            newB.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            newB.translatesAutoresizingMaskIntoConstraints = false
            
            subjectL.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(newB)
            self.contentView.addSubview(subjectL)
            
            NSLayoutConstraint.activate([
                subjectL.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                subjectL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -35),
                
                newB.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                newB.widthAnchor.constraint(equalToConstant: 335),
                newB.trailingAnchor.constraint(equalTo: self.subjectL.leadingAnchor, constant: -35),
                newB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 26),
                newB.heightAnchor.constraint(equalToConstant: 45),
            ])
        }
    }
    
    @objc func buttonTapped() {
        delegate?.multiAddBTapped(type: type, index: indexPath)
    }
    
    @objc func theButtonMenuChange(_ title: String ) {
        delegate?.multiTitleChosen(type: type, title: title, index: indexPath)
    }

    
    
}
    

