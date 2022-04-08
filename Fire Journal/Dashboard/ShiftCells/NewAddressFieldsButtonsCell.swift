//
//  AddressFieldsButtonsCell.swift
//  dashboard
//
//  Created by DuRand Jones on 8/18/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol NewAddressFieldsButtonsCellDelegate: AnyObject {
    func worldBTapped(tag: Int)
    func worldB2Tapped(tag: Int)
    func locationBTapped(tag: Int)
}

class NewAddressFieldsButtonsCell: UITableViewCell, UITextFieldDelegate {
    
    //    MARK: -OBJECTS
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var addressLatitudeTF: UITextField!
    @IBOutlet weak var addressLongitudeTF: UITextField!
    
    let newMapB = UIButton(primaryAction: nil)
    let newLocationB = UIButton(primaryAction: nil)
    
    //    MARK: -PROPERTIES
    var myShift: MenuItems! = nil
    weak var delegate: NewAddressFieldsButtonsCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
    
    func configureNewLocationButton(type: IncidentTypes) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .small
            config.image = UIImage(systemName: "location")
            config.title = " Location"
            switch type {
            case .deptMember:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            case .journal:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            default:
                config.baseBackgroundColor = UIColor(named: "FJIconRed")
            }
            config.baseForegroundColor = .white
            newLocationB.configuration = config
            
            newLocationB.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
            
            newLocationB.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(newLocationB)
            if Device.IS_IPHONE {
                NSLayoutConstraint.activate([
                    newLocationB.topAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -60),
                    newLocationB.widthAnchor.constraint(equalToConstant: 150),
                    newLocationB.trailingAnchor.constraint(equalTo: newMapB.leadingAnchor, constant: -35),
                    newLocationB.heightAnchor.constraint(equalToConstant: 40),
                    ])
            } else {
            NSLayoutConstraint.activate([
                newLocationB.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                newLocationB.widthAnchor.constraint(equalToConstant: 150),
                newLocationB.trailingAnchor.constraint(equalTo: newMapB.leadingAnchor, constant: -35),
                newLocationB.heightAnchor.constraint(equalToConstant: 40),
                ])
            }
            
        }
    }
    
    func configureNewMapButton(type: IncidentTypes) {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .small
            config.image = UIImage(systemName: "map")
            config.title = " Map"
            switch type {
            case .deptMember:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            case .journal:
                config.baseBackgroundColor = UIColor(named: "FJBlueColor")
            default:
                config.baseBackgroundColor = UIColor(named: "FJIconRed")
            }
            config.baseForegroundColor = .white
            newMapB.configuration = config
            
            newMapB.addTarget(self, action: #selector(mapBTapped), for: .touchUpInside)
            
            newMapB.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(newMapB)
            if Device.IS_IPHONE {
                NSLayoutConstraint.activate([
                    newMapB.topAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -60),
                    newMapB.widthAnchor.constraint(equalToConstant: 100),
                    newMapB.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -35),
                    newMapB.heightAnchor.constraint(equalToConstant: 40),
                    ])
            } else {
            NSLayoutConstraint.activate([
                newMapB.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                newMapB.widthAnchor.constraint(equalToConstant: 100),
                newMapB.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -35),
                newMapB.heightAnchor.constraint(equalToConstant: 40),
                ])
            }
        }
    }
    
    @objc func locationTapped() {
        delegate?.locationBTapped(tag: self.tag)
    }
    
    @objc func mapBTapped() {
            delegate?.worldBTapped(tag: self.tag)
    }
    
    
    //    MARK: -textFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
}
