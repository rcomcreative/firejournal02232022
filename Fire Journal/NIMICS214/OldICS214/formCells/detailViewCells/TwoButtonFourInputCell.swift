//
//  TwoButtonFourInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/5/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit


protocol TwoButtonCellDelegate: AnyObject {

    func buttonOneTapped(date: Date )
    func buttonTwoTapped(date: Date )
}

class TwoButtonFourInputCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputLabelThree: UILabel!
    @IBOutlet weak var inputLabelFour: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    @IBOutlet weak var inputTextFieldThree: UITextField!
    @IBOutlet weak var inputTextFieldFour: UITextField!
    var dateTo: Date!
    var dateFrom: Date!
    
    weak var delegate: TwoButtonCellDelegate? = nil
    
    @IBOutlet weak var cellButtonOne: UIButton!
    @IBOutlet weak var cellButtonTwo: UIButton!
    @IBAction func button1Tapped(_ sender: Any) {
        let date = Date()
        delegate?.buttonOneTapped(date: date)
    }
    @IBAction func button2Tapped(_ sender: Any) {
        let date = Date()
        delegate?.buttonTwoTapped(date: date)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
