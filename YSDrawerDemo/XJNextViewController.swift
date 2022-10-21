//
//  XJNextViewController.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/17.
//

import UIKit

class XJNextViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "多云转晴"
        self.view.backgroundColor = UIColor.randomColor
    }
    
    deinit {
        print("XJNextViewController---dealloc")
    }

}
