//
//  NewOnboardOneVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/19/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class NewOnboardOneVC: UIViewController {
    
    
    let theIconIV = UIImageView()
    let theBackgroundView = UIView()
    let fireL = UILabel()
    let journalL = UILabel()
    let titleL = UILabel()
    let descriptionL = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        configure()
    }
    
    func configure() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theIconIV.translatesAutoresizingMaskIntoConstraints = false
        fireL.translatesAutoresizingMaskIntoConstraints = false
        journalL.translatesAutoresizingMaskIntoConstraints = false
        titleL.translatesAutoresizingMaskIntoConstraints = false
        descriptionL.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(theBackgroundView)
        self.view.addSubview(theIconIV)
        self.view.addSubview(fireL)
        self.view.addSubview(journalL)
        self.view.addSubview(titleL)
        self.view.addSubview(descriptionL)
        setUpObjects()
        buildTheNSLayouts()
    }
    
    func setUpObjects() {
        
        theBackgroundView.backgroundColor = UIColor(named: "FJBlueColor")
        
        let iconImage = UIImage(named: "flameLogoCutOut")
        if iconImage != nil {
            theIconIV.image = iconImage
        }
        
        fireL.textAlignment = .left
        fireL.font = .systemFont(ofSize: 34, weight: UIFont.Weight(rawValue: 100))
        fireL.textColor = .white
        fireL.adjustsFontForContentSizeCategory = false
        fireL.lineBreakMode = NSLineBreakMode.byWordWrapping
        fireL.numberOfLines = 0
        fireL.text = "Fire"
        
        journalL.textAlignment = .left
        journalL.font = .systemFont(ofSize: 34, weight: UIFont.Weight(rawValue: 100))
        journalL.textColor = .white
        journalL.adjustsFontForContentSizeCategory = false
        journalL.lineBreakMode = NSLineBreakMode.byWordWrapping
        journalL.numberOfLines = 0
        journalL.text = "Journal"
        
        titleL.textAlignment = .left
        titleL.font = .systemFont(ofSize: 30)
        titleL.textColor = .label
        titleL.adjustsFontForContentSizeCategory = false
        titleL.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleL.numberOfLines = 0
        titleL.text = "Welcome!"
        
        descriptionL.textAlignment = .left
        descriptionL.font = .systemFont(ofSize: 20)
        descriptionL.textColor = .label
        descriptionL.adjustsFontForContentSizeCategory = false
        descriptionL.lineBreakMode = NSLineBreakMode.byWordWrapping
        descriptionL.numberOfLines = 0
        descriptionL.text = """
We’re delighted that you’ve chosen to manage your firefighting career with Fire Journal. Using this easy-to-use and informative app, you will have never before seen capabilities to manage and track important aspects of your career.
The following screens will help explain how to get started.
"""
    }
    
    func buildTheNSLayouts() {
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            theBackgroundView.heightAnchor.constraint(equalToConstant: 175),
            
            theIconIV.centerYAnchor.constraint(equalTo: theBackgroundView.centerYAnchor),
            theIconIV.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor, constant: -75),
            theIconIV.heightAnchor.constraint(equalToConstant: 130),
            theIconIV.widthAnchor.constraint(equalToConstant: 130),
            
            fireL.leadingAnchor.constraint(equalTo: theIconIV.trailingAnchor, constant: 20),
            fireL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -10),
            fireL.centerYAnchor.constraint(equalTo: theIconIV.centerYAnchor, constant: -20),
            fireL.heightAnchor.constraint(equalToConstant: 30),
            
            journalL.leadingAnchor.constraint(equalTo: fireL.leadingAnchor),
            journalL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -10),
            journalL.centerYAnchor.constraint(equalTo: fireL.bottomAnchor, constant: 25),
            journalL.heightAnchor.constraint(equalToConstant: 30),
            
            titleL.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 25),
            titleL.topAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: 10),
            titleL.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -25),
            titleL.heightAnchor.constraint(equalToConstant: 45),
            
            descriptionL.leadingAnchor.constraint(equalTo: titleL.leadingAnchor),
            descriptionL.trailingAnchor.constraint(equalTo: titleL.trailingAnchor),
            descriptionL.topAnchor.constraint(equalTo: titleL.bottomAnchor, constant: 10),
            descriptionL.heightAnchor.constraint(equalToConstant: 250),
            
            ])
    }
    
}
