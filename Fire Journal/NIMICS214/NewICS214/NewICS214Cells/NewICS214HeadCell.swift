//
//  NewICS214HeadCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/12/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214HeadCellDelegate: AnyObject {
    func ics214InfoTapped()
    func ics214CampaignSwitchTapped(campaign: Bool)
    func ics214ShareThisFormTapped()
}

class NewICS214HeadCell: UITableViewCell {
    
    @IBOutlet weak var icsIconIV: UIImageView!
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var campaignTF: UILabel!
    @IBOutlet weak var campaignSwitch: UISwitch!
    @IBOutlet weak var formNameL: UILabel!
    @IBOutlet weak var campaignTypeL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var shareB: UIButton!
    
    private var campaignerSwitch: Bool = true
    var campaign: Bool = true {
        didSet {
            self.campaignerSwitch = self.campaign
            self.campaignerSwitch.toggle()
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
    
    weak var delegate: NewICS214HeadCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
//        shareB.isHidden = true
//        shareB.isEnabled = false
//        shareB.alpha = 0.0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func shareBTapped(_ sender: Any) {
        delegate?.ics214ShareThisFormTapped()
    }
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.ics214InfoTapped()
    }
    
    @IBAction func campaignSwitchTapped(_ sender: Any) {
        campaign.toggle()
        delegate?.ics214CampaignSwitchTapped(campaign: campaignerSwitch)
    }
    
}
