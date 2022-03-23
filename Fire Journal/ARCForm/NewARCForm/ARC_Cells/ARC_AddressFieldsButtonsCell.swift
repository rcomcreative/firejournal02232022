//
//  ARC_AddressFieldsButtonsCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit


protocol ARC_AddressFieldsButtonsCellDelegate: AnyObject {

    func worldBTapped(index: IndexPath)
    func locationBTapped()
    func addressHasBeenFinished()
    func addressFieldFinishedEditing(address: String, tag: Int)
}

class ARC_AddressFieldsButtonsCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var locationB: UIButton!
    @IBOutlet weak var mapB: UIButton!
    @IBOutlet weak var streetNameTF: UITextField!
    @IBOutlet weak var streetNumTF: UITextField!
    @IBOutlet weak var aptMobileNumberTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var addressLatitudeTF: UITextField!
    @IBOutlet weak var addressLongitudeTF: UITextField!
    
    //    MARK: -PROPERTIES
    var myShift: MenuItems! = nil
    weak var delegate:ARC_AddressFieldsButtonsCellDelegate? = nil
    
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
        delegate?.worldBTapped(index: indexPath)
    }
    
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            let tag = textField.tag
            delegate?.addressFieldFinishedEditing(address: text, tag:tag )
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       if let text = textField.text {
            let tag = textField.tag
            delegate?.addressFieldFinishedEditing(address: text, tag:tag )
        }
    }
    
}
