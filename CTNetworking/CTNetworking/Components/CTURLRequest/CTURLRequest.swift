//
//  CTURLRequest.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTURLRequest {
    
    var urlRequest:URLRequest?
    var service:CTServiceProtocol?
    var originRequestParams:Dictionary<String,Any>?
    var actualRequestParams:Dictionary<String,Any>?
    
}
