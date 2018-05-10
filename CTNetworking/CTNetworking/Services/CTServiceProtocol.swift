//
//  CTServiceProtocol.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

protocol CTServiceProtocol:NSObjectProtocol {
    
    var apiEnvironment:CTServiceAPIEnvironment { get set }
    
    func request(params:Dictionary<String, Any>,methodName:String,requestType:CTAPIManagerRequestType) -> CTURLRequest?
    
    func result(responseData:Data,response:URLResponse,request:CTURLRequest) -> Dictionary<String, Any>?
    
}
