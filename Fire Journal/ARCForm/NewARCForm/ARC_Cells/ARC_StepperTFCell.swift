//
//  ARC_StepperTFCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit


protocol ARC_StepperTFCellDelegate: AnyObject {

    func stepperTapped(count: String, indexPath: IndexPath, tag: Int)
    func stepperCompleted(complete: Bool)
}

class ARC_StepperTFCell: UITableViewCell, UITextFieldDelegate {

//    MARK: -OBJECTS-
    @IBOutlet weak var questionL: UILabel!
    @IBOutlet weak var answerTF: UITextField!
    @IBOutlet weak var numStepper: UIStepper!
    
//    MARK: -PROPERTIES-
    private var counted: String = ""
    var count:Double? {
        didSet {
            self.numStepper.value = self.count ?? 0
            self.counted = String(format:"%g",self.numStepper.value)
            self.answerTF.text = self.counted
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    var completed: Bool = false
    
    weak var delegate:ARC_StepperTFCellDelegate? = nil
    
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
//        if completed {
            let value:Double = numStepper.value
            let counter = String(format:"%g",value)
        answerTF.text = counter
        delegate?.stepperTapped(count: counter, indexPath: indexPath,tag: self.tag )
//        }  else {
//           delegate?.stepperCompleted(complete: completed)
//        }
        
        
    }
    
}
