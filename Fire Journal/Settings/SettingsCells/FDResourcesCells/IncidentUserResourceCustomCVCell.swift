//
//  IncidentUserResourceCustomCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/29/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol IncidentUserResourceCustomCVCellDelegate: AnyObject {
    func incidentUserResourceCustomCVTapped(resource: IncidentUserResource)
}

class IncidentUserResourceCustomCVCell: UICollectionViewCell {

    @IBOutlet weak var resourceIV: UIImageView!
    @IBOutlet weak var customResourceL: UILabel!
    @IBOutlet weak var accessIV: UIImageView!
    @IBOutlet weak var resourceB: UIButton!
    var incidentOrNew: Bool = false
    
    weak var delegate: IncidentUserResourceCustomCVCellDelegate? = nil
    
    var customOrNot: Bool = true
    var type: Int64 = 0001
    var redSelectedOrNot: Bool = false
    
    var userResource: IncidentUserResource? {
        didSet {
            let customImageName:String = "RESOURCEWHITE"
            let customImage = UIImage(named:customImageName)
            self.resourceIV.image = customImage
            var imageName = ""
            if incidentOrNew {
                imageName = "RedSelectedCHECKED"
                type = 0001
            } else {
                imageName = "GreenAvailable"
                type = 0002
            }
            let image = UIImage(named: imageName)
            self.accessIV.image = image
            var labelName = ""
            if let name: String = self.userResource?.imageName {
                if name.count > 6 {
                    labelName = name.replacingOccurrences(of: " ", with: "\n")
                    self.customResourceL.font = customResourceL.font.withSize(10)
                    self.customResourceL.adjustsFontSizeToFitWidth = true
                    self.customResourceL.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.customResourceL.numberOfLines = 0
                    self.customResourceL.textAlignment = .center
                    self.customResourceL.setNeedsDisplay()
                } else {
                    labelName = name
                }
                self.customResourceL.text = labelName
                self.customResourceL.textAlignment = .center
                self.customResourceL.setNeedsDisplay()
            }
        }
    }

    
    
    @IBAction func resourceBTapped(_ sender: Any) {
        var imageName = ""
        if redSelectedOrNot {
            userResource?.type = 0002
            imageName = "GreenAvailable"
            userResource?.assetName = "GreenAvailable"
            redSelectedOrNot = false
        } else {
            imageName = "RedSelectedCHECKED"
            userResource?.type = 0001
            redSelectedOrNot = true
            userResource?.assetName = imageName
        }
        let image = UIImage(named: imageName)
        self.accessIV.image = image
        delegate?.incidentUserResourceCustomCVTapped(resource: userResource! )
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
