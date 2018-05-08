//
//  DemoService.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class DemoService: NSObject,CTServiceProtocol {
    
    var apiEnvironment: CTServiceAPIEnvironment
    
    func request(params: Dictionary<String, Any>, methodName: String, requestType: CTAPIManagerRequestType) {
        
    }
    
    func result(responseData: Data, response: URLResponse, request: URLRequest) {
        
    }
    
    required override init() {
        self.apiEnvironment = .CTServiceAPIEnvironmentDevelop
        super.init()
    }
}
