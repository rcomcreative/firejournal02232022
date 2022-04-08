    //
    //  PhotoCCell.swift
    //  Fire Journal
    //
    //  Created by DuRand Jones on 4/1/22.
    //  Copyright © 2022 PureCommand, LLC. All rights reserved.
    //

import UIKit
import Foundation
import CoreData

class PhotoCCell: UICollectionViewCell {
    
    let iconIV = UIImageView()
    let backgroundGView = UIView()
    
    
    var thePhoto: Photo!
    var objectID: NSManagedObjectID!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}

extension PhotoCCell {
    
    func configure(thePhotos: Photo ) {
        self.thePhoto = thePhotos
        self.objectID = self.thePhoto.objectID
        
        if let theGuid = self.thePhoto.guid {
            let imageName = self.thePhoto.getThumbnail(guid: theGuid)
            iconIV.image = imageName
        }
        
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        backgroundGView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundGView.addSubview(iconIV)
        contentView.addSubview(backgroundGView)
        
        NSLayoutConstraint.activate([
            backgroundGView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundGView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundGView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundGView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconIV.topAnchor.constraint(equalTo: backgroundGView.topAnchor, constant: 5),
            iconIV.centerXAnchor.constraint(equalTo: backgroundGView.centerXAnchor),
            iconIV.widthAnchor.constraint(equalToConstant: 66),
            iconIV.heightAnchor.constraint(equalToConstant: 66),
            
        ])
        
        
        
    }
    
}
