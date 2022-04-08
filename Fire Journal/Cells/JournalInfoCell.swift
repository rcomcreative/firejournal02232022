//
//  JournalInfoCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/10/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol JournalInfoCellDelegate: AnyObject {
    func theInfoBTapped()
}

class JournalInfoCell: UITableViewCell,UITextFieldDelegate {
    //    MARK: -Objects
    @IBOutlet weak var infoB: UIButton!
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var entryTypeTF: UITextField!
    @IBOutlet weak var fireStationTF: UITextField!
    @IBOutlet weak var platoonTF: UITextField!
    @IBOutlet weak var assignmentTF: UITextField!
    @IBOutlet weak var apparatusTF: UITextField!
    @IBOutlet weak var label1L: UILabel!
    @IBOutlet weak var label2L: UILabel!
    @IBOutlet weak var label3L: UILabel!
    @IBOutlet weak var label4L: UILabel!
    @IBOutlet weak var label5L: UILabel!
    @IBOutlet weak var label6L: UILabel!
    weak var delegate:JournalInfoCellDelegate? = nil
    
    
    private var theSubject: String = ""
    var subject: String = "" {
        didSet {
            self.theSubject = self.subject
            self.subjectL.text = self.theSubject
        }
    }
    private var theUser: String = ""
    var user: String = "" {
        didSet {
            self.theUser = self.user
            self.userTF.text = self.theUser
        }
    }
    private var theEntryType: String = ""
    var entryType: String = "" {
        didSet {
            self.theEntryType = self.entryType
            self.entryTypeTF.text = self.theEntryType
        }
    }
    private var theFireStation: String = ""
    var fireStation: String = "" {
        didSet {
            self.theFireStation = self.fireStation
            self.fireStationTF.text = self.theFireStation
        }
    }
    private var thePlatoon: String = ""
    private var thePlatoonColor: UIColor!
    var platoon: String = "" {
        didSet {
            self.thePlatoon = self.platoon
            self.platoonTF.text = self.thePlatoon
            if platoon == "A Platoon" {
                thePlatoonColor = UIColor(named: "FJIconRed")
            } else if platoon == "B Platoon" {
                thePlatoonColor = UIColor(named: "FJBlue")
            } else if platoon == "C Platoon" {
                thePlatoonColor = UIColor(named: "FJGreen")
            } else if platoon == "D Platoon" {
                thePlatoonColor = UIColor(named: "FJGold")
            }
        }
    }
    
    private var theAssignment: String = ""
    var assignment: String = "" {
        didSet {
            self.theAssignment = self.assignment
            self.assignmentTF.text = self.theAssignment
        }
    }
    
    private var theApparatus: String = ""
    var apparatus: String = "" {
        didSet {
            self.theApparatus = self.apparatus
            self.apparatusTF.text = self.theApparatus
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.platoonTF.textColor = thePlatoonColor
        self.platoonTF.font = .systemFont(ofSize: 22, weight: UIFont.Weight(rawValue: 300))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func infoBTapped(_ sender: Any) {
        delegate?.theInfoBTapped()
    }
    
}
