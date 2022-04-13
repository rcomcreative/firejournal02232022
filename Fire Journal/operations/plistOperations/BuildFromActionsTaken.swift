//
//  BuildFromActionsTaken.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation

class BuildFromActionsTaken {
    
    struct ActionTaken: Hashable {
        
        let displayOrder: Int
        let actionTaken: String
        let identifier = UUID()
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: ActionTaken, rhs: ActionTaken) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
    }
    
    struct ActionsTaken: Hashable {
        let actionTaken: BuildFromActionsTaken.ActionTaken?
        let identifier = UUID()
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: ActionsTaken, rhs: ActionsTaken) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    var actionsTaken = [ActionsTaken]()
    var displayOrder = [Int]()
    var actionTaken = [String]()
    
    init() {
        self.actionsTaken = configure()
    }
    
}

extension BuildFromActionsTaken {
    
    func configure() -> [ActionsTaken] {
        var actionsTaken = [ActionsTaken]()
        guard let path = Bundle.main.path(forResource: "ActionsTaken", ofType: "plist" ) else { return  actionsTaken }
        let dict = NSDictionary(contentsOfFile:path)
        displayOrder = dict?["DisplayOrder"] as! Array<Int>
        actionTaken = dict?["ActionsTaken"] as! Array<String>
        for (index, value) in displayOrder.enumerated() {
            let display: Int = value
            let actionTake: String = actionTaken[index]
            let action = ActionTaken.init(displayOrder: display, actionTaken: actionTake)
            let theActionTaken = ActionsTaken.init(actionTaken: action)
            actionsTaken.append(theActionTaken)
        }
        return actionsTaken
    }
}
