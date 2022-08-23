//
//  ICS214TextViewTVCell.swift
//  Fire Journal
//
//  Created by DuRand Jones on 8/16/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import UIKit

protocol ICS214TextViewTVCellDelegate: AnyObject {
    func theTextViewTextHasChanged(_ theText: String, index: IndexPath)
}

class ICS214TextViewTVCell: UITableViewCell {
    
    let theTextView = UITextView()
    
    weak var delegate: ICS214TextViewTVCellDelegate? = nil
    
    var index: IndexPath!
    
    private var theLog: String = ""
    var log: String = "" {
        didSet {
            self.theLog = self.log
            self.theTextView.text = self.theLog
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

extension ICS214TextViewTVCell {
    
    func configure() {
        
        theTextView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(theTextView)
        
        theTextView.textAlignment = .left
        theTextView.font = UIFont.preferredFont(forTextStyle: .caption1)
        theTextView.textColor = .label
        theTextView.adjustsFontForContentSizeCategory = true
        theTextView.layer.borderColor = UIColor(named: "FJDarkBlue" )?.cgColor
        theTextView.layer.borderWidth = 1
        theTextView.layer.cornerRadius = 8
        theTextView.isUserInteractionEnabled = true
        theTextView.delegate = self
        theTextView.isScrollEnabled = true
        
        NSLayoutConstraint.activate([
            
            theTextView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            theTextView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15),
            theTextView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 15),
            theTextView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -15),
            
            ])
    }
    
}

extension ICS214TextViewTVCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text {
            delegate?.theTextViewTextHasChanged(text, index: index)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let text = textView.text {
            delegate?.theTextViewTextHasChanged(text, index: index)
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
            if let text = textView.text {
                delegate?.theTextViewTextHasChanged(text, index: index)
            }
    }
    
}
