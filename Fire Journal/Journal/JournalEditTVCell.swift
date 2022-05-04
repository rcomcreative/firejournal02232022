//
//  JournalEditTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/30/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation

protocol JournalEditTVCellDelegate: AnyObject {
    func editBTapped()
}

class JournalEditTVCell: UITableViewCell {
    
    weak var delegate: JournalEditTVCellDelegate? = nil
    
    let editB = UIButton(primaryAction: nil)
    let theJournalTitleL = UILabel()
    let theJournalAddressL = UILabel()
    let theJournalDateL = UILabel()
    let theJournalIconIV = UIImageView()
    let theBackgroundView = UIView()
    
    var theImage: UIImage!
    var theImageName: String = ""
    var imageName: String = "" {
        didSet {
            self.theImageName = self.imageName
            self.theImage = UIImage(named: self.theImageName)
        }
    }
    
    private var theJournalNumber: String = "No journal title was indicated."
    var journalNumber: String = "" {
        didSet {
            self.theJournalNumber = self.journalNumber
        }
    }
    
    private var theJournalAddress: String = "No journal address was indicated."
    var journalAddress: String = "" {
        didSet {
            self.theJournalAddress = self.journalAddress
        }
    }
    
    private var theJournalTime: String = "No alarm time was indicated."
    var journalDate: String = "" {
        didSet {
            self.theJournalTime = self.journalDate
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

extension JournalEditTVCell {
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theJournalTitleL.translatesAutoresizingMaskIntoConstraints = false
        theJournalAddressL.translatesAutoresizingMaskIntoConstraints = false
        theJournalDateL.translatesAutoresizingMaskIntoConstraints = false
        theJournalIconIV.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(theBackgroundView)
        self.contentView.addSubview(theJournalTitleL)
        self.contentView.addSubview(theJournalAddressL)
        self.contentView.addSubview(theJournalDateL)
        self.contentView.addSubview(theJournalIconIV)
        configureLabelsAndImage()
        configureNSLayout()
    }
    
    func configureLabelsAndImage() {
        
        theJournalTitleL.textAlignment = .left
        if theJournalNumber == "No journal title was indicated." {
            theJournalTitleL.font = .systemFont(ofSize: 18)
        } else {
            theJournalTitleL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        }
        theJournalTitleL.textColor = .label
        theJournalTitleL.adjustsFontForContentSizeCategory = false
        theJournalTitleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        theJournalTitleL.numberOfLines = 0
        if theJournalNumber == "No journal title was indicated." {
            theJournalTitleL.text = theJournalNumber
        } else {
            theJournalTitleL.text = theJournalNumber
        }
        
        theJournalAddressL.textAlignment = .left
        theJournalAddressL.font = .systemFont(ofSize: 18)
        theJournalAddressL.textColor = .label
        theJournalAddressL.adjustsFontForContentSizeCategory = false
        theJournalAddressL.lineBreakMode = NSLineBreakMode.byWordWrapping
        theJournalAddressL.numberOfLines = 0
        theJournalAddressL.text = theJournalAddress
        
        theJournalDateL.textAlignment = .left
        theJournalDateL.font = .systemFont(ofSize: 18)
        theJournalDateL.textColor = .label
        theJournalDateL.adjustsFontForContentSizeCategory = false
        theJournalDateL.lineBreakMode = NSLineBreakMode.byWordWrapping
        theJournalDateL.numberOfLines = 0
        theJournalDateL.text = theJournalTime
        
        if let image = theImage {
            theJournalIconIV.image = image
        }
        
    }
    
    func configureNSLayout() {
        
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            theJournalIconIV.heightAnchor.constraint(equalToConstant: 85),
            theJournalIconIV.widthAnchor.constraint(equalToConstant: 85),
            theJournalIconIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 65),
            theJournalIconIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 20),
            
            theJournalTitleL.topAnchor.constraint(equalTo: theJournalIconIV.topAnchor),
            theJournalTitleL.leadingAnchor.constraint(equalTo: theJournalIconIV.trailingAnchor, constant: 7),
            theJournalTitleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -35),
            
            theJournalDateL.topAnchor.constraint(equalTo: theJournalTitleL.bottomAnchor, constant: 10),
            theJournalDateL.leadingAnchor.constraint(equalTo: theJournalTitleL.leadingAnchor),
            theJournalDateL.heightAnchor.constraint(equalToConstant: 20),
            theJournalDateL.trailingAnchor.constraint(equalTo: theJournalTitleL.trailingAnchor),
            
            theJournalAddressL.topAnchor.constraint(equalTo: theJournalDateL.bottomAnchor, constant: 10),
            theJournalAddressL.leadingAnchor.constraint(equalTo: theJournalTitleL.leadingAnchor),
            theJournalAddressL.heightAnchor.constraint(equalToConstant: 20),
            theJournalAddressL.trailingAnchor.constraint(equalTo: theJournalTitleL.trailingAnchor),
            
            ])
        
    }
    
    func configureEditButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .small
            config.image = UIImage(systemName: "pencil.circle")
            config.title = " Edit"
            config.baseBackgroundColor = UIColor(named: "FJBlueColor")
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
