//
//  campaignCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/8/18.
//  Copyright © 2018 PureCommandLLC. All rights reserved.
//

import UIKit

protocol CampaignCellDelegate:class {
    func campaignSwitchWasTapped(tapped: Bool, date: Date)
    func campaignTitleChanged(campaignName: String)
}

class CampaignCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var campaignSwitch: UISwitch!
    @IBOutlet weak var campaignTitleL: UILabel!
    @IBOutlet weak var campaignTitleTF: UITextField!
    @IBOutlet weak var campaignStartEndTF: UILabel!
    var openOrClosed: Bool = false
    
    weak var delegate: CampaignCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let input:String = campaignTitleTF.text {
                delegate?.campaignTitleChanged(campaignName: input)
        }
        return true
    }
        
    @IBAction func campaingSwitchTapped(_ sender: Any) {
        openOrClosed.toggle()
        let campaignDate = Date()
        delegate?.campaignSwitchWasTapped(tapped: openOrClosed, date: campaignDate)
//        if campaignSwitch.isOn {
//            campaignSwitch.setOn(false, animated: true)
//            let campaignDate = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/YYYY"
//            let dateFrom = dateFormatter.string(from: campaignDate)
//            let dateString = "Campaign closed \(dateFrom)."
//            campaignStartEndTF.text = dateString
//            let closed:Bool = true;
//            delegate?.campaignSwitchWasTapped(tapped: openOrClosed, date: campaignDate)
//        } else {
//            campaignSwitch.setOn(true, animated: true)
//            let campaignDate = Date()
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MM/dd/YYYY"
//            let dateFrom = dateFormatter.string(from: campaignDate)
//            let dateString = "Campaign started \(dateFrom)."
//            campaignStartEndTF.text = dateString
//            let closed:Bool = false;
//            delegate?.campaignSwitchWasTapped(tapped: closed, date: campaignDate)
//        }
    }
}
