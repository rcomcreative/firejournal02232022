//
//  SettingsYourDataVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/2/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import Foundation
import CoreData

protocol SettingsYourDataVCDelegate: AnyObject {
    func settingsYourDateReturnToSettings()
}

class SettingsYourDataVC: UIViewController {
    
    var delegate: SettingsYourDataVCDelegate? = nil
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    
    let nc = NotificationCenter.default
    var titleName: String = ""
    private let vcLaunch = VCLaunch()
    private var launchNC: LaunchNotifications!
    var compact:SizeTrait = .regular
    var collapsed:Bool = false
    var settingsType: FJSettings!
    
    let theBackgroundView = UIView()
    let theHeaderView = UIView()
    let headerL = UILabel()
    let descriptionTV = UITextView()
    var theDataText: String!
    let dataButton = UIButton(primaryAction: nil)
    var userObjectID: NSManagedObjectID!
    var theUser: FireJournalUser!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        vcLaunch.splitVC = self.splitViewController
        if userObjectID != nil {
            vcLaunch.userID = userObjectID
            theUser = context.object(with: userObjectID) as? FireJournalUser
        }
        launchNC = LaunchNotifications.init(launchVC: vcLaunch)
        launchNC.callNotifications()
        configureNavigationHeader()
        titleName = "Your Data"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        theDataText = buildTheDataText()
        configureObjects()
        configureNSLayouts()
    }
    
    func configureNavigationHeader() {
//        if Device.IS_IPHONE {
            let listButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(goBackToSettings(_:)))
            navigationItem.leftBarButtonItem = listButton
            navigationItem.setLeftBarButtonItems([listButton], animated: true)
            navigationItem.leftItemsSupplementBackButton = false
            let regularBarButtonTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 150))
            ]
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .normal)
            listButton.setTitleTextAttributes(regularBarButtonTextAttributes, for: .highlighted)
//        }
        
        
        if (Device.IS_IPHONE){
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            let navigationBarAppearace = UINavigationBar.appearance()
            navigationBarAppearace.tintColor = UIColor.black
        } else {
                self.navigationController?.navigationBar.backgroundColor = UIColor.white
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = UIColor.black
        }
    }
    
    @objc func goBackToSettings(_ sender: Any) {
        if collapsed {
            delegate?.settingsYourDateReturnToSettings()
        } else {
            DispatchQueue.main.async {
                if let id = self.userObjectID {
                    self.nc.post(name:Notification.Name(rawValue: FJkSETTINGS_FROM_MASTER),
                                 object: nil,
                                 userInfo: ["sizeTrait":self.compact, "userObjID": id])
                }
            }
        }
    }

}

extension SettingsYourDataVC {
    
    func configureObjects() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerL.translatesAutoresizingMaskIntoConstraints = false
        descriptionTV.translatesAutoresizingMaskIntoConstraints = false
        dataButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(theBackgroundView)
        self.view.addSubview(theHeaderView)
        self.view.addSubview(headerL)
        self.view.addSubview(descriptionTV)
        self.view.addSubview(dataButton)
        
        theHeaderView.backgroundColor = UIColor(named: "FJBlueColor")
        
        headerL.textAlignment = .left
        headerL.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
        headerL.textColor = .white
        headerL.adjustsFontForContentSizeCategory = false
        headerL.lineBreakMode = NSLineBreakMode.byWordWrapping
        headerL.numberOfLines = 0
        headerL.text = titleName
        
        descriptionTV.textAlignment = .left
        if Device.IS_IPHONE {
        descriptionTV.font = .systemFont(ofSize: 16)
        } else {
            descriptionTV.font = .systemFont(ofSize: 20)
        }
        descriptionTV.textColor = .label
        descriptionTV.adjustsFontForContentSizeCategory = true
        descriptionTV.layer.borderColor = UIColor(named: "FJBlueColor" )?.cgColor
        descriptionTV.layer.borderWidth = 0.5
        descriptionTV.layer.cornerRadius = 8
        descriptionTV.isUserInteractionEnabled = true
        descriptionTV.isScrollEnabled = true
        descriptionTV.text = theDataText
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.title = " Delete Your Data"
            config.image = UIImage(systemName: "hand.raised.square")
            config.baseForegroundColor = .white
            dataButton.configuration = config
            dataButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
    }
    
    func configureNSLayouts() {
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: self.view.topAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            theHeaderView.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor),
            theHeaderView.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor),
            theHeaderView.topAnchor.constraint(equalTo: theBackgroundView.topAnchor, constant: 44),
            theHeaderView.heightAnchor.constraint(equalToConstant: 100),
            
            headerL.leadingAnchor.constraint(equalTo: theHeaderView.leadingAnchor, constant: 25),
            headerL.trailingAnchor.constraint(equalTo: theHeaderView.trailingAnchor, constant: -36),
            headerL.heightAnchor.constraint(equalToConstant: 50),
            headerL.centerYAnchor.constraint(equalTo: theHeaderView.centerYAnchor),
            
            descriptionTV.leadingAnchor.constraint(equalTo: headerL.leadingAnchor),
            descriptionTV.trailingAnchor.constraint(equalTo: headerL.trailingAnchor),
            descriptionTV.topAnchor.constraint(equalTo: theHeaderView.bottomAnchor, constant: 15),
            descriptionTV.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -130),
            
            dataButton.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 26),
            dataButton.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -26),
            dataButton.topAnchor.constraint(equalTo: descriptionTV.bottomAnchor, constant: 20),
            dataButton.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor, constant: -55),
            
            ])
    }
    
    @objc func buttonTapped() {
        slideInTransitioningDelgate.direction = .bottom
        slideInTransitioningDelgate.disableCompactHeight = true
        let storyBoard : UIStoryboard = UIStoryboard(name: "SettingsYourDataWarning", bundle:nil)
        let controller: SettingsYourDataWarningVC = storyBoard.instantiateViewController(withIdentifier:"SettingsYourDataWarningVC") as! SettingsYourDataWarningVC
        controller.delegate = self
        controller.transitioningDelegate = slideInTransitioningDelgate
        controller.modalPresentationStyle = .custom
        present(controller, animated: true)
    }
    
    func buildTheDataText() -> String {
    let theYourDataText = """
You have the option to DELETE all of the data for Fire Journal on your smart device and in your iCloud account.

This action cannot be undone. Proceed with caution.

If you do this, Fire Journal will revert to its “As Downloaded” status. All of your data will be deleted. If you’re doing this to restart the data acquisition process with Fire Journal, there is nothing you need to do once you submit a request to delete all of your data. If you are discontinuing your use of Fire Journal, and if you have a subscription, make certain you access your “dot Mac” account and under the subscriptions option, cancel your Fire Journal subscription. Cancellation is subject to the terms and conditions set forth when you originally subscribed.

Remember, this is a permanent action.

If you want to delete all of your Fire Journal data, do so using the Delete Your Data button below.
"""
        return theYourDataText
    }
    
}

extension SettingsYourDataVC: SettingsYourDataWarningVCDelegate {
    
    func cancelThisProcedure() {
        self.dismiss(animated: true, completion: {
            self.goBackToSettings(self)
        })
    }
    
    
        //    MARK: -REMOVE DATA
    /**Send back to SettingsTVC
     
     mark FJkREMOVEALLDATA as true
     */
    func removeAllButtonTapped() {
        self.dismiss(animated: true, completion: {
            self.userDefaults.set(true, forKey: FJkREMOVEALLDATA)
            self.goBackToSettings(self)
        })
    }
    
    
}
