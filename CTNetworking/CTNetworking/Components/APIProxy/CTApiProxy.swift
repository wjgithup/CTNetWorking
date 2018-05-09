//
//  CTApiProxy.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/9.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit
import AFNetworking

class CTApiProxy {
    
    typealias CTCallback = ((CTURLResponse)->Void)
    
    static let shareInstance = CTApiProxy()
    private init() {}
    
    var dispatchTable:Dictionary<Int, Any> = {
        let dic = Dictionary<Int,Any>()
        return dic
    }()
    var recordedRequestId:Int?
    var sessionManager:AFHTTPSessionManager = {
        let session = AFHTTPSessionManager()
        session.responseSerializer = AFHTTPResponseSerializer()
        session.securityPolicy.allowInvalidCertificates = true
        session.securityPolicy.validatesDomainName = false
        return session
    }()
    //取消请求
    func cancelRequest(requestID:Int) {
        let requestOperation = self.dispatchTable[requestID] as? URLSessionDataTask
        requestOperation?.cancel()
        self.dispatchTable.removeValue(forKey: requestID)
    }
    //批量取消请求
    func cancelRequest(requestList:Array<Int>) {
        for item in requestList {
            self.cancelRequest(requestID: item)
        }
    }
    
    func callApi(request:NSURLRequest,success:CTCallback,fail:CTCallback) -> Int {
        return 0
    }
    
}
