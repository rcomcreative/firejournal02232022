//
//  BuildFromFDID.swift
//  Fire Journal
//
//  Created by DuRand Jones on 4/11/22.
//  Copyright © 2022 PureCommand, LLC. All rights reserved.
//

import Foundation

class BuildFromFDIDPlist {
    
    struct FDID: Hashable {
        
        let fdid: String
        let department: String
        let state: String
        let city: String
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: FDID, rhs: FDID) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    struct FDIDs: Hashable {
        
        let fdid: BuildFromFDIDPlist.FDID
        let identifier = UUID()
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
        
        static func == (lhs: FDIDs, rhs: FDIDs) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }
    
    var fdids = [FDIDs]()
    
    var fdid = [String]()
    var states = [String]()
    var city = [String]()
    var department = [String]()
    
    init() {
        fdids = configure()
    }
    
}

extension BuildFromFDIDPlist {
    
    func configure() -> [FDIDs] {
        var fdids = [FDIDs]()
        guard let path = Bundle.main.path(forResource: "FDID", ofType: "plist" ) else { return  fdids }
        guard let dict = NSDictionary(contentsOfFile:path) else { return fdids}
        fdid = dict["FDID"] as! Array<String>
        states = dict["HQState"] as! Array<String>
        city = dict["HQCity"] as! Array<String>
        department = dict["FireDepartmentName"] as! Array<String>
        for (index, _ ) in fdid.enumerated() {
            let aFDID = fdid[index]
            let aState = states[index]
            let aCity = city[index]
            let aDepartment = department[index]
            let theFDID = FDID.init(fdid: aFDID, department: aDepartment, state: aState, city: aCity)
            let oneFDID = FDIDs.init(fdid: theFDID)
            fdids.append(oneFDID)
        }
        return fdids
    }
    
}
