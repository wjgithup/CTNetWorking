//
//  DemoAPIManager.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/14.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class DemoAPIManager: CTAPIBaseManager,CTAPIManager,CTAPIManagerValidator,CTAPIManagerParamSource {
    
    override init() {
        super.init()
        self.paramSource = self
        self.validator = self
        self.cachePolicy = .CTAPIManagerCachePolicyDisk
    }
    
    func methodName() -> String {
        return "public/characters"
    }
    
    func serviceIdentifier() -> String {
        return "DemoService"
    }
    
    func requestType() -> CTAPIManagerRequestType {
        return .CTAPIManagerRequestTypeGet
    }
    
    func isBackDataCorrect(manager: CTAPIBaseManager, callBackData: Dictionary<String, Any>?) -> CTAPIManagerErrorType {
        return .CTAPIManagerErrorTypeNoError
    }
    
    func isParamsDataCorrect(manager: CTAPIBaseManager, params: Dictionary<String, Any>?) -> CTAPIManagerErrorType {
        return .CTAPIManagerErrorTypeNoError
    }
    
    func params(manager: CTAPIBaseManager) -> Dictionary<String, Any>? {
        return nil
    }
    
}
