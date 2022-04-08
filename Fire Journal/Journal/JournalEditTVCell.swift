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
    let theJournalTitleTF = UITextField()
    let theJournalAddressTF = UITextField()
    let theJournalDateTF = UITextField()
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
        theJournalTitleTF.translatesAutoresizingMaskIntoConstraints = false
        theJournalAddressTF.translatesAutoresizingMaskIntoConstraints = false
        theJournalDateTF.translatesAutoresizingMaskIntoConstraints = false
        theJournalIconIV.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(theBackgroundView)
        self.contentView.addSubview(theJournalTitleTF)
        self.contentView.addSubview(theJournalAddressTF)
        self.contentView.addSubview(theJournalDateTF)
        self.contentView.addSubview(theJournalIconIV)
        configureLabelsAndImage()
        configureNSLayout()
    }
    
    func configureLabelsAndImage() {
        
        theJournalTitleTF.textAlignment = .left
        if theJournalNumber == "No journal title was indicated." {
            theJournalTitleTF.font = .systemFont(ofSize: 18)
        } else {
            theJournalTitleTF.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        }
        theJournalTitleTF.textColor = .label
        theJournalTitleTF.adjustsFontForContentSizeCategory = false
        if theJournalNumber == "No journal title was indicated." {
            theJournalTitleTF.text = theJournalNumber
        } else {
            theJournalTitleTF.text = theJournalNumber
        }
        
        theJournalAddressTF.textAlignment = .left
        theJournalAddressTF.font = .systemFont(ofSize: 18)
        theJournalAddressTF.textColor = .label
        theJournalAddressTF.adjustsFontForContentSizeCategory = false
        theJournalAddressTF.text = theJournalAddress
        
        theJournalDateTF.textAlignment = .left
        theJournalDateTF.font = .systemFont(ofSize: 18)
        theJournalDateTF.textColor = .label
        theJournalDateTF.adjustsFontForContentSizeCategory = false
        theJournalDateTF.text = theJournalTime
        
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
            
            theJournalTitleTF.topAnchor.constraint(equalTo: theJournalIconIV.topAnchor),
            theJournalTitleTF.leadingAnchor.constraint(equalTo: theJournalIconIV.trailingAnchor, constant: 7),
            theJournalTitleTF.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -35),
            theJournalTitleTF.heightAnchor.constraint(equalToConstant: 25),
            
            theJournalDateTF.topAnchor.constraint(equalTo: theJournalTitleTF.bottomAnchor, constant: 10),
            theJournalDateTF.leadingAnchor.constraint(equalTo: theJournalTitleTF.leadingAnchor),
            theJournalDateTF.heightAnchor.constraint(equalToConstant: 20),
            theJournalDateTF.trailingAnchor.constraint(equalTo: theJournalTitleTF.trailingAnchor),
            
            theJournalAddressTF.topAnchor.constraint(equalTo: theJournalDateTF.bottomAnchor, constant: 10),
            theJournalAddressTF.leadingAnchor.constraint(equalTo: theJournalTitleTF.leadingAnchor),
            theJournalAddressTF.heightAnchor.constraint(equalToConstant: 20),
            theJournalAddressTF.trailingAnchor.constraint(equalTo: theJournalTitleTF.trailingAnchor),
            
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
