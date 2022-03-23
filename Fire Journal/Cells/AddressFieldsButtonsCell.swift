//
//  AddressFieldsButtonsCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol AddressFieldsButtonsCellDelegate: AnyObject {
    func worldBTapped()
    func locationBTapped()
    func addressHasBeenFinished()
    func addressFieldFinishedEditing(address: String, tag: Int)
}

class AddressFieldsButtonsCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var locationB: UIButton!
    @IBOutlet weak var mapB: UIButton!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var addressLatitudeTF: UITextField!
    @IBOutlet weak var addressLongitudeTF: UITextField!
    
    //    MARK: -PROPERTIES
    var myShift: MenuItems! = nil
    weak var delegate:AddressFieldsButtonsCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
    
    //    MARK: - button actions
    @IBAction func locationBTapped(_ sender: Any) {
        delegate?.locationBTapped()
    }
    @IBAction func worldBTapped(_ sender: Any) {
        delegate?.worldBTapped()
    }
    
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(textField.text ?? "nothing to see here")
        let tag = textField.tag
        let address = textField.text ?? ""
        delegate?.addressFieldFinishedEditing(address: address, tag:tag )
    }
    
}
