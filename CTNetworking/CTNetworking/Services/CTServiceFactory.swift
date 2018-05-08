//
//  CTServiceFactory.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTServiceFactory {
    
    static let shareInstance = CTServiceFactory()
    private init() {}
    
    public func getService(identifier:String) -> CTServiceProtocol{
        if self.serviceStorage[identifier] == nil {
            self.serviceStorage[identifier] = self.createService(identifier: identifier)
        }
        return self.serviceStorage[identifier]!
    }
    
    private func createService(identifier:String) -> CTServiceProtocol {
        var instance:NSObject! = nil
        let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        let anyclass =  NSClassFromString(nameSpace+"."+identifier)
        if let anyc = anyclass ,let classtype = anyc as? DemoService.Type {
           instance = classtype.init()
        }
        return instance as! CTServiceProtocol
    }
    
    private lazy var serviceStorage:Dictionary<String,CTServiceProtocol> = {
        let dic = Dictionary<String,CTServiceProtocol>()
        return dic
    }()
}
