//
//  IncidentTFwDirctionalSwitchCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/21/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentTFwDirectionalSwitchCellDelegate: AnyObject {
    func incidentDirectionalTapped(type: IncidentTypes,myShift:MenuItems)
    func incidentTFSwitchTapped(type: IncidentTypes,myShift:MenuItems)
}

class IncidentTFwDirectionalSwitchCell: UITableViewCell {

    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var directionalB: UIButton!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var defaultOvertimeL: UILabel!
    @IBOutlet weak var defaultOvertimeSwitch: UISwitch!
    weak var delegate:IncidentTFwDirectionalSwitchCellDelegate? = nil
    var incidentType:IncidentTypes!
    var myShift:MenuItems! = nil
    
    @IBAction func switchTapped(_ sender: Any) {
        delegate?.incidentTFSwitchTapped(type: incidentType,myShift:myShift)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    @IBAction func directionalBTapped(_ sender: Any) {
        delegate?.incidentTFSwitchTapped(type: incidentType,myShift:myShift)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
