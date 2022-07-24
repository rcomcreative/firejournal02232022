//
//  ARC_HeadCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol ARC_HeadCellDelegate: AnyObject {
    func arcFormInfoTapped()
    func arcFormCampaignSwitchTapped(campaign: Bool)
    func arcFormShareThisFormTapped()
}

class ARC_HeadCell: UITableViewCell {
    
//    MARK: -OBJECTS-
    @IBOutlet weak var icsIconIV: UIImageView!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var campaignTF: UILabel!
    @IBOutlet weak var campaignSwitch: UISwitch!
    @IBOutlet weak var formNameL: UILabel!
    @IBOutlet weak var campaignTypeL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var shareB: UIButton!
    
    private var theFirstRun: Bool = false
    var firstRun: Bool = false {
        didSet {
            self.theFirstRun = self.firstRun
            if self.theFirstRun {
                shareB.isHidden = true
                shareB.isEnabled = false
                shareB.alpha = 0.0
            }
        }
    }
    
//    MARK: -PROPERTIES-
    private var campaignerSwitch: Bool = true
    var campaign: Bool = true {
        didSet {
            self.campaignerSwitch = self.campaign
            self.campaignSwitch.isOn = self.campaignerSwitch
        }
    }
    
    private var campaignText: String = ""
    var cText: String = "Campaign Open" {
        didSet {
            self.campaignText = self.cText
            self.campaignTF.text = self.campaignText
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    weak var delegate: ARC_HeadCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
//        if firstRun {
//                        shareB.isHidden = true
//                        shareB.isEnabled = false
//                        shareB.alpha = 0.0
//        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareBTapped(_ sender: Any) {
        delegate?.arcFormShareThisFormTapped()
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.arcFormInfoTapped()
    }
    
    @IBAction func campaignSwitchTapped(_ sender: Any) {
        campaign.toggle()
        delegate?.arcFormCampaignSwitchTapped(campaign: campaignerSwitch)
    }
    
}
