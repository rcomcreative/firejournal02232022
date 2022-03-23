//
//  UserFDResourceCustomCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol UserFDResourceCustomCVCellDelegate: AnyObject {
    func userFDResourceCustomCVTapped(resource: UserFDResources)
}

class UserFDResourceCustomCVCell: UICollectionViewCell {
    @IBOutlet weak var customResourceIV: UIImageView!
    @IBOutlet weak var customResourceL: UILabel!
    @IBOutlet weak var accessIV: UIImageView!
    
    @IBOutlet weak var selectCustomB: UIButton!
    
    weak var delegate: UserFDResourceCustomCVCellDelegate? = nil
    
    var customOrNot: Bool = false
    var imageType: theFDResources = .FJkFDRESOURCE_AC1
    var type: Int64 = 0002
    var redSelectedOrNot: Bool = false
    
    var userFDResource: UserFDResources? {
        didSet {
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
                if name.count > 6 {
                    labelName = name.replacingOccurrences(of: " ", with: "\n")
                    self.customResourceL.font = customResourceL.font.withSize(10)
                    self.customResourceL.adjustsFontSizeToFitWidth = true
                    self.customResourceL.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.customResourceL.numberOfLines = 0
                    self.customResourceL.setNeedsDisplay()
                } else {
                    labelName = name
                }
                self.customResourceL.text = labelName
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func selectBTapped(_ sender: Any) {
        var imageName = ""
        if redSelectedOrNot {
            userFDResource?.fdResourceType = 0002
            imageName = "GreenAvailable"
            redSelectedOrNot = false
        } else {
            imageName = "RedSelectedCHECKED"
            userFDResource?.fdResourceType = 0001
            redSelectedOrNot = true
        }
        let image = UIImage(named: imageName)
        self.accessIV.image = image
        delegate?.userFDResourceCustomCVTapped(resource: userFDResource!)
    }
    

}
