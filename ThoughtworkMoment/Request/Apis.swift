//
//  Apis.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation


public class TweetsApi: Requestable, ResonseValidator {
    
    private let userName: String
    
    var currentPage: Int = 0
    
    var isFirstPage: Bool {
        return currentPage == 0
    }
    
    public init(userName: String) {
        self.userName = userName
    }
    
    public var cancelToken: Cancellable?
    
    public var path: String {
        return "user/<user>/tweets"
    }
    
    public var method: RequestMethod {
        return .get
    }
    
    public var params: [String : AnyHashable]? {
        return ["user": userName, "currentPage": currentPage]
    }
    
    public func mapResponse(data: Data?) throws -> JsonType {
        guard let `data` = data else {
            throw errorProcessing
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            throw errorProcessing
        }
        
        if let array = json as? [JsonType] {
            return ["list": array.filter { !$0.keys.contains("error") }]
        }
        
        throw errorProcessing
    }
    
}

public class UserInfoApi: Requestable, ResonseValidator {
    
    private let userName: String
    
    public init(userName: String) {
        self.userName = userName
    }
    
    public var cancelToken: Cancellable?
    
    public var path: String {
        return "user/<user>"
    }
    
    public var method: RequestMethod {
        return .get
    }
    
    public var params: [String : AnyHashable]? {
        return ["user": userName]
    }
}
