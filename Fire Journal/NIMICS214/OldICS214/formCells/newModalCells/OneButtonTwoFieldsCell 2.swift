//
//  TwoButtonFourInputCell.swift
//  ARCForm
//
//  Created by DuRand Jones on 9/5/17.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol OneButtonTwoFieldCellDelegate: AnyObject {
    func bOneModalTapped(date: Date )
}

class OneButtonTwoFieldsCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var inputLabelOne: UILabel!
    @IBOutlet weak var inputLabelTwo: UILabel!
    @IBOutlet weak var inputTextFieldOne: UITextField!
    @IBOutlet weak var inputTextFieldTwo: UITextField!
    var dateTo: Date!
    var dateFrom: Date!
    
    weak var delegate: OneButtonTwoFieldCellDelegate? = nil
    
    @IBOutlet weak var cellButtonOne: UIButton!
    @IBAction func button1Tapped(_ sender: Any) {
        let date = Date()
        delegate?.bOneModalTapped(date: date)
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
