//
//  EfforWithoutDateCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 10/24/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol EffortDelegate: AnyObject {
    func newFormWithTwoStrings(type: TypeOfForm, name1: String, name2: String )
}

class EfforWithoutDateCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var question1L: UILabel!
    @IBOutlet weak var question2L: UILabel!
    @IBOutlet weak var question1TF: UITextField!
    @IBOutlet weak var question2TF: UITextField!
    @IBOutlet weak var continueB: UIButton!
    var type:TypeOfForm!
    
    weak var delegate: EffortDelegate? = nil
    @IBOutlet weak var instructionL: UILabel!
    
    @IBAction func continueBTapped(_ sender: Any) {
        var team:String = ""
        var fireName:String = ""
        if let name = question1TF.text {
            team = name
        }
        if let fire = question2TF.text {
            fireName = fire
        }
        delegate?.newFormWithTwoStrings(type: type, name1: team, name2: fireName)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        continueB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
