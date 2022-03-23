//
//  StringExtension.swift
//  DashboardTest
//
//  Created by DuRand Jones on 2/6/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

extension String {
    
    var isDigits: Bool {
        guard !self.isEmpty else { return false }
        return !self.contains { Int(String($0)) == nil }
    }
    
    public var hasWhiteSpace: Bool {
        return self.contains(" ")
    }
    
    
    public var hasPeriod: Bool {
        return self.contains(".")
    }
    
}
