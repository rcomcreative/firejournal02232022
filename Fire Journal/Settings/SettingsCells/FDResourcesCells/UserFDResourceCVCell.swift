//
//  UserFDResourceCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol UserFDResourceCVCellDelegate: AnyObject {
     func userFDResourceCVTapped(resource: UserFDResources)
}

class UserFDResourceCVCell: UICollectionViewCell {
    
    //    MARK: -Objects
    @IBOutlet weak var clipboardIV: UIImageView!
    @IBOutlet weak var accessIV: UIImageView!
    @IBOutlet weak var selectBoardB: UIButton!
    
    weak var delegate: UserFDResourceCVCellDelegate? = nil
    
    var customOrNot: Bool = false
    var imageType: theFDResources = .FJkFDRESOURCE_AC1
    var type: Int64 = 0002
    var redSelectedOrNot: Bool = false
    
    var userFDResource: UserFDResources? {
        didSet {
            if let name = self.userFDResource!.fdResourceImageName {
                var named = name.uppercased()
                named = named.replacingOccurrences(of: " ", with: "")
                let imageName:String = name
                let image = UIImage(named:imageName)
                self.clipboardIV.image = image
            }
            let type:Int64 = self.userFDResource!.fdResourceType
            var imageName = ""
            switch type {
            case 0001:
                imageName = "RedSelectedCHECKED"
                redSelectedOrNot = true
            case 0002:
                imageName = "GreenAvailable"
                redSelectedOrNot = false
            case 0003:
                imageName = "YellowConditional"
            case 0004:
                imageName = "BlackOutOfService"
            default: break
            }
            let image = UIImage(named: imageName)
            self.accessIV.image = image
        }
    }
    
    @IBAction func selectBoardBTapped(_ sender: Any) {
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
        delegate?.userFDResourceCVTapped(resource: userFDResource!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
