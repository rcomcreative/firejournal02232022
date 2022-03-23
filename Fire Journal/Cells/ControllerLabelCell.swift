//
//  ControllerLabelCell.swift
//  dashboard
//
//  Created by DuRand Jones on 9/7/18.
//  Copyright © 2018 PureCommand LLC. All rights reserved.
//

import UIKit

protocol ControllerLabelCellDelegate: AnyObject {
    func incidentInfoBTapped()
}

class ControllerLabelCell: UITableViewCell {
    
    @IBOutlet weak var controllerL: UILabel!
    @IBOutlet weak var dateL: UILabel!
    @IBOutlet weak var addressL: UILabel!
    @IBOutlet weak var typeIV: UIImageView!
    @IBOutlet weak var incidentEditB: UIButton!
    
    weak var delegate: ControllerLabelCellDelegate? = nil
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func incidentInfoBTapped(_ sender: Any) {
        delegate?.incidentInfoBTapped()
    }
    
}
