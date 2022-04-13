//
//  BuildFromLocalIncidentType.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation

class BuildFromLocalIncidentType {
    
    struct LocalIncident: Hashable {
        
        let displayOrder: Int
        let localIncident: String
        let identifier = UUID()
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: LocalIncident, rhs: LocalIncident) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    struct LocalIncidents: Hashable {
        
        let localIncident: BuildFromLocalIncidentType.LocalIncident?
        let identifier = UUID()
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: LocalIncidents, rhs: LocalIncidents) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
    }
    
    var localIncidents = [LocalIncidents]()
    var displayOrder = [Int]()
    var localIncident = [String]()
    
    init() {
        self.localIncidents = configure()
    }
}

extension BuildFromLocalIncidentType {
    
    func configure() -> [LocalIncidents] {
        var local = [LocalIncidents]()
        guard let path = Bundle.main.path(forResource: "LocalIncidents", ofType: "plist" ) else { return  local }
        let dict = NSDictionary(contentsOfFile:path)
        displayOrder = dict?["displayOrder"] as! Array<Int>
        localIncident = dict?["localIncidents"] as! Array<String>
        for (index, value) in displayOrder.enumerated() {
            let display: Int = value
            let localIn: String = localIncident[index]
            let localIncident = LocalIncident.init(displayOrder: display, localIncident: localIn)
            let localIncidents = LocalIncidents.init(localIncident: localIncident)
            local.append(localIncidents)
        }
        return local
    }
    
}
