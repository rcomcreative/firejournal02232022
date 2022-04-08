//
//  InteractiveCollectionView.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/1/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation
import UIKit

final class InteractiveCollectionView: UICollectionView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return super.hitTest(point, with: event) as? InteractiveCollectionView
    }
}
