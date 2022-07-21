    //
    //  SettingsYourDataWarningVC.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 7/5/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit

protocol SettingsYourDataWarningVCDelegate: AnyObject {
    func cancelThisProcedure()
    func removeAllButtonTapped()
}

class SettingsYourDataWarningVC: UIViewController {
    
    var delegate: SettingsYourDataWarningVCDelegate? = nil
    
    let warningIconIV = UIImageView()
    let theBackgroundView = UIView()
    let aBackgroundView = UIView()
    var warningSubjectL = UILabel()
    let warningL = UILabel()
    let warningButton = UIButton(primaryAction: nil)
    let cancelThisButton = UIButton(primaryAction: nil)
    var short: Bool = false
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        if Device.IS_IPHONE {
            if Device.IS_IPHONE_6P || Device.IS_IPHONE_6{
                short = true
            }
        }
        configure()
    }
    
    
}

extension SettingsYourDataWarningVC {
    
    func configure() {
        
        aBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        warningIconIV.translatesAutoresizingMaskIntoConstraints = false
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        warningL.translatesAutoresizingMaskIntoConstraints = false
        warningSubjectL.translatesAutoresizingMaskIntoConstraints = false
        warningButton.translatesAutoresizingMaskIntoConstraints = false
        cancelThisButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(aBackgroundView)
        self.aBackgroundView.addSubview(warningIconIV)
        self.aBackgroundView.addSubview(theBackgroundView)
        self.theBackgroundView.addSubview(warningL)
        self.theBackgroundView.addSubview(warningSubjectL)
        self.theBackgroundView.addSubview(warningButton)
        self.theBackgroundView.addSubview(cancelThisButton)
        configureObjects()
        configureNSLayout()
        
    }
    
    func configureObjects() {
        
        aBackgroundView.backgroundColor = .label
        theBackgroundView.backgroundColor = .white
        theBackgroundView.layer.cornerRadius = 8
        theBackgroundView.layer.borderColor = UIColor(named: "FJIconRed")?.cgColor
        theBackgroundView.layer.borderWidth = 2
        
        let warningTextSubject = "Warning!"
        let warningText = """
Are you sure?

Clicking the remove data button will clear all of the data that you have captured for incidents, journal, projects, ICS214, CRR Smoke Alarm Inspection Forms, contacts and personal data. This will be deleted from your iCloud account and from your devices.

Remember, this is a permanent action. This will return this app to the pre Agreement status.
"""
        
        let image = UIImage(systemName: "hand.raised.square")
        if image != nil {
            warningIconIV.image = image
            warningIconIV.tintColor = UIColor(named: "FJIconRed")
        }
        
        warningSubjectL.textAlignment = .center
        warningSubjectL.font = .systemFont(ofSize: 60, weight: UIFont.Weight(rawValue: 300))
        warningSubjectL.textColor = UIColor(named: "FJIconRed")
        warningSubjectL.adjustsFontForContentSizeCategory = false
        warningSubjectL.lineBreakMode = NSLineBreakMode.byWordWrapping
        warningSubjectL.numberOfLines = 0
        warningSubjectL.text = warningTextSubject
        
        warningL.textAlignment = .natural
        warningL.font = .systemFont(ofSize: 17)
        warningL.textColor = .black
        warningL.adjustsFontForContentSizeCategory = false
        warningL.lineBreakMode = NSLineBreakMode.byWordWrapping
        warningL.numberOfLines = 0
        warningL.text = warningText
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.title = " Remove Data"
            config.image = UIImage(systemName: "hand.raised.square")
            config.baseForegroundColor = .white
            warningButton.configuration = config
        }
        
        warningButton.addTarget(self, action: #selector(warningButtonTapped), for: .touchUpInside)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.baseBackgroundColor = UIColor(named: "FJDarkBlue")
            config.title = " Cancel"
            config.image = UIImage(systemName: "xmark.circle")
            config.baseForegroundColor = .white
            cancelThisButton.configuration = config
        }
        
        cancelThisButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    func configureNSLayout() {
        
        if short {
            NSLayoutConstraint.activate([
                
                aBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
                aBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                aBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                aBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                
                warningIconIV.centerXAnchor.constraint(equalTo: aBackgroundView.centerXAnchor),
                warningIconIV.topAnchor.constraint(equalTo: aBackgroundView.topAnchor, constant: 55),
                warningIconIV.widthAnchor.constraint(equalToConstant: 75),
                warningIconIV.heightAnchor.constraint(equalToConstant: 75),
                
                
                theBackgroundView.leadingAnchor.constraint(equalTo: aBackgroundView.leadingAnchor, constant: 10),
                theBackgroundView.trailingAnchor.constraint(equalTo: aBackgroundView.trailingAnchor, constant: -10),
                theBackgroundView.topAnchor.constraint(equalTo: aBackgroundView.topAnchor, constant: 135),
                theBackgroundView.bottomAnchor.constraint(equalTo: aBackgroundView.bottomAnchor),


                warningSubjectL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 25),
                warningSubjectL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -25),
                warningSubjectL.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 25),
                warningSubjectL.heightAnchor.constraint(equalToConstant: 70),
                warningSubjectL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),

                warningL.leadingAnchor.constraint(equalTo: warningSubjectL.leadingAnchor),
                warningL.trailingAnchor.constraint(equalTo: warningSubjectL.trailingAnchor),
                warningL.topAnchor.constraint(equalTo: warningSubjectL.bottomAnchor, constant: 3),
                warningL.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -180),

                cancelThisButton.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 26),
                cancelThisButton.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -26),
                cancelThisButton.topAnchor.constraint(equalTo: warningL.bottomAnchor, constant: 10),
                cancelThisButton.heightAnchor.constraint(equalToConstant: 45),

                warningButton.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 26),
                warningButton.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -26),
                warningButton.topAnchor.constraint(equalTo: cancelThisButton.bottomAnchor, constant: 10),
                warningButton.heightAnchor.constraint(equalToConstant: 45),
                
                ])
        } else {
        NSLayoutConstraint.activate([
            
            aBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            aBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            aBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            aBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            warningIconIV.centerXAnchor.constraint(equalTo: aBackgroundView.centerXAnchor),
            warningIconIV.topAnchor.constraint(equalTo: aBackgroundView.topAnchor, constant: 105),
            warningIconIV.widthAnchor.constraint(equalToConstant: 150),
            warningIconIV.heightAnchor.constraint(equalToConstant: 150),
            
            
            theBackgroundView.leadingAnchor.constraint(equalTo: aBackgroundView.leadingAnchor, constant: 10),
            theBackgroundView.trailingAnchor.constraint(equalTo: aBackgroundView.trailingAnchor, constant: -10),
            theBackgroundView.topAnchor.constraint(equalTo: aBackgroundView.topAnchor, constant: 305),
            theBackgroundView.bottomAnchor.constraint(equalTo: aBackgroundView.bottomAnchor, constant: -95),


            warningSubjectL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 25),
            warningSubjectL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -25),
            warningSubjectL.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 25),
            warningSubjectL.heightAnchor.constraint(equalToConstant: 70),
            warningSubjectL.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor),

            warningL.leadingAnchor.constraint(equalTo: warningSubjectL.leadingAnchor),
            warningL.trailingAnchor.constraint(equalTo: warningSubjectL.trailingAnchor),
            warningL.topAnchor.constraint(equalTo: warningSubjectL.bottomAnchor, constant: 3),
            warningL.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -155),

            cancelThisButton.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 26),
            cancelThisButton.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -26),
            cancelThisButton.topAnchor.constraint(equalTo: warningL.bottomAnchor, constant: 10),
            cancelThisButton.heightAnchor.constraint(equalToConstant: 55),

            warningButton.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 26),
            warningButton.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -26),
            warningButton.topAnchor.constraint(equalTo: cancelThisButton.bottomAnchor, constant: 10),
            warningButton.heightAnchor.constraint(equalToConstant: 55),
            
            ])
        }
    }
    
    @objc func cancelButtonTapped() {
        delegate?.cancelThisProcedure()
    }
    
        //    MARK: -REMOVE DATA
    /**Begin Data Removal
     
    • Call to Notification
     fireJournalRemoveAllDataFromCloudKit
     observed by CloudKitManager
    • Returns to SettingsYourDataVC
     where userDefaults are updated
     to true for FJkREMOVEALLDATA
    • App returns to SettingsVC
     and spinner
         */
    @objc func warningButtonTapped() {
        DispatchQueue.main.async {
            self.nc.post(name: .fireJournalRemoveAllDataFromCloudKit, object: nil)
        }
        delegate?.removeAllButtonTapped()
    }
    
}
