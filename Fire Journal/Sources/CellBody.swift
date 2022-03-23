//
//  CellBody.swift
//  Fire Journal
//
//  Created by DuRand Jones on 3/18/20.
//  Copyright © 2020 PureCommand, LLC. All rights reserved.
//

import Foundation

struct CellBody {
    var cellAttributes = [ String : Sections ]()
    var type = [ String : CellType ]()
    var fType = [ String : String ]()
    var dType = [ String : Date ]()
    var bType = [ String : Bool ]()
    var objID = [ String : Any? ]()
}


extension CellBody: Equatable {}
func ==(lhs: CellBody, rhs: CellBody) -> Bool {
    return lhs.cellAttributes == rhs.cellAttributes && lhs.type == rhs.type
}
