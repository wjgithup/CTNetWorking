//
//  ViewController.swift
//  CTNetworking
//
//  Created by 王杰 on 2018/5/7.
//  Copyright © 2018年 王杰. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CTAPIManagerCallBackDelegate {
    
    var apimanager:DemoAPIManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        apimanager = DemoAPIManager()
        apimanager?.delegate = self
    }
    
    @IBAction func callApi(_ sender: Any) {
        let _ = apimanager?.loadData()
    }
    
    
    func callApiDidSuccess(manager: CTAPIBaseManager) {
        let _ = manager.fetchData(reformer: nil)

    }
    
    func callApiDidFailed(manager: CTAPIBaseManager) {
        let _ = manager.fetchData(reformer: nil)
    }
    
}

