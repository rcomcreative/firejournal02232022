//
//  LabelYesNoSwitchCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/14/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol LabelYesNoSwitchCellDelegate: AnyObject {
    func labelYesNoSwitchTapped(theShift:MenuItems,yesNoB:Bool,type:IncidentTypes)
}

class LabelYesNoSwitchCell: UITableViewCell {

    //    MARK: -Objects
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var leftL: UILabel!
    @IBOutlet weak var rightL: UILabel!
    @IBOutlet weak var yesNotSwitch: UISwitch!
    
    //    MARK: -Properties
    var myShift:MenuItems!
    var yesNoB:Bool = false
    var rightText:String = "Yes"
    var leftText:String = "No"
    var incidentType:IncidentTypes!
    weak var delegate:LabelYesNoSwitchCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        leftL.text = leftText
        rightL.text = rightText
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //    MARK: -Button actions
    @IBAction func switchTapped(_ sender: Any) {
        if yesNotSwitch.isOn {
            yesNoB = true
        } else {
            yesNoB = false
        }
        delegate?.labelYesNoSwitchTapped(theShift: myShift,yesNoB: yesNoB,type:incidentType)
    }
    
}
