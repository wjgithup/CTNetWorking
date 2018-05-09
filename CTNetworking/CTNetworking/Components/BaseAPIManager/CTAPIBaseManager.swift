//
//  CTAPIBaseManager.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/9.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTAPIBaseManager: NSObject {
    
    weak var delegate:CTAPIManagerCallBackDelegate?
    weak var paramSource:CTAPIManagerParamSource?
    weak var validator:CTAPIManagerValidator?
    var fetchedRawData:AnyObject?
    var errorMessage:String?
    var isReachAble:Bool = true
    var errorType:CTAPIManagerErrorType?
    var successHandler:((CTAPIBaseManager)->Void)?
    var failHandler:((CTAPIBaseManager)->Void)?
    var memoryCacheSecond:TimeInterval = 3*60
    var diskCacheSecond:TimeInterval = 3*60
    weak var child:CTAPIManager?
    
    var requestList:Array<Int>? = {
        let array = Array<Int>()
        return array
    }()
    
    var isLoading:Bool {
        return self.requestList?.count != 0
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
    func removeRequest(requestId:Int) {
        self.requestList?.remove(at: (self.requestList?.index(of: requestId))!)
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
        var requestId = 0
        let reformedParams = self.reformParams(params: params)
        return 0
    }
    
    //Mark method for child
    
    func cleanData() {
        self.fetchedRawData = nil
        self.errorType = .CTAPIManagerErrorTypeDefault
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
        if let _ = self.validator as? CTAPIBaseManager {
            return true
        }
        return true
    }
    
    deinit {
        self.cancelAllRequests()
        self.requestList = nil
    }
}
