//
//  ARC_CampaignResidenceTypeCell.swift
//  FJ ARC Plus
//
//  Created by DuRand Jones on 9/15/20.
//  Copyright © 2020 com.purecommand.FireJournal. All rights reserved.
//

import UIKit

class ARC_CampaignResidenceTypeCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var subjectL: UILabel!
    @IBOutlet weak var descriptionL: UILabel!
    
//    MARK: -PROPERTIES-
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
        }
    }
    
    
    var entityType: EntityType = .residence
    var theEntityType: EntityType? {
        didSet {
            self.entityType = self.theEntityType ?? .residence
        }
    }
    
    
    private var subject: String = ""
    var theSubject: String? {
        didSet {
            self.subject = theSubject ?? ""
            self.subjectL.text = self.subject
        }
    }
    
    private var theDescription: String = ""
    var descriptionText: String? {
        didSet {
            self.theDescription = self.descriptionText ?? ""
            self.descriptionL.text = self.theDescription
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
