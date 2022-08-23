//
//  ICS214SegmentTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/10/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ICS214SegmentTVCellDelegate: AnyObject {
    func theICS214CompleteSwitchTapped(complete: Bool)
    func theICS214DetailInfoBTapped()
}

class ICS214SegmentTVCell: UITableViewCell {
    
    weak  var delegate: ICS214SegmentTVCellDelegate? = nil
    
    let theSwitch = UISwitch()
    let theCampaignL = UILabel()
    let infoB = UIButton(primaryAction: nil)
    
    var masterComplete: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }

}

extension ICS214SegmentTVCell {
    
    func configure(master: Bool) {
        
        self.masterComplete = master
        
        theSwitch.translatesAutoresizingMaskIntoConstraints = false
        theCampaignL.translatesAutoresizingMaskIntoConstraints = false
        infoB.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(theSwitch)
        self.contentView.addSubview(theCampaignL)
        self.contentView.addSubview(infoB)
        
        theCampaignL.textAlignment = .left
        theCampaignL.font = .systemFont(ofSize: 16)
        theCampaignL.textColor = .label
        theCampaignL.adjustsFontForContentSizeCategory = false
        if !masterComplete {
            theCampaignL.text = "Completed"
        } else {
            theCampaignL.text = "Campaign Open"
        }
        
        
        theSwitch.addTarget(self, action: #selector(switchTapped), for: UIControl.Event.valueChanged)
        theSwitch.onTintColor = UIColor(red: 1.00, green: 0.21, blue: 0.00, alpha: 0.35)
        theSwitch.tintColor = UIColor(red: 1.00, green: 0.21, blue: 0.00, alpha: 1.00)
        theSwitch.backgroundColor = UIColor(named: "FJIconRed")
        theSwitch.layer.cornerRadius = 16
        theSwitch.isOn = masterComplete
        
        configureNSLayouts()
        configureInfoButton()
        
    }
    
    @objc func theInfoBTapped(_ sender: UIButton) {
        delegate?.theICS214DetailInfoBTapped()
    }
    
    
    
    @objc func switchTapped(_ sender: UISwitch) {
        masterComplete.toggle()
        if !masterComplete {
            theCampaignL.text = "Completed"
            theCampaignL.setNeedsDisplay()
        } else {
            theCampaignL.text = "Compaign Open"
            theCampaignL.setNeedsDisplay()
        }
        delegate?.theICS214CompleteSwitchTapped(complete: masterComplete)
    }
    
    func configureInfoButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: "info.circle")
            config.title = " "
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            infoB.configuration = config
            infoB.addTarget(self, action: #selector(theInfoBTapped(_:)), for: .touchUpInside)
        }
        
    }
    
    func configureNSLayouts() {
        
        NSLayoutConstraint.activate([
            
            theSwitch.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            theSwitch.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            infoB.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            infoB.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            infoB.heightAnchor.constraint(equalToConstant: 45),
            infoB.widthAnchor.constraint(equalToConstant: 100),
            
            theCampaignL.leadingAnchor.constraint(equalTo: theSwitch.trailingAnchor, constant: 10),
            theCampaignL.centerYAnchor.constraint(equalTo: theSwitch.centerYAnchor),
            theCampaignL.heightAnchor.constraint(equalToConstant: 20),
            theCampaignL.trailingAnchor.constraint(equalTo: infoB.leadingAnchor, constant: -10),
            
            
            
            ])
        
    }
    
}




