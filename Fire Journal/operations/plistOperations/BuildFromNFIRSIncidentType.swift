//
//  BuildFromNFIRSIncidentType.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//




import Foundation
import UIKit

class BuildFromNFIRSIncidentType {

    struct NFIRSIncidentType: Hashable {
        
        let displayOrder: Int
        let incidentTypeName: String
        let incidentTypeNumber: String
        let identifier = UUID()
        
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: NFIRSIncidentType, rhs: NFIRSIncidentType) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    
    }
    
    class NFIRSIncidentTypes: Hashable {
        
        var nfirsIncidentTypes: BuildFromNFIRSIncidentType.NFIRSIncidentType?
        let identifier = UUID()
        
        init(nfirsIncidentTypes: BuildFromNFIRSIncidentType.NFIRSIncidentType) {
            self.nfirsIncidentTypes = nfirsIncidentTypes
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: NFIRSIncidentTypes, rhs: NFIRSIncidentTypes) -> Bool {
            return lhs.identifier == rhs.identifier
        }
        
    }
    
    
    var nfirsIncidentTypes = [BuildFromNFIRSIncidentType.NFIRSIncidentTypes]()
    var nfirsStreetTypesString = [String]()
    var nfirsStreetTypeNumber = [String]()
    var displayOrder = [Int]()
    
    init() {
        nfirsIncidentTypes = configure()
    }

}

extension BuildFromNFIRSIncidentType {
    
    func configure() ->[NFIRSIncidentTypes] {
        var nitypes = [NFIRSIncidentTypes]()
        guard let path = Bundle.main.path(forResource: "NFIRSIncidentType", ofType: "plist" ) else { return  nitypes }
        let dict = NSDictionary(contentsOfFile:path)
        
        nfirsStreetTypesString = dict?["incidentTypeName"] as! Array<String>
        nfirsStreetTypeNumber = dict?["incidentTypeNumber"] as! Array<String>
        displayOrder = dict?["displayOrder"] as! Array<Int>
        
        for (index, value) in displayOrder.enumerated() {
            let type = nfirsStreetTypesString[index]
            let number = nfirsStreetTypeNumber[index]
            let display: Int = value
            let incidentType = NFIRSIncidentType(displayOrder: display, incidentTypeName: type, incidentTypeNumber: number)
            let types = NFIRSIncidentTypes(nfirsIncidentTypes: incidentType)
            nitypes.append(types)
        }
        return nitypes
    }
}
