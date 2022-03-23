//
//  NFIRSSignatureCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/27/19.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NFIRSSignatureCellDelegate: AnyObject {
    func signatureBTapped(type: IncidentTypes)
}

class NFIRSSignatureCell: UITableViewCell {

    @IBOutlet weak var signatureL: UILabel!
    @IBOutlet weak var signatureIV: UIImageView!
    @IBOutlet weak var signatureB: UIButton!
    var type:IncidentTypes!
    
    weak var delegate:NFIRSSignatureCellDelegate? = nil
    
    @IBAction func signatureBTapped(_ sender: UIButton) {
        delegate?.signatureBTapped(type: type)
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
