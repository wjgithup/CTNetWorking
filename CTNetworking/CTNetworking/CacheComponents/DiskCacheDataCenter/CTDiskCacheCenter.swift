//
//  CTDiskCacheCenter.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTDiskCacheCenter {
    
    static let kCTDiskCacheCenterCachedObjectKeyPrefix = "kCTDiskCacheCenterCachedObjectKeyPrefix"
    
    static let shareInstance = CTDiskCacheCenter()
    private init() {}
    
    func fetchCachedRecord(key:String) -> CTURLResponse? {
        let actualKey = CTDiskCacheCenter.kCTDiskCacheCenterCachedObjectKeyPrefix + key
        let diskdata = UserDefaults.standard.data(forKey: actualKey)
        guard let data = diskdata else {
            return nil
        }
        let fetchedContent = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, Any>
        guard let content = fetchedContent else {
            return nil
        }
        let lastUpdateTimeNumber = content!["lastUpdateTime"] as? Int
        guard let lastupdatetime = lastUpdateTimeNumber else  {
            return nil
        }
        let lastUpdateTime = Date.init(timeIntervalSince1970: Double(lastupdatetime))
        let timeInterval = NSDate().timeIntervalSince(lastUpdateTime as Date)
        let cacheTime = fetchedContent!!["cacheTime"] as? Int
        var response:CTURLResponse! = nil
        if Int(timeInterval) < cacheTime!  {
            response = CTURLResponse(data: try! JSONSerialization.data(withJSONObject: fetchedContent!!["content"] ?? "", options: JSONSerialization.WritingOptions.prettyPrinted)) as CTURLResponse
        } else {
            UserDefaults.standard.removeObject(forKey: actualKey)
            UserDefaults.standard.synchronize()
        }
        return response
    }
    
    func saveCache(response:CTURLResponse,key:String,cacheTime:TimeInterval) {
        guard let content = response.content else {
            return
        }
        let data = try? JSONSerialization.data(withJSONObject: ["content":content,"lastUpdateTime":Int(NSDate().timeIntervalSince1970),"cacheTime":Int(cacheTime)], options: JSONSerialization.WritingOptions(rawValue: 0))
        guard let savedata = data else {
            return
        }
        let actualKey = CTDiskCacheCenter.kCTDiskCacheCenterCachedObjectKeyPrefix + key
        UserDefaults.standard.set(savedata, forKey: actualKey)
        UserDefaults.standard.synchronize()
    }
    
    func cleanAll() {
        let defaultsDict = UserDefaults.standard.dictionaryRepresentation()
        let keys = defaultsDict.keys.filter { (value) -> Bool in
            return value.contains(CTDiskCacheCenter.kCTDiskCacheCenterCachedObjectKeyPrefix)
        }
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }
    
}
