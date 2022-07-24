//
//  CampaignTypeHeaderV.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/15/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit
import Foundation

protocol  CampaignTypeHeaderVDelegate: AnyObject {
    func campaignTypeHeaderBackTapped()
    func campaignTypeHeaderAddTapped(residenceType: String, type: EntityType)
    func campaignTypeHeaderSaveTapped( )
}

class CampaignTypeHeaderV: UIView {

//    MARK: -OBJECTS-
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var addB: UIButton!
    @IBOutlet weak var saveB: UIButton!
    
//    MARK: -PROPERTIES-
    private var subject: String = ""
    var theSubject: String? {
        didSet {
            self.subject = self.theSubject ?? ""
            self.subjectL.text = self.subject
        }
    }
    
    weak var delegate: CampaignTypeHeaderVDelegate? = nil
    
    private var residenceType: String = ""
    var theResidence: String? {
        didSet {
            self.residenceType = self.theResidence ?? ""
        }
    }
    
    private var type: EntityType = .residence
    var theType: EntityType? {
        didSet {
            self.type = theType ?? .residence
            switch self.type {
            case .nationalPartner:
                self.theSubject = "Naational Partner:"
            case .localPartners:
                self.theSubject = "Local Partner(s):"
            case .residence:
                self.theSubject = "Campaign Residence Type:"
            }
            if self.type == .localPartners {
                self.saveB.isHidden = false
                self.saveB.alpha = 1.0
            } else {
                self.saveB.isHidden = true
                self.saveB.alpha = 0.0
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func addbTapped(_ sender: Any) {
        _ = self.textFieldShouldEndEditing(self.descriptionTF)
        delegate?.campaignTypeHeaderAddTapped(residenceType: residenceType, type: type)
    }
    
    /// Multiple selections made for LocalPartners
    /// - Parameter sender: self
    @IBAction func saveBTapped(_ sender: Any) {
        delegate?.campaignTypeHeaderSaveTapped()
    }
    
    @IBAction func backBTapped(_ sender: Any) {
        delegate?.campaignTypeHeaderBackTapped()
    }
    
}

extension CampaignTypeHeaderV: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            theResidence = text
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            theResidence = text
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            theResidence = text
        }
        return true
    }
    
}
