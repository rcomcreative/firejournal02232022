//
//  questionWSwitch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol QuestionSwitchDelegate:class {
    func theSwitchIsTapped(switchState:Bool,section:Sections)
    func theCompleteIsMarkedTrue(complete: Bool)
}

class QuestionWSwitch: UITableViewCell {

    
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var noL: UILabel!
    @IBOutlet weak var yesL: UILabel!
    @IBOutlet weak var yesNoSwitch: UISwitch!
    var switchState:Bool = false
    var section: Sections!
    var completed: Bool!
    
    weak var delegate:QuestionSwitchDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchTapped(_ sender: Any) {
        if completed {
            if yesNoSwitch.isOn {
                switchState = true
            } else {
                switchState = false
            }
            delegate?.theSwitchIsTapped(switchState: switchState,section: section)
        } else {
            delegate?.theCompleteIsMarkedTrue(complete: completed)
        }
    }
}
