//
//  DemoService.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit
import AFNetworking

class DemoService: NSObject,CTServiceProtocol {
    
    var apiEnvironment: CTServiceAPIEnvironment
    
    func request(params: Dictionary<String, Any>, methodName: String, requestType: CTAPIManagerRequestType) -> NSURLRequest? {
        if requestType == .CTAPIManagerRequestTypeGet {
            let urlstring = self.baseUrl! + methodName
            let tsString = NSUUID().uuidString
            let md5Hash = (tsString + self.privateKey! + self.publicKey!).md5
            let request = self.httpRequestSerializer.request(withMethod: "GET", urlString: urlstring, parameters: ["apikey":self.publicKey,"ts":tsString,"hash":md5Hash], error: nil)
            return request
        }
        return nil
    }
    
    func result(responseData: Data, response: URLResponse, request: URLRequest) {
        
    }
    
    required override init() {
        self.apiEnvironment = .CTServiceAPIEnvironmentDevelop
        super.init()
    }
    
    var baseUrl:String? {
        switch self.apiEnvironment {
        case .CTServiceAPIEnvironmentDevelop:
            return "https://gateway.marvel.com:443/v1"
        case .CTServiceAPIEnvironmentRelease:
            return "https://gateway.marvel.com:443/v1"
        case .CTServiceAPIEnvironmentReleaseCandidate:
            return "https://gateway.marvel.com:443/v1"
        }
    }
    
    var privateKey:String? {
        return "31bb736a11cbc10271517816540e626c4ff2279a"
    }
    
    var publicKey:String? {
        return "d97bab99fa506c7cdf209261ffd06652"
    }
    
    lazy var httpRequestSerializer:AFHTTPRequestSerializer = {
        let serializer = AFHTTPRequestSerializer()
        serializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return serializer
    }()
}
