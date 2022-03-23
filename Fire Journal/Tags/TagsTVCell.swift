//
//  TagsTVCell.swift
//  StationCommand
//
//  Created by DuRand Jones on 11/23/21.
//

import UIKit
import CoreData
import CloudKit

class TagsTVCell: UITableViewCell {
    
    var objectID: NSManagedObjectID!
    
    var tagName: String = "" {
        didSet {
            self.tagL.text = self.tagName
        }
    }

    let tagL = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        accessoryType = selected ? .checkmark : .none
    }

}

extension TagsTVCell {
    
    func configure(objectID: NSManagedObjectID, tag: String) {
        
        self.objectID = objectID
        self.tagName = tag
        
        tagL.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagL)
        
        tagL.textAlignment = .left
        tagL.font = UIFont.preferredFont(forTextStyle: .caption2)
        tagL.textColor = .label
        tagL.adjustsFontForContentSizeCategory = false
        tagL.lineBreakMode = NSLineBreakMode.byWordWrapping
        tagL.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            tagL.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 34),
            tagL.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tagL.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -34),
            tagL.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagL.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        
    }
    
    
}
