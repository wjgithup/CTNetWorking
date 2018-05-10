//
//  CTAPIBaseManager.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/9.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTAPIBaseManager: NSObject {
    
    static let kCTAPIBaseManagerRequestID = "kCTAPIBaseManagerRequestID"
    
    weak var delegate:CTAPIManagerCallBackDelegate?
    weak var paramSource:CTAPIManagerParamSource?
    weak var validator:CTAPIManagerValidator?
    weak var interceptor:CTAPIManagerInterceptor?
    var cachePolicy:CTAPIManagerCachePolicy?
    var shouldIgnoreCache:Bool = false
    var fetchedRawData:AnyObject?
    var errorMessage:String?
    var isReachAble:Bool = true
    var errorType:CTAPIManagerErrorType?
    var successHandler:((CTAPIBaseManager)->Void)?
    var failHandler:((CTAPIBaseManager)->Void)?
    var memoryCacheSecond:TimeInterval = 3*60
    var diskCacheSecond:TimeInterval = 3*60
    weak var child:CTAPIManager?
    var response:CTURLResponse?
    
    var requestList:Array<Int>? = {
        let array = Array<Int>()
        return array
    }()
    
    var isLoading:Bool {
        get {
            return self.requestList?.count != 0
        }
        set {
            self.isLoading = newValue
        }
    }
    
    override init() {
        super.init()
        if let myself = self as? CTAPIManager {
            self.child = myself
        } else {
            assert(false, "子类需要实现CTAPIManager")
        }
    }
    
    //MARK
    func cancelAllRequests() {
        CTApiProxy.shareInstance.cancelRequest(requestList: self.requestList!)
        self.requestList?.removeAll()
    }
    
    func cancelRequest(requestID:Int) {
        self.removeRequest(requestId: requestID)
        CTApiProxy.shareInstance.cancelRequest(requestID: requestID)
    }
    
    //MARK private
    func removeRequest(requestId:Int?) {
        guard requestId != nil else {
            return
        }
        self.requestList?.remove(at: (self.requestList?.index(of: requestId!))!)
    }
    //解析数据
    func fetchData(reformer:CTAPIManagerDataReformer) -> AnyObject?{
        var resultData:AnyObject?
        resultData = reformer.reformer(manager: self, data: self.fetchedRawData as! Dictionary<String, Any>)
        return resultData
    }
    
    func loadData() -> Int {
        let params = self.paramSource?.params(manager: self)
        let id = self.loadData(params: params!)
        return id
    }
    
    func loadData(params:Dictionary<String,Any>) -> Int {
        let requestId = 0
        let reformedParams = self.reformParams(params: params)
        guard self.shouldCallApi(params: params) else {
            return requestId
        }
        let vaildatorerror = self.validator?.isParamsDataCorrect(manager: self, params: params)
        guard  vaildatorerror == .CTAPIManagerErrorTypeNoError else {
            self.failedOnCallApi(response: nil, errorType: vaildatorerror!)
            return requestId
        }
        var response:CTURLResponse! = nil
        if self.cachePolicy == CTAPIManagerCachePolicy.CTAPIManagerCachePolicyMemory && !self.shouldIgnoreCache {
            response = CTCacheCenter.shareInstance.fetchMemoryCache(serviceIdentifier: (self.child?.serviceIdentifier())!, methodName: (self.child?.methodName())!, params: reformedParams)
        }
        if self.cachePolicy == CTAPIManagerCachePolicy.CTAPIManagerCachePolicyDisk && !self.shouldIgnoreCache {
            response = CTCacheCenter.shareInstance.fetchDiskCache(serviceIdentifier: (self.child?.serviceIdentifier())!, methodName: (self.child?.methodName())!, params: params)
        }
        if response != nil {
            self.successOnCallApi(response: response)
            return 0
        }
        //实际的网络请求
        guard self.isReachAble == true else {
            self.failedOnCallApi(response: nil, errorType: .CTAPIManagerErrorTypeNoNetWork)
            return 0
        }
        
        self.isLoading = true
        let service = CTServiceFactory.shareInstance.getService(identifier: (self.child?.serviceIdentifier())!)
        let request = service.request(params: reformedParams, methodName: (self.child?.methodName())!, requestType: (self.child?.requestType())!)
        request?.service = service
        let _ = Logger.logDebugInfoRequest(request: request!, apiName: (self.child?.methodName())!, service: service)
        let requestID = CTApiProxy.shareInstance.callApi(request: request!, success: { (response) in
            self.successOnCallApi(response: response)
        }) { (response) in
            var errorType:CTAPIManagerErrorType! = nil
            if response.status == .CTURLResponseStatusErrorCancel {
                errorType = .CTAPIManagerErrorTypeCanceled
            } else if response.status == .CTURLResponseStatusErrorTimeout {
                errorType = .CTAPIManagerErrorTypeTimeout
            } else if response.status == .CTURLResponseStatusErrorNoNetwork {
                errorType = .CTAPIManagerErrorTypeNoNetWork
            }
            self.failedOnCallApi(response: response, errorType: errorType)
        }
        self.requestList?.append(requestID)
        var afparams = reformedParams
        afparams[CTAPIBaseManager.kCTAPIBaseManagerRequestID] = requestID
        self.afterCallApi(params: afparams)
        return requestID
    }
    
    func successOnCallApi(response:CTURLResponse) {
        self.isLoading = false
        self.response = response
        
        if response.content != nil {
            self.fetchedRawData = response.content as AnyObject
        } else {
            self.fetchedRawData = response.responseData as AnyObject
        }
        self.removeRequest(requestId: response.requestId)
        
        let errorType = self.validator?.isBackDataCorrect(manager: self, callBackData: response.content!)
        guard errorType == .CTAPIManagerErrorTypeNoError else {
            self.failedOnCallApi(response: response, errorType: errorType!)
            return
        }
        let _ =  self.interceptor?.didReceiveResponse!(manager: self, response: response)
        if self.beforePerformSuccess(response: response) {
            DispatchQueue.main.async {
                self.delegate?.callApiDidSuccess(manager: self)
                if self.successHandler != nil {
                    self.successHandler!(self)
                }
            }
            let _ = self.afterPerformSuccess(response: response)
        }
        if self.cachePolicy == .CTAPIManagerCachePolicyNoCache || self.shouldIgnoreCache  {
            return
        }
        if self.cachePolicy == .CTAPIManagerCachePolicyMemory {
            CTCacheCenter.shareInstance.saveMemoryCache(response: response, serviceIdentifier: (self.child?.serviceIdentifier())!, methodName: (self.child?.methodName())!, cacheTime: self.memoryCacheSecond)
        }
        if self.cachePolicy == .CTAPIManagerCachePolicyDisk {
            CTCacheCenter.shareInstance.saveDiskCache(response: response, serviceIdentifier: (self.child?.serviceIdentifier())!, methodName: (self.child?.methodName())!, cacheTime: self.diskCacheSecond)
        }
    }
    
    func failedOnCallApi(response:CTURLResponse?,errorType:CTAPIManagerErrorType) {
        self.isLoading = false
        if response != nil {
            self.response = response
        }
        self.errorType = errorType
        self.removeRequest(requestId: response?.requestId)
        // 常规错误
        if errorType == .CTAPIManagerErrorTypeNoNetWork {
            self.errorMessage = "无网络连接，请检查网络";
        }
        if errorType == .CTAPIManagerErrorTypeTimeout {
            self.errorMessage = "请求超时";
        }
        if errorType == .CTAPIManagerErrorTypeCanceled {
            self.errorMessage = "您已取消";
        }
        if errorType == .CTAPIManagerErrorTypeDownGrade {
            self.errorMessage = "网络拥塞";
        }
        //其他错误可根据业务处理  比如未登录等错误
        DispatchQueue.main.async {
            let _ = self.interceptor?.didReceiveResponse!(manager: self, response: response!)
            let _ = self.beforePerformFail(response: response!)
            if self.failHandler != nil {
                self.failHandler!(self)
            }
            let _ = self.afterPerformFail(response: response!)
        }
    }
    
    //Mark method for child
    
    func cleanData() {
        self.fetchedRawData = nil
        self.errorType = .CTAPIManagerErrorTypeDefault
    }
    
    //MARK
    
    /*
     拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
     当两种情况共存的时候，子类重载的方法一定要调用一下super
     然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
     
     notes:
     正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
     但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
     所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
     这就是decorate pattern
     */
    func beforePerformSuccess(response:CTURLResponse) -> Bool {
        guard  self.interceptor is CTAPIBaseManager else {
            return (self.interceptor?.beforePerformSuccess?(manager: self, response: response))!
        }
        return true
    }
    
    func afterPerformSuccess(response:CTURLResponse) ->Bool {
        guard self.interceptor is CTAPIBaseManager  else {
            return (self.interceptor?.afterPerformSuccess?(manager: self, response: response))!
        }
        return true
    }
    
    func beforePerformFail(response:CTURLResponse) -> Bool {
        guard self.interceptor is CTAPIBaseManager else {
            return (self.interceptor?.beforePerformFail?(manager: self, response: response))!
        }
        return true
    }
    
    func afterPerformFail(response:CTURLResponse) -> Bool {
        guard self.interceptor is CTAPIBaseManager else {
            return (self.interceptor?.afterPerformFail?(manager: self, response: response))!
        }
        return true
    }
    //如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
    //子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
    @objc func reformParams(params:Dictionary<String,Any>)->Dictionary<String,Any> {
        let selfIMP = self.method(for: #selector(CTAPIBaseManager.reformParams))
        let childIMP = (self.child as? NSObject)?.method(for: #selector(CTAPIBaseManager.reformParams))
        if selfIMP == childIMP {
            return params
        } else {
            var result:Dictionary<String,Any>?
            result = self.child?.reformParams!(params: params)
            return result ?? params
        }
    }
    
    func shouldCallApi(params:Dictionary<String,Any>) ->Bool {
        guard let _ = self.interceptor as? CTAPIBaseManager else {
            return (self.interceptor?.shouldCallApi!(manager: self, params: params))!
        }
        return true
    }
    
    func afterCallApi(params:Dictionary<String,Any>) {
        guard let _ = self.interceptor as? CTAPIBaseManager else {
           return (self.interceptor?.afterCallAPI!(manager: self, params: params))!
        }
    }
    
    deinit {
        self.cancelAllRequests()
        self.requestList = nil
    }
}
