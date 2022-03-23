//
//  SettingMyResourceTVCell.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/5/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol SettingMyResourceTVCellDelegate: AnyObject {
    func editBTapped(row: Int)
}

class SettingMyResourceTVCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var resourceStatusIV: UIImageView!
    @IBOutlet weak var resourceIV: UIImageView!
    @IBOutlet weak var resourceL: UILabel!
    @IBOutlet weak var editB: UIButton!
    @IBOutlet weak var statusL: UILabel!
    @IBOutlet weak var idL: UILabel!
    @IBOutlet weak var shopNumberL: UILabel!
    @IBOutlet weak var positionL: UILabel!
    @IBOutlet weak var yearL: UILabel!
    @IBOutlet weak var manufacturerL: UILabel!
    @IBOutlet weak var apparatusL: UILabel!
    @IBOutlet weak var specialtiesL: UILabel!
    @IBOutlet weak var descriptionTV: UITextView!
    var row: Int!
    @IBOutlet weak var rowBarV: UIView!
    weak var delegate: SettingMyResourceTVCellDelegate? = nil
    
    
//    MARK: -PROPERTIES-
    var resource: UserFDResource? {
        didSet {
            if let type = self.resource?.resourceType {
                switch type {
                    case 0002:
                        self.resourceStatusIV.image = UIImage(named: "GreenAvailable")
                        self.statusL.text = "Front Line"
                    case 0003:
                        self.resourceStatusIV.image = UIImage(named: "YellowConditional")
                        self.statusL.text = "Reserve"
                    case 0004:
                        self.resourceStatusIV.image = UIImage(named: "BlackOutOfService")
                        self.statusL.text = "Out of Service"
                    default:
                        self.resourceStatusIV.image = UIImage(named: "GreenAvailable")
                }
            }
            if let id = self.resource?.resourceID {
                self.idL.text = id
            }
            if let shopNum = self.resource?.resourceShopNumber {
                self.shopNumberL.text = shopNum
            }
            if let position = self.resource?.resourcePersonnelCount {
                self.positionL.text = String(position)
            }
            if let manufacturer = self.resource?.resourceManufacturer {
                self.manufacturerL.text = manufacturer
            }
            if let year = self.resource?.resourceYear {
                self.yearL.text = year
            }
            if let apparatus = self.resource?.resourceApparatus {
                self.apparatusL.text = apparatus
            }
            if let speciality = self.resource?.resourceSpecialities {
                self.specialtiesL.text = speciality
            }
            if let describe = self.resource?.resourceDescription {
                self.descriptionTV.text = describe
            }
            if let custom = self.resource?.custom {
                if custom {
                    self.resourceIV.image = UIImage(named: "RESOURCEWHITE")
                    self.resourceL.text = resource?.resource
                } else {
                    if let image = resource?.resource {
                        self.resourceIV.image = UIImage(named: image)
                        self.resourceL.text = ""
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        descriptionTV.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8.0
        self.rowBarV.backgroundColor = UIColor(red:0.89, green:0.90, blue:0.93, alpha:1.00)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    MARK: -ACTIONS-
    @IBAction func editBTapped(_ sender: Any) {
        delegate?.editBTapped(row: row)
    }
    
}
