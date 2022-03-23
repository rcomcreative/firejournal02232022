//
//  UserFDResourcesCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol UserFDResourceCellDelegate: AnyObject {
    func theNotCustomSaveBWasTapped(resource: UserFDResources)
}

class UserFDResourcesCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -Properited
    var customOrNot: Bool = false
    var imageType: theFDResources = .FJkFDRESOURCE_AC1
    var type: Int64 = 0002
    weak var delegate: UserFDResourceCellDelegate? = nil
    var redSelectedOrNot: Bool = false
    
    
//    MARK: -Objects
    @IBOutlet weak var fdResourceBadgeIV: UIImageView!
    @IBOutlet weak var fdResourceStringTF: UITextField!
    @IBOutlet weak var fdResourceTypeIV: UIImageView!
    @IBOutlet weak var fdResourceSegment: UISegmentedControl!
    @IBOutlet weak var saveB: UIButton!
    
    var showResources: Bool? {
        didSet {
            if self.showResources! {
                self.fdResourceBadgeIV.isHidden = false
                self.fdResourceBadgeIV.alpha = 1.0
                self.fdResourceStringTF.isHidden = false
                self.fdResourceStringTF.alpha = 1.0
                self.fdResourceSegment.isHidden = false
                self.fdResourceSegment.alpha = 1.0
                self.fdResourceSegment.isEnabled = true
                self.fdResourceSegment.setNeedsLayout()
                self.fdResourceTypeIV.isHidden = false
                self.fdResourceTypeIV.alpha = 1.0
                self.saveB.isHidden = false
                self.saveB.alpha = 1.0
                self.saveB.isEnabled = true
            } else {
                self.fdResourceBadgeIV.isHidden = true
                self.fdResourceBadgeIV.alpha = 0.0
                self.fdResourceStringTF.isHidden = true
                self.fdResourceStringTF.alpha = 0.0
                self.fdResourceSegment.isHidden = true
                self.fdResourceSegment.alpha = 0.0
                self.fdResourceSegment.isEnabled = false
                self.fdResourceTypeIV.isHidden = true
                self.fdResourceTypeIV.alpha = 0.0
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
                if let name = self.fdResources!.fdResourceImageName {
                    let imageName:String = name
                    let image = UIImage(named:imageName)
                    self.fdResourceBadgeIV.image = image
                }
                let type:Int64 = self.fdResources!.fdResourceType
                var imageName = ""
                switch type {
                case 0001:
                    imageName = "RedSelectedCHECKED"
                case 0002:
                    imageName = "GreenAvailable"
                    self.fdResourceSegment.selectedSegmentIndex = 0
                case 0003:
                    imageName = "YellowConditional"
                    self.fdResourceSegment.selectedSegmentIndex = 1
                case 0004:
                    imageName = "BlackOutOfService"
                    self.fdResourceSegment.selectedSegmentIndex = 2
                default: break
                }
                let customImage = UIImage(named: imageName)
                self.fdResourceTypeIV.image = customImage
                if let name: String = self.fdResources!.fdResource {
                    self.fdResourceStringTF.text = name
                }
            }
        }
    }
    
    @IBAction func fdResourceSegmentTapped(_ sender: UISegmentedControl) {
        var imageName = ""
        switch fdResourceSegment.selectedSegmentIndex
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
        self.fdResourceTypeIV.image = customImage
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // update UI
        accessoryType = selected ? .none : .none
    }
    
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.theNotCustomSaveBWasTapped(resource: fdResources!)
    }
}
