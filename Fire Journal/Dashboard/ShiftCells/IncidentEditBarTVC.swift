//
//  IncidentEditBarTVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/15/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol IncidentEditBarTVCDelegate: AnyObject {
    func editBTapped()
}

class IncidentEditBarTVC: UITableViewCell {
    
    weak var delegate: IncidentEditBarTVCDelegate? = nil
    
    let editB = UIButton(primaryAction: nil)
    let theIncidentNumberTF = UITextField()
    let theIncidentAddressTF = UITextField()
    let theIncidentAlarmTimeTF = UITextField()
    let theIncidentIconIV = UIImageView()
    let theBackgroundView = UIView()
    
    var theImage: UIImage!
    var theImageName: String = ""
    var imageName: String = "" {
        didSet {
            self.theImageName = self.imageName
            self.theImage = UIImage(named: self.theImageName)
        }
    }
    
    private var theIncidentNumber: String = "No Incident number was indicated."
    var incidentNumber: String = "" {
        didSet {
            self.theIncidentNumber = self.incidentNumber
        }
    }
    
    private var theIncidentAddress: String = "No Incident address was indicated."
    var incidentAddress: String = "" {
        didSet {
            self.theIncidentAddress = self.incidentAddress
        }
    }
    
    private var theAlarmTime: String = "No alarm time was indicated."
    var alarmDate: String = "" {
        didSet {
            self.theAlarmTime = self.alarmDate
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension IncidentEditBarTVC {
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theIncidentNumberTF.translatesAutoresizingMaskIntoConstraints = false
        theIncidentAddressTF.translatesAutoresizingMaskIntoConstraints = false
        theIncidentAlarmTimeTF.translatesAutoresizingMaskIntoConstraints = false
        theIncidentIconIV.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(theBackgroundView)
        self.contentView.addSubview(theIncidentNumberTF)
        self.contentView.addSubview(theIncidentAddressTF)
        self.contentView.addSubview(theIncidentAlarmTimeTF)
        self.contentView.addSubview(theIncidentIconIV)
        
        configureLabelsAndImage()
        configureNSLayout()
        
    }
    
    func configureLabelsAndImage() {
        
        theIncidentNumberTF.textAlignment = .left
        if theIncidentNumber == "No Incident number was indicated." {
            theIncidentNumberTF.font = .systemFont(ofSize: 18)
        } else {
            theIncidentNumberTF.font = .systemFont(ofSize: 24, weight: UIFont.Weight(rawValue: 300))
        }
        theIncidentNumberTF.textColor = .label
        theIncidentNumberTF.adjustsFontForContentSizeCategory = false
        if theIncidentNumber == "No Incident number was indicated." {
            theIncidentNumberTF.text = theIncidentNumber
        } else {
            theIncidentNumberTF.text = "#" + theIncidentNumber
        }
        
        theIncidentAddressTF.textAlignment = .left
        theIncidentAddressTF.font = .systemFont(ofSize: 18)
        theIncidentAddressTF.textColor = .label
        theIncidentAddressTF.adjustsFontForContentSizeCategory = false
        theIncidentAddressTF.text = theIncidentAddress
        
        theIncidentAlarmTimeTF.textAlignment = .left
        theIncidentAlarmTimeTF.font = .systemFont(ofSize: 18)
        theIncidentAlarmTimeTF.textColor = .label
        theIncidentAlarmTimeTF.adjustsFontForContentSizeCategory = false
        theIncidentAlarmTimeTF.text = theAlarmTime
        
        if let image = theImage {
            theIncidentIconIV.image = image
        }
        
    }
    
    func configureNSLayout() {
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            theIncidentIconIV.heightAnchor.constraint(equalToConstant: 85),
            theIncidentIconIV.widthAnchor.constraint(equalToConstant: 85),
            theIncidentIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 55),
            theIncidentIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            
            theIncidentNumberTF.topAnchor.constraint(equalTo: theIncidentIconIV.topAnchor),
            theIncidentNumberTF.leadingAnchor.constraint(equalTo: theIncidentIconIV.trailingAnchor, constant: 7),
            theIncidentNumberTF.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -35),
            theIncidentNumberTF.heightAnchor.constraint(equalToConstant: 25),
            
            theIncidentAddressTF.topAnchor.constraint(equalTo: theIncidentNumberTF.bottomAnchor, constant: 10),
            theIncidentAddressTF.leadingAnchor.constraint(equalTo: theIncidentNumberTF.leadingAnchor),
            theIncidentAddressTF.heightAnchor.constraint(equalToConstant: 20),
            theIncidentAddressTF.trailingAnchor.constraint(equalTo: theIncidentNumberTF.trailingAnchor),
            
            theIncidentAlarmTimeTF.topAnchor.constraint(equalTo: theIncidentAddressTF.bottomAnchor, constant: 10),
            theIncidentAlarmTimeTF.leadingAnchor.constraint(equalTo: theIncidentNumberTF.leadingAnchor),
            theIncidentAlarmTimeTF.heightAnchor.constraint(equalToConstant: 20),
            theIncidentAlarmTimeTF.trailingAnchor.constraint(equalTo: theIncidentNumberTF.trailingAnchor),
            
            ])
        
    }
    
    func configureEditButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .small
            config.image = UIImage(systemName: "pencil.circle")
            config.title = " Edit"
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            editB.configuration = config
            
            editB.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            editB.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(editB)
            
            NSLayoutConstraint.activate([
                editB.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                editB.widthAnchor.constraint(equalToConstant: 120),
                editB.heightAnchor.constraint(equalToConstant: 45),
                editB.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -35),
                ])
            
        }
            
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        delegate?.editBTapped()
    }
    
}
