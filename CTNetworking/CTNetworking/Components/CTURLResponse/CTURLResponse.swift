//
//  CTURLResponse.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/7.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

public enum CTURLResponseStatus {
    case CTURLResponseStatusSuccess,//该层只关心是否请求到数据，不关心数据正确性
    CTURLResponseStatusErrorTimeout,
    CTURLResponseStatusErrorCancel,
    CTURLResponseStatusErrorNoNetwork,
    CTURLResponseStatusErrorUnKnowed
}

class CTURLResponse: NSObject {
    
    var status:CTURLResponseStatus! = nil
    var contentString:String?
    var content:Dictionary<String,Any>?
    var requestId:Int?
    var request:CTURLRequest?
    var responseData:Data?
    var errorMessage:String?
    
    var acturlRequestParams:Dictionary<String, Any>?
    var originRequestParams:Dictionary<String, Any>?
    var logString:String?
    
    var isCache:Bool = false
    
    //使用缓存初始化 其iscache属性为ture
    init(data:Data) {
        super.init()
        self.status = self.getResponseStatus(error: nil)
        self.contentString = String(data: data as Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        self.requestId = 0
        self.request = nil
        self.responseData = data
        do {
            self.content = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary
        }
        self.isCache = true
    }
    
    init(responseString:String,requestId:Int,request:CTURLRequest,responsContent:Dictionary<String,Any>,error:Error) {
        super.init()
        self.contentString = responseString
        self.requestId = requestId
        self.request = request
        self.acturlRequestParams = request.actualRequestParams
        self.originRequestParams = request.originRequestParams
        self.isCache = false
        self.status = self.getResponseStatus(error: error)
        self.content = responsContent
        self.errorMessage = String(describing: error)
    }
    
    //MARK private Methods
    func getResponseStatus(error:Error?)->CTURLResponseStatus {
        guard let err = error else {
            return .CTURLResponseStatusSuccess
        }
        switch err._code {
        case NSURLErrorTimedOut:
            return .CTURLResponseStatusErrorTimeout
        case NSURLErrorCancelled:
            return .CTURLResponseStatusErrorCancel
        case NSURLErrorNotConnectedToInternet:
            return .CTURLResponseStatusErrorNoNetwork
        default:
            return .CTURLResponseStatusErrorUnKnowed
        }
    }
    
}
