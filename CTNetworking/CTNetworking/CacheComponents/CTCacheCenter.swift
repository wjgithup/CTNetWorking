//
//  CTCacheCenter.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTCacheCenter {
    
    let shareInstance = CTCacheCenter()
    private init() {}
    
    let diskCacheCenter = CTDiskCacheCenter.shareInstance
    let memoryCacheCenter = CTMemoryCacheDataCenter.shareInstance
    
    func fetchDiskCache(serviceIdentifier:String,methodName:String,params:Dictionary<String,Any>) -> CTURLResponse {
        let keyString = self.getKey(serviceIdentifier: serviceIdentifier, methodName: methodName, requestParams: params)
        let response = self.diskCacheCenter.fetchCachedRecord(key: keyString)
        response?.logString = Logger.logDebugInfoResponse(response: response!, methodName: methodName, service: CTServiceFactory.shareInstance.getService(identifier: serviceIdentifier), params: params)
        return response!
    }
    
    func getKey(serviceIdentifier:String,methodName:String,requestParams:Dictionary<String,Any>) -> String {
        let string = serviceIdentifier + methodName + requestParams.getUrlParamsString()
        return string
    }
}
