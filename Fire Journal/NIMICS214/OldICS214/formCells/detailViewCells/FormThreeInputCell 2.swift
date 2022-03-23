//
//  FormThreeInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 8/31/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ThreeFieldDelegate: AnyObject {
    func threeAnswersChosen(array: Array<Any>)
    func theAddButtonTapped()
}

class FormThreeInputCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var cellL: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputLabelThree: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    @IBOutlet weak var inputTextFieldThree: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    var fieldOne: String!
    var fieldTwo: String!
    var fieldThree: String!
    
    weak var delegate: ThreeFieldDelegate? = nil
    
    
    @IBAction func addButtonTapped(_ sender: Any) {
        delegate?.theAddButtonTapped()
//        print(Date())
//        let field1 = inputTextFieldOne.text
//        fieldTwo = inputTextFieldTwo.text
//        fieldThree = inputTextFieldThree.text
//        let a: [String?] = [field1,fieldTwo,fieldThree]
//        let b = a.flatMap{ $0 }
//        print(b)
//        delegate?.threeAnswersChosen(array: b)
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
