//
//  Configurations.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation
import CleanJSON

public let errorProcessing: MomentException = MomentException(message: "数据解析失败鸭")
public let defaultError: String = "未知错误了鸭"

public typealias JsonType = [String: AnyHashable]

public typealias JsonResult = (Result<JsonType, MomentException>) -> Void
public typealias ModelResult<T: MomentCodable> = (Result<T, MomentException>) -> Void

public class EnviromentBuilder {
    public static let shared = EnviromentBuilder()
    var env: NeverChanged = DemoConfig()
    
    public func setup(newEnv: NeverChanged) {
        env = newEnv
    }
}

public class MomentException: Error {
    
    let code: String
    let msg: String
    
    init(errorCode: String, message: String) {
        code = errorCode
        msg = message
    }
    
    convenience init(message: String) {
        self.init(errorCode: "-99", message: message)
    }
    
    convenience init() {
        self.init(errorCode: "-99", message: defaultError)
    }
}

public enum RequestMethod: String {
    case post = "POST"
    case get = "GET"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public struct Endpoint {
    var params: JsonType?
    var url: String
    
    init(params: JsonType?, url: String) {
        self.params = params
        self.url = url
    }
}

public protocol NeverChanged {
    var host: String { get set }
    var customHeader: [String: String] { get set }
    var port: String { get set }
    var timeout: Double { get set }
}

public protocol Requestable {
    var neverChangedPackage: NeverChanged { get }
    var additionHeader: [String: String] { get }
    var validator: ResonseValidator { get }
    var cancelToken: Cancellable? { get set }
   
    var path: String { get }
    var method: RequestMethod { get }
    var params: JsonType? { get }
    
    func beforeSending(endpoint: Endpoint) throws -> Endpoint
    func beforeReceving(response: JsonType) throws -> JsonType
}

public protocol ResonseValidator {
    func mapResponse(data: Data?) throws -> JsonType
    func validateResponse(json: JsonType) throws -> JsonType
}

public extension ResonseValidator {
    
    func mapResponse(data: Data?) throws -> JsonType {
        guard let `data` = data else {
            throw errorProcessing
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
            throw errorProcessing
        }
        
        if let dic = json as? JsonType {
            return dic
        }
        
        if let array = json as? [JsonType] {
            return ["list": array]
        }
        
        throw errorProcessing
    }
    
    func validateResponse(json: JsonType) throws -> JsonType {
        return json
    }

}

public extension Requestable {

    func beforeSending(endpoint: Endpoint) throws -> Endpoint {
        return endpoint
    }
    
    func beforeReceving(response: JsonType) throws -> JsonType {
        return response
    }
    
    var finalHeader: [String: String] {
        let dic = additionHeader.merging(neverChangedPackage.customHeader, uniquingKeysWith: { $1 })
        return dic
    }
    
    var finalPath: String {
        guard let `params` = params else {
            return path
        }
        
        return params.reduce(path) {
            $0.replacingOccurrences(of: "<\($1.key)>", with: "\($1.value)")
        }
    }
    
    mutating func setupCancel(token: Cancellable) {
        cancelToken = token
    }
}

public extension Requestable where Self: ResonseValidator {
    mutating func fire(result: @escaping JsonResult) {
        Firer().fireJson(request: &self, callback: result)
    }
    
    mutating func fire<T: MomentCodable>(result: @escaping ModelResult<T>) {
        Firer().fire(request: &self, callback: result)
    }
}

public protocol Cancellable {
    func cancel()
}

extension URLSessionDataTask: Cancellable {
    
}

public protocol MomentCodable: Codable {
    static var jsonDecoder: JSONDecoder { get }
}

private let decoder = CleanJSONDecoder()

public extension MomentCodable {
    static var jsonDecoder: JSONDecoder {
        return decoder
    }
}
