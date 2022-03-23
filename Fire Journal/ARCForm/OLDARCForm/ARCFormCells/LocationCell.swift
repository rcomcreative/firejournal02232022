//
//  locationCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol LocationCellDelegate:class {
    func theLocationBTapped()
    func theMapButtonTapped()
    func theTextFieldOnLocationCTyped(textLocation:[ String : String ])
    func theTextFieldOnLocationComplete(complete: Bool)
}

class LocationCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var mapB: UIButton!
    @IBOutlet weak var locationB: UIButton!
    @IBOutlet weak var streetAddressL: UILabel!
    @IBOutlet weak var apartSuiteL: UILabel!
    @IBOutlet weak var cityL: UILabel!
    @IBOutlet weak var stateL: UILabel!
    @IBOutlet weak var zipL: UILabel!
    @IBOutlet weak var streetAddressTF: UITextField!
    @IBOutlet weak var apartSuiteTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    
    var cellType: CellType!
    var section: Sections!
    var complete: Bool!
    
    weak var delegate:LocationCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mapBTapped(_ sender: Any) {
        delegate?.theMapButtonTapped()
    }
    
    @IBAction func locaitonBTapped(_ sender: Any) {
        delegate?.theLocationBTapped()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if complete {} else {
            delegate?.theTextFieldOnLocationComplete(complete: complete)
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.theTextFieldOnLocationCTyped(textLocation:[ "Address" : streetAddressTF.text ?? "", "City" : cityTF.text ?? "", "State" : stateTF.text ?? "", "Zip" : zipTF.text ?? "", "AptSuite" : apartSuiteTF.text ?? "" ])
        return true
    }
    
}
