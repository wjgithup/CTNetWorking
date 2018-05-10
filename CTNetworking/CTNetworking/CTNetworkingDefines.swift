//
//  CTNetworkingDefines.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

public enum CTServiceAPIEnvironment {
    case CTServiceAPIEnvironmentDevelop,
    CTServiceAPIEnvironmentReleaseCandidate,
    CTServiceAPIEnvironmentRelease
}

@objc public enum CTAPIManagerRequestType:Int {
    case CTAPIManagerRequestTypePost,
    CTAPIManagerRequestTypeGet,
    CTAPIManagerRequestTypePut,
    CTAPIManagerRequestTypeDelete
}

public enum CTAPIManagerErrorType {
    case CTAPIManagerErrorTypeNeedAccessToken,//需要重新刷新accessToken
    CTAPIManagerErrorTypeNeedLogin,// 需要登陆
    CTAPIManagerErrorTypeDefault,// 没有产生过API请求，这个是manager的默认状态。
    CTAPIManagerErrorTypeLoginCanceled,   // 调用API需要登陆态，弹出登陆页面之后用户取消登陆了
    CTAPIManagerErrorTypeSuccess,         // API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    CTAPIManagerErrorTypeNoContent,       // API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    CTAPIManagerErrorTypeParamsError,     // 参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    CTAPIManagerErrorTypeTimeout,         // 请求超时。CTAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看CTAPIProxy的相关代码。
    CTAPIManagerErrorTypeNoNetWork,       // 网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
    CTAPIManagerErrorTypeCanceled,        // 取消请求
    CTAPIManagerErrorTypeNoError,         // 无错误
    CTAPIManagerErrorTypeDownGrade       // APIManager被降级了
}

public enum CTAPIManagerCachePolicy {
    case CTAPIManagerCachePolicyNoCache,
    CTAPIManagerCachePolicyMemory,
    CTAPIManagerCachePolicyDisk
}

protocol CTAPIManagerCallBackDelegate:NSObjectProtocol {
    func callApiDidSuccess(manager:CTAPIBaseManager)
    func callApiDidFailed(manager:CTAPIBaseManager)
}

protocol CTAPIManagerParamSource:NSObjectProtocol {
    func params(manager:CTAPIBaseManager) -> Dictionary<String, Any>?
}

protocol CTAPIManagerValidator:NSObjectProtocol {
    func isBackDataCorrect(manager:CTAPIBaseManager,callBackData:Dictionary<String,Any>) -> CTAPIManagerErrorType
    func isParamsDataCorrect(manager:CTAPIBaseManager,params:Dictionary<String,Any>) -> CTAPIManagerErrorType
}

protocol CTAPIManagerDataReformer:NSObjectProtocol {
    func reformer(manager:CTAPIBaseManager,data:Dictionary<String, Any>) -> AnyObject?
}

@objc protocol CTAPIManagerInterceptor:NSObjectProtocol {
    @objc optional func beforePerformSuccess(manager:CTAPIBaseManager,response:CTURLResponse) -> Bool
    @objc optional func afterPerformSuccess(manager:CTAPIBaseManager,response:CTURLResponse) -> Bool
    @objc optional func beforePerformFail(manager:CTAPIBaseManager,response:CTURLResponse) -> Bool
    @objc optional func afterPerformFail(manager:CTAPIBaseManager,response:CTURLResponse) -> Bool
    @objc optional func shouldCallApi(manager:CTAPIBaseManager,params:Dictionary<String,Any>) -> Bool
    @objc optional func afterCallAPI(manager:CTAPIBaseManager,params:Dictionary<String,Any>)
    @objc optional func didReceiveResponse(manager:CTAPIBaseManager,response:CTURLResponse) -> Bool
}

@objc protocol CTAPIManager:NSObjectProtocol {
    func methodName() ->String
    func serviceIdentifier() ->String
    func requestType() -> CTAPIManagerRequestType
    @objc optional func cleanData()
    @objc optional func reformParams(params:Dictionary<String,Any>)->Dictionary<String,Any>
    @objc optional func loadData(params:Dictionary<String,Any>)
}
