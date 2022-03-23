//
//  DoubleSignatureCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol DoubleSignatureCellDelegate:class {
    func residentSigTapped()
    func installerSigTapped()
    func theTextFieldOnSignatureTyped(textNames:[ String : String ])
    func theTextFieldOnSignatureComplete(complete: Bool )
}

class DoubleSignatureCell: UITableViewCell,UITextFieldDelegate {
    @IBOutlet weak var residentNameTF: UITextField!
    @IBOutlet weak var residentNameL: UILabel!
    @IBOutlet weak var residentDateTF: UITextField!
    @IBOutlet weak var residentDateL: UILabel!
    @IBOutlet weak var residentSigB: UIButton!
    @IBOutlet weak var residentSigIV: UIImageView!
    @IBOutlet weak var installerNameTF: UITextField!
    @IBOutlet weak var installerNameL: UILabel!
    @IBOutlet weak var installerDateTF: UITextField!
    @IBOutlet weak var installerDateL: UILabel!
    @IBOutlet weak var installerSigB: UIButton!
    @IBOutlet weak var installerSigIV: UIImageView!
    var complete: Bool!
    
    weak var delegate:DoubleSignatureCellDelegate? = nil
    
    
    @IBAction func residentSigBTapped(_ sender: Any) {
        delegate?.residentSigTapped()
    }
    @IBAction func installerSigBTapped(_ sender: Any) {
        delegate?.installerSigTapped()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        delegate?.theTextFieldOnSignatureTyped(textNames: [ "Resident" : residentNameTF.text ?? "", "Installer" : installerNameTF.text ?? "" ])
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if complete {} else {
            delegate?.theTextFieldOnSignatureComplete(complete: complete)
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
    
}
