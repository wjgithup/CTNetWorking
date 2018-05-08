//
//  Dictionary+NetworkingMethods.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

extension Dictionary {
    
    func getUrlParamsString() -> String{
        var resultString:String! = nil
        for i in 0..<self.count {
            var string:String! = nil
            if i == 0 {
                string = "?" + (Array(self.keys)[i] as! String) + "=" + (Array(self.keys)[i] as! String)
            } else {
                string = "&" + (Array(self.keys)[i] as! String) + "=" + (Array(self.keys)[i] as! String)
            }
            resultString.append(string)
        }
        return resultString
    }
    
    func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        guard jsonData != nil else {
            return nil
        }
        let string = String(data: jsonData!, encoding: String.Encoding.utf8)
        return string
    }
    
}
