//
//  SettingsFDResourcesCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/3/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class SettingsFDResourcesCell: UITableViewCell {
    
    @IBOutlet weak var fdResourceIV: UIImageView!
    @IBOutlet weak var fdResourceTF: UITextField!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    var fdResource: UserFDResources? {
        didSet {
            fdResourceTF.text = fdResource?.fdResource
            if let name = self.fdResource!.fdResourceImageName {
                let imageName:String = name
                let image = UIImage(named:imageName)
                self.fdResourceIV.image = image
            }
        }
    }
    
    var resource: UserResources? {
        didSet {
            fdResourceTF.text = resource?.resource
            if let name = self.resource!.resource {
                var named = name.uppercased()
                named = named.replacingOccurrences(of: " ", with: "")
                let imageName:String = named
                let image = UIImage(named:imageName)
                self.fdResourceIV.image = image
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
