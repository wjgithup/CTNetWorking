//
//  CTMemoryCacheDataCenter.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTMemoryCacheDataCenter {
    
    static let shareInstance = CTMemoryCacheDataCenter()
    private init() {}
    
    func fetchCachedRecord(key:String) -> CTURLResponse? {
        let cachedRecord = self.cache.object(forKey: key as AnyObject) as? CTMemoryCacheRecord
        guard let cached = cachedRecord else {
            return nil
        }
        guard !cached.isOutDated && !cached.isEmpty else {
            self.cache.removeObject(forKey: key as AnyObject)
            return nil
        }
        let result = CTURLResponse(data: cached.content!)
        return result
    }
    
    func cleanAll() {
        self.cache.removeAllObjects()
    }
    
    lazy var cache:NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = 100
        return cache
    }()
    
}
