//
//  userFDResourcesCustomCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol userFDResourcesCustomCellDelegate: AnyObject {
    func theSaveBWasTapped(resource: UserFDResources)
}

class userFDResourcesCustomCell: UITableViewCell {

    @IBOutlet weak var fdResourceIV: UIImageView!
    @IBOutlet weak var fdResouceCustomL: UILabel!
    @IBOutlet weak var fdResouceCustomTF: UITextField!
    @IBOutlet weak var fdResourceCustomSegment: UISegmentedControl!
    @IBOutlet weak var accessIV: UIImageView!
    @IBOutlet weak var saveB: UIButton!
    
    weak var delegate: userFDResourcesCustomCellDelegate? = nil
    var type: Int = 0
    
    var showResources: Bool? {
        didSet {
            if self.showResources! {
                self.fdResourceIV.isHidden = false
                self.fdResourceIV.alpha = 1.0
                self.fdResouceCustomL.isHidden = false
                self.fdResouceCustomL.alpha = 1.0
                self.fdResouceCustomTF.isHidden = false
                self.fdResouceCustomTF.alpha = 1.0
                self.fdResourceCustomSegment.isHidden = false
                self.fdResourceCustomSegment.alpha = 1.0
                self.fdResourceCustomSegment.isEnabled = true
                self.accessIV.isHidden = false
                self.accessIV.alpha = 1.0
                self.saveB.isHidden = false
                self.saveB.alpha = 1.0
                self.saveB.isEnabled = true
            } else {
                self.fdResourceIV.isHidden = true
                self.fdResourceIV.alpha = 0.0
                self.fdResouceCustomL.isHidden = true
                self.fdResouceCustomL.alpha = 0.0
                self.fdResouceCustomTF.isHidden = true
                self.fdResouceCustomTF.alpha = 0.0
                self.fdResourceCustomSegment.isHidden = true
                self.fdResourceCustomSegment.alpha = 0.0
                self.fdResourceCustomSegment.isEnabled = false
                self.accessIV.isHidden = true
                self.accessIV.alpha = 0.0
                self.saveB.isHidden = true
                self.saveB.alpha = 0.0
                self.saveB.isEnabled = false
            }
            self.setNeedsDisplay()
        }
    }
    
    var fdResources: UserFDResources? {
        didSet {
            if showResources! {
                let customImageName:String = "RESOURCEWHITE"
                let image = UIImage(named:customImageName)
                self.fdResourceIV.image = image
                let type:Int64 = self.fdResources!.fdResourceType
                var imageName = ""
                switch type {
                case 0001:
                    imageName = "RedSelectedCHECKED"
                case 0002:
                    imageName = "GreenAvailable"
                    fdResourceCustomSegment.selectedSegmentIndex = 0
                case 0003:
                    imageName = "YellowConditional"
                    fdResourceCustomSegment.selectedSegmentIndex = 1
                case 0004:
                    imageName = "BlackOutOfService"
                    fdResourceCustomSegment.selectedSegmentIndex = 2
                default: break
                }
                let customImage = UIImage(named: imageName)
                self.accessIV.image = customImage
                var labelName = ""
                if let name: String = self.fdResources!.fdResource {
                    if name.count > 6 {
                        labelName = name.replacingOccurrences(of: " ", with: "\n")
                        self.fdResouceCustomL.font = fdResouceCustomL.font.withSize(10)
                        self.fdResouceCustomL.adjustsFontSizeToFitWidth = true
                        self.fdResouceCustomL.lineBreakMode = NSLineBreakMode.byWordWrapping
                        self.fdResouceCustomL.numberOfLines = 0
                        self.fdResouceCustomL.setNeedsDisplay()
                    } else {
                        labelName = name
                    }
                    self.fdResouceCustomL.text = labelName
                    self.fdResouceCustomTF.text = name
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // update UI
        accessoryType = selected ? .none : .none
    }
    @IBAction func fdResourceCustomSegmentTapped(_ sender: UISegmentedControl) {
        var imageName = ""
        switch fdResourceCustomSegment.selectedSegmentIndex
        {
        case 0:
            type = 0
            imageName = "GreenAvailable"
            fdResources?.fdResourceType = 0002
        case 1:
            type = 1
            imageName = "YellowConditional"
            fdResources?.fdResourceType = 0003
        case 2:
            type = 2
            imageName = "BlackOutOfService"
            fdResources?.fdResourceType = 0004
        default:
            break;
        }
        let customImage = UIImage(named: imageName)
        self.accessIV.image = customImage
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
         _ = textFieldShouldEndEditing(fdResouceCustomTF)
        delegate?.theSaveBWasTapped(resource: fdResources!)
    }
}

extension userFDResourcesCustomCell: UITextFieldDelegate {
    //    MARK: -textFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text ?? ""
        fdResources?.fdResource = text
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let text = textField.text ?? ""
       fdResources?.fdResource = text
        return true
    }
}
