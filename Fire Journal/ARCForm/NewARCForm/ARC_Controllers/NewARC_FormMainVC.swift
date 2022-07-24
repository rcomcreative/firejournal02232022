//
//  ARC_FormMainVC.swift
//  Fire Journal
//
//  Created by DuRand Jones on 7/22/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit
import CoreData

protocol NewARC_FormMainVCDelegate: AnyObject {
    func theCampaignButtonTapped(userTimeOID: NSManagedObjectID, userOID: NSManagedObjectID)
    func theSingleFormButtonTapped(userTimeOID: NSManagedObjectID, userOID: NSManagedObjectID)
}

class NewARC_FormMainVC: UIViewController {
    
    var modalHeaderV: ModalHeaderSaveDismiss!
    
    lazy var slideInTransitioningDelgate = SlideInPresentationManager()
    let newCampaignB = UIButton(primaryAction: nil)
    let newSingleB = UIButton(primaryAction: nil)
    let headerTitle: String = "CRR Smoke Alarm"
    var alertUp: Bool = false
    var theBackgroundView = UIView()
    var theBackgroundViewIV = UIImageView()
    var userOID: NSManagedObjectID!
    var userTimeOID: NSManagedObjectID!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var theUser: FireJournalUser!
    var theUserTime: UserTime!
    
    weak var delegate: NewARC_FormMainVCDelegate? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if userOID == nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            theUser = context.object(with: userOID) as? FireJournalUser
            if userTimeOID == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                theUserTime = context.object(with: userTimeOID) as? UserTime
            }
        }
        configureModalHeaderSaveDismiss()
         configureTheBody()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
}

extension NewARC_FormMainVC {
    
    func configureModalHeaderSaveDismiss() {
        modalHeaderV = Bundle.main.loadNibNamed("ModalHeaderSaveDismiss", owner: self, options: nil)?.first as? ModalHeaderSaveDismiss
        modalHeaderV.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(modalHeaderV)
        modalHeaderV.modalHTitleL.textColor = UIColor.white
        modalHeaderV.modalHCancelB.setTitle("Cancel",for: .normal)
        modalHeaderV.modalHCancelB.setTitleColor(UIColor.white, for: .normal)
        modalHeaderV.modalHSaveB.isHidden = true
        modalHeaderV.modalHSaveB.isEnabled = false
        modalHeaderV.modalHSaveB.alpha = 0.0
        modalHeaderV.modalHTitleL.text = headerTitle
        modalHeaderV.infoB.setTitle("", for: .normal)
        if let color = UIColor(named: "FJIconRed") {
            modalHeaderV.contentView.backgroundColor = color
        }
        modalHeaderV.myShift = MenuItems.incidents
        modalHeaderV.delegate = self
        
        NSLayoutConstraint.activate([
            modalHeaderV.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            modalHeaderV.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            modalHeaderV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            modalHeaderV.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureTheBody() {
        
        theBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        theBackgroundViewIV.translatesAutoresizingMaskIntoConstraints = false
        newCampaignB.translatesAutoresizingMaskIntoConstraints = false
        newSingleB.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(theBackgroundView)
        theBackgroundView.addSubview(theBackgroundViewIV)
        theBackgroundView.addSubview(newCampaignB)
        theBackgroundView.addSubview(newSingleB)
        configureTheBackgroundView()
        configureCampaignB()
        configureSingleB()
        configureNSLayout()
    }
    
    func configureTheBackgroundView() {
        
        let image = UIImage(named: "cell-back")
        if image != nil {
            theBackgroundViewIV.image = image
            theBackgroundViewIV.contentMode = .scaleToFill
        }
        
    }
    
    func configureCampaignB() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: "folder.badge.plus")
            config.title = " Campaign"
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            newCampaignB.configuration = config
            newCampaignB.addTarget(self, action: #selector(campaignBTapped(_:)), for: .touchUpInside)
        }
    }
    
    func configureSingleB() {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: "doc.fill.badge.plus")
            config.title = " Single"
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            newSingleB.configuration = config
            newSingleB.addTarget(self, action: #selector(singleBTapped(_:)), for: .touchUpInside)
        }
    }
    
    func configureNSLayout() {
        NSLayoutConstraint.activate([
            
            theBackgroundView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            theBackgroundView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            theBackgroundView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            theBackgroundView.topAnchor.constraint(equalTo: modalHeaderV.bottomAnchor),
            
            theBackgroundViewIV.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor),
            theBackgroundViewIV.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor),
            theBackgroundViewIV.topAnchor.constraint(equalTo: theBackgroundView.topAnchor),
            theBackgroundViewIV.bottomAnchor.constraint(equalTo: theBackgroundView.bottomAnchor),
            
            newCampaignB.centerXAnchor.constraint(equalTo: theBackgroundView.centerXAnchor, constant: -65),
            newCampaignB.centerYAnchor.constraint(equalTo: theBackgroundView.centerYAnchor),
            newCampaignB.leadingAnchor.constraint(equalTo: theBackgroundView.leadingAnchor, constant: 35),
            newCampaignB.trailingAnchor.constraint(equalTo: theBackgroundView.trailingAnchor, constant: -35),
            newCampaignB.heightAnchor.constraint(equalToConstant: 65),
            
            newSingleB.leadingAnchor.constraint(equalTo: newCampaignB.leadingAnchor),
            newSingleB.topAnchor.constraint(equalTo: newCampaignB.bottomAnchor, constant: 65),
            newSingleB.trailingAnchor.constraint(equalTo: newCampaignB.trailingAnchor),
            newSingleB.heightAnchor.constraint(equalToConstant: 65),
            
            ])
    }
    
    @objc func campaignBTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.delegate?.theCampaignButtonTapped(userTimeOID: self.userTimeOID, userOID: self.userOID)
        })
    }
    
    @objc func singleBTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.delegate?.theSingleFormButtonTapped(userTimeOID: self.userTimeOID, userOID: self.userOID)
        })
    }
    
}

extension NewARC_FormMainVC:  ModalHeaderSaveDismissDelegate {
    
    func modalDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func modalSave(myShift: MenuItems) {}
    
    func modalInfoBTapped(myShift: MenuItems) {
        presentAlert()
    }
    
    func presentAlert() {
        let title: InfoBodyText = .arcFormSubject
        let message: InfoBodyText = .arcFormDescription
        let alert = UIAlertController.init(title: title.rawValue, message: message.rawValue, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Okay", style: .default, handler: {_ in
            self.alertUp = false
        })
        alert.addAction(okAction)
        alertUp = true
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
