//
//  ICS214ButtonTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ICS214ButtonTVCellDelegate: AnyObject {
    func theButtonTapped(index: IndexPath)
}

class ICS214ButtonTVCell: UITableViewCell {
    
    private var theImageName: String = ""
    var imageName: String = "" {
        didSet {
            self.theImageName = self.imageName
        }
    }
    
    private var theButtonTitle: String = ""
    var buttonTitle: String = "" {
        didSet {
            self.theButtonTitle = self.buttonTitle
        }
    }
    
    var index: IndexPath!
    
    weak var delegate: ICS214ButtonTVCellDelegate? = nil
    
    var theButton = UIButton(primaryAction: nil)
    
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

extension ICS214ButtonTVCell {
    
    func configure(index: IndexPath) {
        
        self.index = index
        self.tag = index.row
        
        theButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(theButton)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.buttonSize = .medium
            config.image = UIImage(systemName: theImageName)
            config.title = theButtonTitle
            config.baseBackgroundColor = UIColor(named: "FJIconRed")
            config.baseForegroundColor = .white
            theButton.configuration = config
            theButton.addTarget(self, action: #selector(theButtonTapped(_:)), for: .touchUpInside)
        }
        
        NSLayoutConstraint.activate([
            
            theButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            theButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            theButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 3),
            theButton.heightAnchor.constraint(equalToConstant: 45),
            
            ])
        
    }
    
    @objc func theButtonTapped(_ sender: UIButton) {
        delegate?.theButtonTapped(index: index)
    }
    
    
}
