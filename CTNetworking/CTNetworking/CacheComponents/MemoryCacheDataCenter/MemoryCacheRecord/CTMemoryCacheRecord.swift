//
//  CTMemoryCacheRecord.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/8.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class CTMemoryCacheRecord {
    var lastUpdateTime:Date?
    var cacheTime:TimeInterval?
    var content:Data? {
        didSet {
            self.lastUpdateTime = Date()
        }
    }
    var isOutDated:Bool {
        let timeinterval = Date().timeIntervalSince(self.lastUpdateTime!)
        return Int(timeinterval) > Int(self.cacheTime!)
    }
    var isEmpty:Bool {
        return self.content == nil
    }
    
    func updateContent(content:Data) {
        self.content = content
    }
}
