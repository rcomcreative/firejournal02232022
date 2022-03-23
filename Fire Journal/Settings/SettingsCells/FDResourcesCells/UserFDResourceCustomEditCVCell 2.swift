//
//  UserFDResourceCustomEditCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol UserFDResourceCustomEditCVCellDelegate:class {
    func editBWasTapped(tag: Int, resource: UserFDResources)
}

class UserFDResourceCustomEditCVCell: UICollectionViewCell {
    
    @IBOutlet weak var customResourceIV: UIImageView!
    @IBOutlet weak var customResourceL: UILabel!
    @IBOutlet weak var accessIV: UIImageView!
    @IBOutlet weak var editB: UIButton!
//    var resource: UserFDResource? {
//            didSet {
//                editB.backgroundColor = .clear
//                editB.layer.cornerRadius = 3
//                editB.layer.borderWidth = 0.5
//                editB.layer.borderColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1.0).cgColor
//                if let type = self.resource?.resourceType {
//                    switch type {
//                        case 0001:
//                            self.accessIV.image = UIImage(named: "RedSelectedCHECKED")
//                        case 0002:
//                            self.accessIV.image = UIImage(named: "GreenAvailable")
//                        case 0003:
//                            self.accessIV.image = UIImage(named: "YellowConditional")
//                        case 0004:
//                            self.accessIV.image = UIImage(named: "BlackOutOfService")
//                        default:
//                            self.accessIV.image = UIImage(named: "GreenAvailable")
//                    }
//                }
//                if let custom = self.resource?.custom {
//                    if custom {
//                        self.customResourceIV.image = UIImage(named: "RESOURCEWHITE")
//                        self.customResourceL.text = resource?.resource
//                    } else {
//                        if let image = resource?.resource {
//                            self.customResourceIV.image = UIImage(named: image)
//                        }
//                    }
//                }
//            }
//        }
    var userFDResource: UserFDResources? {
        didSet {
            editB.backgroundColor = .clear
            editB.layer.cornerRadius = 5
            editB.layer.borderWidth = 1
            editB.layer.borderColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1.0).cgColor
            let customImageName:String = "RESOURCEWHITE"
            let customImage = UIImage(named:customImageName)
            self.customResourceIV.image = customImage
            let type: Int64 = self.userFDResource!.fdResourceType
            var imageName = ""
            switch type {
            case 0001:
                imageName = "RedSelectedCHECKED"
            case 0002:
                imageName = "GreenAvailable"
            case 0003:
                imageName = "YellowConditional"
            case 0004:
                imageName = "BlackOutOfService"
            default: break
            }
            let image = UIImage(named: imageName)
            self.accessIV.image = image
            var labelName = ""
            if let name: String = self.userFDResource!.fdResource {
                labelName = name
//                if name.count > 6 {
//                    labelName = name.replacingOccurrences(of: " ", with: "\n")
//                    self.customResourceL.font = customResourceL.font.withSize(10)
//                    self.customResourceL.adjustsFontSizeToFitWidth = true
//                    self.customResourceL.lineBreakMode = NSLineBreakMode.byWordWrapping
//                    self.customResourceL.numberOfLines = 0
//                    self.customResourceL.setNeedsDisplay()
//                } else {
//                    labelName = name
//                }
            }
            self.customResourceL.text = labelName
        }
    }
    
    weak var delegate: UserFDResourceCustomEditCVCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    @IBAction func editBTapped(_ sender: Any) {
        delegate?.editBWasTapped(tag: tag, resource: userFDResource!)
    }
    

}
