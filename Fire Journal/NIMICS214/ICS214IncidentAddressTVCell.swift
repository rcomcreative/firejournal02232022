//
//  ICS214IncidentAddressTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/6/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class ICS214IncidentAddressTVCell: UITableViewCell {
    
    let headerL = UILabel()
    let iconIV = UIImageView()
    let addressL = UILabel()
    let latitudeL = UILabel()
    let longitudeL =  UILabel()
    
    private var theHeader: String = ""
    var header: String = "" {
        didSet {
            self.theHeader = self.header
            self.headerL.text = self.theHeader
        }
    }
    
    private var theImageName: String = ""
    var imageName: String = "" {
        didSet {
            self.theImageName = self.imageName
            let image = UIImage(named: self.theImageName)
            if image != nil {
                self.iconIV.image = image
            }
        }
    }
    
    private var theAddress: String = ""
    var address: String = "" {
        didSet {
            self.theAddress = self.address
            self.addressL.text = self.theAddress
        }
    }
    
    private var theLatitude: String = ""
    var latitude: String = "" {
        didSet {
            self.theLatitude = self.latitude
            self.latitudeL.text = self.theLatitude
        }
    }
    
    private var theLongitude: String = ""
    var longitude: String = "" {
        didSet {
            self.theLongitude = self.longitude
            self.longitudeL.text = self.theLongitude
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
    }

}

extension ICS214IncidentAddressTVCell {
    
    func configure() {
        
        headerL.translatesAutoresizingMaskIntoConstraints = false
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        addressL.translatesAutoresizingMaskIntoConstraints = false
        latitudeL.translatesAutoresizingMaskIntoConstraints = false
        longitudeL.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(headerL)
        self.contentView.addSubview(iconIV)
        self.contentView.addSubview(addressL)
        self.contentView.addSubview(latitudeL)
        self.contentView.addSubview(longitudeL)
        
        configureLabels()
        configureNSLayout()
        
    }
    
    func configureLabels() {
        
        headerL.textAlignment = .left
        headerL.font = .systemFont(ofSize: 24, weight: .semibold )
        headerL.textColor = .label
        headerL.adjustsFontForContentSizeCategory = false
        
        addressL.textAlignment = .left
        addressL.font = .systemFont(ofSize: 14)
        addressL.textColor = .label
        addressL.adjustsFontForContentSizeCategory = false
        addressL.lineBreakMode = NSLineBreakMode.byWordWrapping
        addressL.numberOfLines = 0
        
        latitudeL.textAlignment = .left
        latitudeL.font = .systemFont(ofSize: 14)
        latitudeL.textColor = .label
        latitudeL.adjustsFontForContentSizeCategory = false
        
        longitudeL.textAlignment = .left
        longitudeL.font = .systemFont(ofSize: 14)
        longitudeL.textColor = .label
        longitudeL.adjustsFontForContentSizeCategory = false
        
    }
    
    func configureNSLayout() {
        
        NSLayoutConstraint.activate([
        
            headerL.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            headerL.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5),
            headerL.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
            headerL.heightAnchor.constraint(equalToConstant: 29),
            
            iconIV.leadingAnchor.constraint(equalTo: headerL.leadingAnchor),
            iconIV.topAnchor.constraint(equalTo: headerL.bottomAnchor, constant: 5),
            iconIV.heightAnchor.constraint(equalToConstant: 55),
            iconIV.widthAnchor.constraint(equalToConstant: 55),
            
            addressL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
            addressL.topAnchor.constraint(equalTo: iconIV.topAnchor),
            addressL.trailingAnchor.constraint(equalTo: headerL.trailingAnchor),
            addressL.heightAnchor.constraint(equalToConstant: 20),
            
            latitudeL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
            latitudeL.topAnchor.constraint(equalTo: addressL.bottomAnchor, constant: 5),
            latitudeL.trailingAnchor.constraint(equalTo: headerL.trailingAnchor),
            latitudeL.heightAnchor.constraint(equalToConstant: 15),
            
            longitudeL.leadingAnchor.constraint(equalTo: iconIV.trailingAnchor, constant: 10),
            longitudeL.topAnchor.constraint(equalTo: latitudeL.bottomAnchor, constant: 5),
            longitudeL.trailingAnchor.constraint(equalTo: headerL.trailingAnchor),
            longitudeL.heightAnchor.constraint(equalToConstant: 15),
            
        ])
            
    }
    
}
