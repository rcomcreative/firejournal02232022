//
//  UserFDResouceEditCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/9/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol UserFDResouceEditCVCellDelegate: AnyObject {
    func editBTapped(resource: UserFDResources)
}

class UserFDResouceEditCVCell: UICollectionViewCell {
    
    @IBOutlet weak var fdResourceUI: UIImageView!
    @IBOutlet weak var accessIV: UIImageView!
    @IBOutlet weak var editB: UIButton!
    weak var delegate: UserFDResouceEditCVCellDelegate? = nil
    var fdResource: UserFDResources? {
        didSet {
            editB.backgroundColor = .clear
            editB.layer.cornerRadius = 3
            editB.layer.borderWidth = 0.5
            editB.layer.borderColor = UIColor(red: 0.37, green: 0.59, blue: 0.22, alpha: 1.0).cgColor
            if let name = self.fdResource?.fdResource {
                var named = name.uppercased()
                named = named.replacingOccurrences(of: " ", with: "")
                let imageName:String = name
                let image = UIImage(named:imageName)
               self.fdResourceUI.image = image
            }
            let type: Int64 = self.fdResource?.fdResourceType ?? 0
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
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func editBTapped(_ sender: Any) {
        delegate?.editBTapped(resource: fdResource!)
    }
    

}
