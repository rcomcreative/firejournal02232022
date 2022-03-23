//
//  StepperTFCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol StepperTFCellDelegate:class {
    func stepperTapped(count: String, section: Sections, indexPath: IndexPath)
    func stepperCompleted(complete: Bool)
}

class StepperTFCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var answerTF: UITextField!
    @IBOutlet weak var numStepper: UIStepper!
    var count:Double? {
        didSet {
            numStepper.value = self.count ?? 0
        }
    }
    var section:Sections!
    var indexPath: IndexPath!
    var completed: Bool = false
    
    weak var delegate:StepperTFCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        answerTF.text = ""
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func numStepperTapped(_ sender: Any) {
        if completed {
            let value:Double = numStepper.value
            let counter = String(format:"%g",value)
            delegate?.stepperTapped(count: counter, section: section, indexPath: indexPath)
        }  else {
           delegate?.stepperCompleted(complete: completed)
        }
        
        
    }
    
}
