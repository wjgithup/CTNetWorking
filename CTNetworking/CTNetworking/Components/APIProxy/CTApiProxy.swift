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
    
    static let kCTApiProxyValidateResultKeyResponseJSONObject = "kCTApiProxyValidateResultKeyResponseJSONObject"
    static let kCTApiProxyValidateResultKeyResponseJSONString = "kCTApiProxyValidateResultKeyResponseJSONString"
    static let kCTApiProxyValidateResultKeyResponseData = "kCTApiProxyValidateResultKeyResponseData"
    
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
    
    /** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
    func callApi(request:CTURLRequest,success:CTCallback,fail:CTCallback) -> Int {
        var dataTask:URLSessionDataTask! = nil
        dataTask = self.sessionManager.dataTask(with: request.urlRequest!) { (response, responseData, error) in
            let requestId  = dataTask.taskIdentifier
            self.dispatchTable.removeValue(forKey: requestId)
            let result = request.service?.result(responseData: responseData as! Data, response: response, request: request)
            let CTResponse = CTURLResponse(responseString: (result![CTApiProxy.kCTApiProxyValidateResultKeyResponseJSONString] as? String)!, requestId: requestId, request: request, responsContent: (result![CTApiProxy.kCTApiProxyValidateResultKeyResponseJSONObject] as? Dictionary<String,Any>)!, error: error!)
            
        }
        return 0
    }
    
}
