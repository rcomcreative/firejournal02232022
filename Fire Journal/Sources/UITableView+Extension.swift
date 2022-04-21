//
//  UITableView+Extension.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/20/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}
