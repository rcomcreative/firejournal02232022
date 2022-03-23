//
//  IncidentUserResourceCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/29/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentUserResourceCVCellDelegate: AnyObject {
    func incidentUserResourceCVTapped(resource: IncidentUserResource)
}

class IncidentUserResourceCVCell: UICollectionViewCell {
    
    @IBOutlet weak var clipboardIV: UIImageView!
    @IBOutlet weak var assetIV: UIImageView!
    @IBOutlet weak var resourceB: UIButton!
    var incidentOrNew: Bool = false
    
    var customOrNot: Bool = false
    var type: Int64 = 0002
    var redSelectedOrNot: Bool = false
    
    weak var delegate: IncidentUserResourceCVCellDelegate? = nil
    
    var userResource: IncidentUserResource? {
        didSet {
            if let name = self.userResource?.imageName {
                let imageName:String = name
                let image = UIImage(named:imageName)
                self.clipboardIV.image = image
            }
            
            var imageName = ""
            if incidentOrNew {
                imageName = "RedSelectedCHECKED"
                type = 0001
            } else {
                imageName = "GreenAvailable"
                type = 0001
            }
           
            let image = UIImage(named: imageName)
            self.assetIV.image = image
        }
    }
    
    @IBAction func resourceBTapped(_ sender: Any) {
        var imageName = ""
        if redSelectedOrNot {
            userResource?.type = 0002
            imageName = "GreenAvailable"
            userResource?.assetName = imageName
            redSelectedOrNot = false
        } else {
            imageName = "RedSelectedCHECKED"
            userResource?.assetName = imageName
            userResource?.type = 0001
            redSelectedOrNot = true
        }
        let image = UIImage(named: imageName)
        self.assetIV.image = image
        delegate?.incidentUserResourceCVTapped(resource: userResource!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
