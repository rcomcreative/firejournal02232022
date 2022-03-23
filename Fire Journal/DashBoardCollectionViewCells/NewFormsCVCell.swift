//
//  NewFormsCVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 11/5/19.
//  Copyright © 2019 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewFormsCVCellDelegate: AnyObject {
    func newJournalTapped()
    func newIncidentTapped()
    func newFormTapped()
}

class NewFormsCVCell: UICollectionViewCell {
    
//    MARK: -Objects-
    @IBOutlet weak var journalGradientIV: UIImageView!
    @IBOutlet weak var journalIconIV: UIImageView!
    @IBOutlet weak var journalSubjectL: UILabel!
    @IBOutlet weak var newJournalB: UIButton!
    @IBOutlet weak var incidentGradientIV: UIImageView!
    @IBOutlet weak var incidentIconIV: UIImageView!
    @IBOutlet weak var incidentSubjectL: UILabel!
    @IBOutlet weak var newIncidentB: UIButton!
    @IBOutlet weak var formsGraidentIV: UIImageView!
    @IBOutlet weak var formsIconIV: UIImageView!
    @IBOutlet weak var formsSubjectL: UILabel!
    @IBOutlet weak var newFormB: UIButton!
    
    weak var delegate: NewFormsCVCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
       roundViews()
        }
        
        func roundViews() {
            self.contentView.layer.cornerRadius = 6
            self.contentView.clipsToBounds = true
            self.contentView.layer.borderColor = UIColor.systemRed.cgColor
            self.contentView.layer.borderWidth = 2
        }
    
    //    MARK: -BUTTON ACTIONS-
    @IBAction func newJournaBTapped(_ sender: UIButton) {
        delegate?.newJournalTapped()
    }
    @IBAction func newIncidentBTapped(_ sender: UIButton) {
        delegate?.newIncidentTapped()
    }
    @IBAction func newFormBTapped(_ sender: UIButton) {
        delegate?.newFormTapped()
    }
    

}
