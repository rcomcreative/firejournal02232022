//
//  CrewModalCell.swift
//  dashboard
//
//  Created by DuRand Jones on 10/26/18.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import UIKit

class CrewModalCell: UITableViewCell {
    @IBOutlet weak var Subject1L: UILabel!
    @IBOutlet weak var subject2L: UILabel!
    
    var crew: UserCrews? {
        didSet {
            self.Subject1L.text = crew?.crewName
            self.subject2L.text = crew?.crew
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // update UI
        accessoryType = selected ? .checkmark : .none
    }
    
}
