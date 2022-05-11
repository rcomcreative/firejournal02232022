//
//  CameraTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol CameraTVCellDelegate: AnyObject {
    func galleryChosen(tag: Int)
    func cameraChosen(tag: Int)
}

class CameraTVCell: UITableViewCell {
    
    let cameraB = UIButton(primaryAction: nil)
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    var type: IncidentTypes? = nil
    
    weak var delegate: CameraTVCellDelegate? = nil
    
    private var theBackgroundColor: String = "FJBlue"
    var aBackgroundColor: String = "" {
        didSet {
            self.theBackgroundColor = self.aBackgroundColor
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
    }

}

extension CameraTVCell {
    
    func configureTheButton() {
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            switch type {
            case .journal:
                config.image = UIImage(systemName: "camera.circle")
                config.title = " Add Photo"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .allIncidents:
                config.image = UIImage(systemName: "camera.circle")
                config.title = " Add Photo"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            case .theProject:
                config.image = UIImage(systemName: "camera.circle")
                config.title = " Add Photo"
                config.baseBackgroundColor = UIColor(named: theBackgroundColor)
            default: break
            }
            config.baseForegroundColor = .white
            cameraB.configuration = config
            
            let theClosure = {(action: UIAction) in
                self.signalTheButtonMenuChange(action.title)
            }
            
            self.cameraB.menu = UIMenu(children: [
                UIAction(title: "Gallery", handler: theClosure),
                UIAction(title: "Camera", handler: theClosure)
            ])
            
            self.cameraB.showsMenuAsPrimaryAction = true
            
            cameraB.translatesAutoresizingMaskIntoConstraints = false
            

            self.contentView.addSubview(cameraB)
            
            NSLayoutConstraint.activate([
                cameraB.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
                cameraB.widthAnchor.constraint(equalToConstant: 335),
                cameraB.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 26),
                cameraB.heightAnchor.constraint(equalToConstant: 45),
            ])
        }
    }
    
    func signalTheButtonMenuChange(_ title: String) {
        if title == "Gallery" {
            delegate?.galleryChosen(tag: self.tag)
        } else if title == "Camera" {
            delegate?.cameraChosen(tag: self.tag)
        }
    }
    
}
