//
//  Logger.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class Logger {
    
    static func logDebugInfoRequest(request:CTURLRequest,apiName:String,service:CTServiceProtocol) -> String {
        #if DEBUG
            var logString:String! = nil
            var enviromentString:String! = nil
            switch request.service?.apiEnvironment {
            case .CTServiceAPIEnvironmentDevelop?:
                enviromentString = "Develop"
                break
            case .CTServiceAPIEnvironmentReleaseCandidate?:
                enviromentString = "Pre Release"
                break
            case .CTServiceAPIEnvironmentRelease?:
                enviromentString = "Release"
                break
            default:
                enviromentString = "UnKnow"
                break
            }; logString.append("\n\n********************************************************\nRequest Start\n********************************************************\n\n")
            logString.append("API Name:"+apiName+"\n")
            logString.append("Method"+(request.urlRequest?.httpMethod)!+"\n")
            logString.append("Status"+enviromentString+"\n")
            logString.append("URL"+(request.urlRequest?.url?.absoluteString)!+"\n")
            logString.append("\n\n********************************************************\nRequest End\n********************************************************\n\n\n")
        #endif
        return logString
    }
    
    static func logDebugInfoResponse(response:CTURLResponse,methodName:String,service:CTServiceProtocol,params:Dictionary<String,Any>) -> String {
        
        #if DEBUG
            var logString:String! = nil
            logString.append("\n\n=========================================\nCached Response                             \n=========================================\n\n")
            logString.append("API Name:\t\t"+methodName+"\n")
            logString.append("Service:"+NSStringFromClass(type(of: service))+"\n")
            logString.append("Params:"+params.jsonString()!+"\n")
            logString.append("Origin Params:"+(response.originRequestParams?.jsonString()!)!+"\n")
            logString.append("Actual Params:"+(response.acturlRequestParams?.jsonString()!)!+"\n")
            logString.append("Content:"+(response.content?.jsonString()!)!+"\n")
            logString.append("\n\n=========================================\nResponse End\n=========================================\n\n")
        #endif
        return logString;
    }
    
}
