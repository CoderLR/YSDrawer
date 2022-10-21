//
//  XJRightViewController.swift
//  YSDrawerDemo
//
//  Created by xj on 2022/10/17.
//

import UIKit

class XJRightViewController: UIViewController {
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.white
        tableView.tableFooterView = UIView()
        return tableView
    }()

    fileprivate var titles: [String] = ["push next",
                                        "push next",
                                        "push next"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width * 0.75, height: self.view.frame.size.height)
        
        setupUI()
    }
    
    /// 加载UI
    fileprivate func setupUI() {
        tableView.frame = CGRect(x: 0, y: 0.5 * (self.view.frame.size.height - 150), width: self.view.frame.size.width, height: 150)
        tableView.backgroundColor = UIColor.clear
        self.view.addSubview(tableView)
    }

    deinit {
        print("XJRightViewController---dealloc")
    }
}

extension XJRightViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 返回每组个数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    // 返回cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "UITableViewCell"
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white

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
        
        self.ys_pushViewController(controller: XJNextViewController())
    }
}
