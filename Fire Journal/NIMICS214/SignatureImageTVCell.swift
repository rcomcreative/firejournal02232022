//
//  SignatureImageTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/19/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

class SignatureImageTVCell: UITableViewCell {
    
    let signatureImageIV = UIImageView()
    
    private var theImageName: UIImage!
    var imageName: UIImage! {
        didSet {
            self.theImageName = self.imageName
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
            // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
            // Configure the view for the selected state
    }

}

extension SignatureImageTVCell {
    
    func configure(_ imageName: UIImage ) {
        
            self.imageName = imageName
            self.signatureImageIV.image = theImageName
            self.signatureImageIV.contentMode = .scaleAspectFit
        
        
        configureImageView()
        
    }
    
    func configureImageView() {
        
        signatureImageIV.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(signatureImageIV)
        
        NSLayoutConstraint.activate([
            
            self.signatureImageIV.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            self.signatureImageIV.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            self.signatureImageIV.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            self.signatureImageIV.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15),
            
            ])
        
    }
    
}


