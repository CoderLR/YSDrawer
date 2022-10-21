//
//  XJLeftViewController.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/17.
//

import UIKit

class XJLeftViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    fileprivate lazy var headerView: UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        imgView.contentMode = .scaleAspectFill
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "bg3.jpg")
        return imgView
    }()
    
    fileprivate var titles: [String] = ["close and push",
                                        "open and present",
                                        "close and presnet"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.75, height: self.view.frame.size.height)
        
        setupUI()
    }
    
    /// 加载UI
    fileprivate func setupUI() {
        tableView.frame = self.view.bounds
        tableView.tableHeaderView = headerView
        self.view.addSubview(tableView)
    }
    
    deinit {
        print("XJLeftViewController---dealloc")
    }
}

extension XJLeftViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 返回每组个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    // 返回cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "UITableViewCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.textLabel?.textColor = UIColor.black
        let title = titles[indexPath.row]
        cell.textLabel?.text = title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // 返回cell的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // 点击cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            self.ys_pushViewController(controller: XJNextViewController())
        } else if indexPath.row == 1 {
            self.ys_presentViewController(controller: XJNextViewController(), isClose: false)
        } else if indexPath.row == 2 {
            self.ys_presentViewController(controller: XJNextViewController(), isClose: true)
        }
    }
}
