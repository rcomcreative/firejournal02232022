//
//  ARC_SignatureCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 6/25/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ARC_SignatureCellDelegate: AnyObject {
    func theSignatureBTapped(path: IndexPath, tag: Int)
}

class ARC_SignatureCell: UITableViewCell {

//    MARK: -OBJECTS-
    @IBOutlet weak var signatureB: UIButton!
    @IBOutlet weak var signatureIV: UIImageView!
    
//    MARK: -PROPERTIES-
    weak var delegate: ARC_SignatureCellDelegate? = nil
    
    private var signatureImage = UIImage()
    var sImage: UIImage? {
        didSet {
            self.signatureImage = self.sImage ?? UIImage()
            self.signatureIV.image = self.signatureImage
        }
    }
    
    private var signature: Bool = false
    var theSignature: Bool? {
        didSet {
            self.signature = theSignature ?? false
        }
    }
    
    private var indexPath = IndexPath(item: 0, section: 0)
    var path: IndexPath? {
        didSet {
            self.indexPath = self.path ?? IndexPath(item: 0, section: 0)
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
        delegate?.theSignatureBTapped(path: indexPath, tag: self.tag )
    }
    
    
}
