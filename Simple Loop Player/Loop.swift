//
//  Loop.swift
//  Simple Loop Player
//
//  Created by Peter Zeman on 24.2.17.
//  Copyright © 2017 Procus s.r.o. All rights reserved.
//

import Foundation

class Loop: NSObject{
    var start: Float64!
    var end: Float64!
    
    init(start: Float64, end: Float64){
        self.start = start
        self.end = end
    }
}
