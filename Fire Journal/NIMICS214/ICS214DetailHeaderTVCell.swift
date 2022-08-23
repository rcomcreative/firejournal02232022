    //
    //  ICS214DetailHeaderTVCell.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 8/10/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CloudKit
import CoreData

protocol ICS214DetailHeaderTVCellDelegate: AnyObject {
    func theEditButtonTapped(_ theICS214OID: NSManagedObjectID)
    func theShareButtonTapped(_ theICS214OID: NSManagedObjectID)
}

class ICS214DetailHeaderTVCell: UITableViewCell {
    
    weak var delegate: ICS214DetailHeaderTVCellDelegate? = nil
    
    var subscriptionBought: Bool = false
    let userDefaults = UserDefaults.standard
    var masterOrNot: Bool = false
    let calendar = Calendar.current
    let nc = NotificationCenter.default
    var theType: TypeOfForm!
    
    
    let iconIV = UIImageView()
    let titleL = UILabel()
    let typeL = UILabel()
    let dateL = UILabel()
    let editB = UIButton(primaryAction: nil)
    let shareB = UIButton(primaryAction: nil)
    
    lazy var theICS214Provider: ICS214Provider = {
        let provider = ICS214Provider(with: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        return provider
    }()
    var theICS214ProviderContext: NSManagedObjectContext!
    
    var theICS214Form: ICS214Form!
    var theICs214FormOID: NSManagedObjectID!
    var imageName: String = ""
    var theTitle: String = ""
    var effortType: String = ""
    var ics214CalendarDate: String = ""
    
    
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

extension ICS214DetailHeaderTVCell {
    
    func configure(_ ics214OID: NSManagedObjectID, type: TypeOfForm) {
        self.theType = type
        self.theICs214FormOID = ics214OID
        self.theICS214ProviderContext = self.theICS214Provider.persistentContainer.newBackgroundContext()
        self.theICS214Form = self.theICS214ProviderContext.object(with: self.theICs214FormOID) as? ICS214Form
        self.imageName = self.theICS214Provider.determineTheICS214Image(type: self.theType)
        self.effortType = self.theICS214Provider.determineTheICS214EffortType(type: self.theType)
        self.titleL.text = ""
        self.typeL.text = ""
        self.dateL.text = ""
        if let effortName = theICS214Form.ics214IncidentName {
            theTitle = effortName
        }
        if let aDate = self.theICS214Form.ics214FromTime {
            self.ics214CalendarDate = self.theICS214Provider.determineTheICS214StringDate(theDate: aDate)
        }
        subscriptionBought = userDefaults.bool(forKey: FJkSUBSCRIPTIONIsLocallyCached)
        
        configureObjects()
        configureTheContent()
        if subscriptionBought {
            configureShareButton()
            configureEditButton()
        }
        configureNSLayouts()
    }
    
    func configureObjects() {
        
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        typeL.translatesAutoresizingMaskIntoConstraints = false
        dateL.translatesAutoresizingMaskIntoConstraints = false
        editB.translatesAutoresizingMaskIntoConstraints = false
        shareB.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(iconIV)
        self.contentView.addSubview(titleL)
        self.contentView.addSubview(typeL)
        self.contentView.addSubview(dateL)
        self.contentView.addSubview(editB)
        self.contentView.addSubview(shareB)
        
    }
    
    func configureTheContent() {
        
        if imageName != "" {
            let image = UIImage(named: imageName)
            if let theImage = image {
                iconIV.image = theImage
            }
        }
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 24, weight: .semibold )
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.text = theTitle
        
        typeL.textAlignment = .left
        typeL.font = .systemFont(ofSize: 16)
        typeL.textColor = .label
        typeL.adjustsFontForContentSizeCategory = false
        typeL.text = effortType
        
        dateL.textAlignment = .left
        dateL.font = .systemFont(ofSize: 16)
        dateL.textColor = .label
        dateL.adjustsFontForContentSizeCategory = false
        dateL.text = ics214CalendarDate
        
        
    }
    
    func configureShareButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: "square.and.arrow.up")
            config.title = " Share"
            config.baseBackgroundColor = UIColor(named: "FJDarkBlue")
            config.baseForegroundColor = .white
            shareB.configuration = config
            shareB.addTarget(self, action: #selector(shareBTapped(_:)), for: .touchUpInside)
        }
        
    }
    
    func configureEditButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: "pencil.circle")
            config.title = " Edit Effort Header"
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            editB.configuration = config
            editB.addTarget(self, action: #selector(editBTapped(_:)), for: .touchUpInside)
        }
        
    }
    
    func configureNSLayouts() {
        
        if subscriptionBought {
            NSLayoutConstraint.activate([
                
                iconIV.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
                iconIV.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
                iconIV.heightAnchor.constraint(equalToConstant: 65),
                iconIV.widthAnchor.constraint(equalToConstant: 65),
                
                titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                titleL.topAnchor.constraint(equalTo: iconIV.topAnchor),
                titleL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                titleL.heightAnchor.constraint(equalToConstant: 24),
                
                typeL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                typeL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 5),
                typeL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                typeL.heightAnchor.constraint(equalToConstant: 15),
                
                dateL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                dateL.topAnchor.constraint(equalTo: typeL.bottomAnchor, constant: 5),
                dateL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                dateL.heightAnchor.constraint(equalToConstant: 15),
                
                shareB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
                shareB.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                shareB.topAnchor.constraint(equalTo: dateL.bottomAnchor, constant: 7),
                shareB.heightAnchor.constraint(equalToConstant: 45),
                
                editB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
                editB.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                editB.topAnchor.constraint(equalTo: shareB.bottomAnchor, constant: 7),
                editB.heightAnchor.constraint(equalToConstant: 45),
                
                
            ])
        } else {
            NSLayoutConstraint.activate([
                
                iconIV.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
                iconIV.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
                iconIV.heightAnchor.constraint(equalToConstant: 65),
                iconIV.widthAnchor.constraint(equalToConstant: 65),
                
                titleL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                titleL.topAnchor.constraint(equalTo: iconIV.topAnchor),
                titleL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                titleL.heightAnchor.constraint(equalToConstant: 24),
                
                typeL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                typeL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 5),
                typeL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                typeL.heightAnchor.constraint(equalToConstant: 15),
                
                dateL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
                dateL.topAnchor.constraint(equalTo: typeL.bottomAnchor, constant: 5),
                dateL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
                dateL.heightAnchor.constraint(equalToConstant: 15),
                
            ])
        }
        
    }
    
    @objc func shareBTapped(_ sender: UIButton) {
        delegate?.theShareButtonTapped( self.theICs214FormOID)
    }
    
    @objc func editBTapped(_ sender: UIButton) {
        delegate?.theEditButtonTapped( self.theICs214FormOID)
    }
    
}
