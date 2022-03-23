//
//  BuiltFromTagsPlist.swift
//  StationCommand
//
//  Created by DuRand Jones on 4/9/21.
//

import Foundation

class BuiltFromTagsPlist {
    
    struct Tag: Hashable {
        let tag: String
        let displayOrder: Int
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Tag, rhs: Tag) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
    }
    
    struct Tags: Hashable {
        
        let tag: BuiltFromTagsPlist.Tag
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: Tags, rhs: Tags) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    var tags = [Tags]()
    
    var displayOrder = [Int]()
    var journalTags = [String]()
    
    init() {
        tags = configure()
    }
}

extension BuiltFromTagsPlist {
    
    func configure() -> [Tags] {
        var tags = [Tags]()
        guard let path = Bundle.main.path(forResource: "Tags", ofType: "plist" ) else { return  tags }
        guard let dict = NSDictionary(contentsOfFile:path) else { return tags}
        displayOrder = dict["displayOrder"] as! Array<Int>
        journalTags = dict["journalTag"] as! Array<String>
        for (index, value) in displayOrder.enumerated() {
            let display: Int = value
            let tag = journalTags[index]
            let theTag = Tag.init(tag: tag, displayOrder: display)
            let theTags = Tags.init(tag: theTag)
            tags.append(theTags)
        }
        return tags
    }
}

