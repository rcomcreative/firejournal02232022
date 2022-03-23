//
//  LabelInstructionWSwitchCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/22/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol LabelInstructionWSwitchDelegate: AnyObject {
    func onOffSwitchWasTapped(type:MenuItems,yesNoB:Bool)
}

class LabelInstructionWSwitchCell: UITableViewCell {

    @IBOutlet weak var onOffSwitch: UISwitch!
    @IBOutlet weak var onOffL: UILabel!
    @IBOutlet weak var instructionL: UILabel!
    var type: MenuItems!
    
    var switchOnOff: Bool = false
    var age = 1
    
    weak var delegate:LabelInstructionWSwitchDelegate? = nil
    
    @IBAction func onOffSwitchTapped(_ sender: UISwitch) {
        if switchOnOff {
            switchOnOff = false
        } else {
            switchOnOff = true
        }
        delegate?.onOffSwitchWasTapped(type: type,yesNoB: switchOnOff)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
    
}
