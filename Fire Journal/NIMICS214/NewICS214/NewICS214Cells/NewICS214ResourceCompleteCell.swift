//
//  NewICS214ResourceCompleteCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class NewICS214ResourceCompleteCell: UITableViewCell {
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var icsPositionL: UILabel!
    @IBOutlet weak var homeAgencyL: UILabel!
    
    private var theCrew = UserAttendees()
    var crew: UserAttendees? {
        didSet {
            self.theCrew = self.crew ?? UserAttendees()
            self.nameL.text = self.theCrew.attendee
            self.icsPositionL.text = self.theCrew.attendeeICSPosition
            self.homeAgencyL.text = self.theCrew.attendeeHomeAgency
        }
    }
    
    private var arrayPosition: Int = 0
    var position: Int? {
        didSet {
            self.arrayPosition = self.position ?? 0
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
