//
//  SettingsCustomFDResourceCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit



class SettingsCustomFDResourceCell: UITableViewCell {
    
    @IBOutlet weak var customResourceIV: UIImageView!
    @IBOutlet weak var customResourceL: UILabel!
    @IBOutlet weak var customResource2L: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var fdResource: UserFDResources? {
        didSet {
            var labelName = ""
            if let name: String = self.fdResource!.fdResource {
                if name.count > 6 {
                    labelName = name.replacingOccurrences(of: " ", with: "\n")
                    self.customResourceL.font = customResourceL.font.withSize(10)
                    self.customResourceL.adjustsFontSizeToFitWidth = true
                    self.customResourceL.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.customResourceL.numberOfLines = 0
                    self.customResourceL.setNeedsDisplay()
                    self.customResource2L.text = labelName
                } else {
                    labelName = name
                }
                self.customResourceL.text = labelName
                self.customResource2L.text = labelName
            }
        }
    }
    
    var resource: UserResources? {
        didSet {
            let customImageName:String = "RESOURCEWHITE"
            let image = UIImage(named:customImageName)
            self.customResourceIV.image = image
            var labelName = ""
            if let name: String = self.resource!.resource {
                if name.count > 6 {
                    labelName = name.replacingOccurrences(of: " ", with: "\n")
                    self.customResourceL.font = customResourceL.font.withSize(10)
                    self.customResourceL.adjustsFontSizeToFitWidth = true
                    self.customResourceL.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.customResourceL.numberOfLines = 0
                    self.customResourceL.setNeedsDisplay()
                    self.customResource2L.text = labelName
                } else {
                    labelName = name
                }
                self.customResourceL.text = labelName
                self.customResource2L.text = labelName
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
