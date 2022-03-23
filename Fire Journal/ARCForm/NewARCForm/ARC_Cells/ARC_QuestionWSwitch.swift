//
//  ARC_QuestionWSwitch.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit


protocol ARC_QuestionSwitchDelegate: AnyObject {

    func theSwitchIsTapped(switchState: Bool,index: IndexPath, tag: Int)
    func theCompleteIsMarkedTrue(complete: Bool)
}

class ARC_QuestionWSwitch: UITableViewCell {

//  MARK: -OBJECTS-
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var noL: UILabel!
    @IBOutlet weak var yesL: UILabel!
    @IBOutlet weak var yesNoSwitch: UISwitch!
    
//    MARK: -PROPERTIES-
    
    var completed: Bool!
    
    weak var delegate: ARC_QuestionSwitchDelegate? = nil
    
    private var switchState:Bool = false
    var theSwitch: Bool? {
        didSet {
            self.switchState = self.theSwitch ?? false
            self.yesNoSwitch.isOn = self.switchState
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchTapped(_ sender: Any) {
            if yesNoSwitch.isOn {
                switchState = true
            } else {
                switchState = false
            }
        delegate?.theSwitchIsTapped(switchState: switchState, index: indexPath, tag: self.tag)
    }
}
