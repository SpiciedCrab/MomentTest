//
//  DemoRequestConfig.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

struct DemoConfig: NeverChanged {
    var host: String  = "https://thoughtworks-mobile-2018.herokuapp.com"
    
    var customHeader: [String : String] = [:]
    
    var port: String = ""
    
    var timeout: Double = 30
}

extension Requestable {
    public var neverChangedPackage: NeverChanged {
        return EnviromentBuilder.shared.env
    }
    
    public var additionHeader: [String : String] {
        return [:]
    }
    
    public var validator: ResonseValidator {
        return MomentRespValidator()
    }
}

public struct MomentRespValidator: ResonseValidator {
    
}
