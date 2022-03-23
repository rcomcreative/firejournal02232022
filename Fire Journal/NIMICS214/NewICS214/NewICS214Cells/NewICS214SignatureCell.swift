//
//  NewICS214SignatureCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol NewICS214SignatureCellDelegate: AnyObject {
    func theSignatureBTapped()
}

class NewICS214SignatureCell: UITableViewCell {

    @IBOutlet weak var signatureB: UIButton!
    @IBOutlet weak var signatureIV: UIImageView!
    weak var delegate: NewICS214SignatureCellDelegate? = nil
    
    private var signatureImage = UIImage()
    var sImage: UIImage? {
        didSet {
            self.signatureImage = self.sImage ?? UIImage()
            self.signatureIV.image = self.signatureImage
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        signatureB.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        delegate?.theSignatureBTapped()
    }
    
    
}
