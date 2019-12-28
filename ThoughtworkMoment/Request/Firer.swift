//
//  Firer.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

public class Firer {
    public init(){
        
    }
    
    public func fire<T: Requestable & ResonseValidator,
        U: MomentCodable>(request: inout T,
                         callback: @escaping ModelResult<U>) {
        fireJson(request: &request) { (result) in
            switch(result) {
            case .success(let json):
                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
                    let model = try U.jsonDecoder.decode(U.self, from: data)
                    callback(Result.success(model))
                } catch let error {
                    guard let MomentError = error as? MomentException else {
                        callback(Result.failure(MomentException()))
                        return
                    }
                    callback(Result.failure(MomentError))
                    return
                }
                break
            case .failure(let error):
                callback(Result.failure(error))
            }
        }
    }
    
    public func fireJson<T: Requestable & ResonseValidator>(request: inout T,
                                                            callback: @escaping JsonResult) {
        let tempRequest = request
        fireData(request: &request) { (result: Result<Data, MomentException>) in
            switch(result) {
            case .success(let data):
                var json: JsonType = [:]
                do {
                    let resp = try tempRequest.mapResponse(data: data)
                    let tempjson = try tempRequest.validateResponse(json: resp)
                    json = try tempRequest.beforeReceving(response: tempjson)
                } catch let error {
                    guard let MomentError = error as? MomentException else {
                        callback(Result.failure(MomentException()))
                        return
                    }
                    callback(Result.failure(MomentError))
                    return
                }
                
                callback(Result.success(json))
                break
            case .failure(let error):
                callback(Result.failure(error))
            }
        }
    }
    
    private func fireData<T: Requestable & ResonseValidator>(request: inout T,
                                                 callback: @escaping (Result<Data, MomentException>) -> Void) {
        
        var endpoint = Endpoint(params: request.params, url: request.finalPath)
        do {
            endpoint = try request.beforeSending(endpoint: endpoint)
        } catch let error {
            guard let err = error as? MomentException else {
                callback(Result.failure(MomentException()))
                return
            }
            callback(Result.failure(err))
            return
        }
        
        var wholeUrl = "\(request.neverChangedPackage.host)/\(request.finalPath)"
        
        let param = endpoint.params ?? [:]
        
        if request.method == .get {
            let mapped = param.map { "\($0)=\($1)" }
            let pattern = mapped.joined(separator: "&")
            wholeUrl = "\(wholeUrl)?\(pattern)"
        }

        guard let url = URL(string: wholeUrl) else {
            return
        }
        
        var finalRequest = URLRequest(url: url)
        
        request.finalHeader
            .forEach {
                finalRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if request.method != .get {
            let data = try? JSONSerialization.data(withJSONObject: param, options: .fragmentsAllowed)
            finalRequest.httpBody = data
        }
        
        finalRequest.httpMethod = request.method.rawValue
        
        let sessionConfigure = URLSessionConfiguration.default
        sessionConfigure.httpAdditionalHeaders = finalRequest.allHTTPHeaderFields
        sessionConfigure.timeoutIntervalForRequest = 30
        sessionConfigure.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: sessionConfigure)

        let task = session.dataTask(with: finalRequest) { (data, _, error) in
            if let err = error {
                callback(Result.failure(MomentException(message: "\(err)")))
                return
            }
            
            guard let `data` = data else {
                callback(Result.failure(MomentException()))
                return
            }
            callback(Result.success(data))
        }
        
        request.setupCancel(token: task)
        
        task.resume()
    }
}
