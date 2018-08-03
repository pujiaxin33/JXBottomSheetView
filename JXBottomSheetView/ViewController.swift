//
//  ViewController.swift
//  JXBottomSheetView
//
//  Created by jiaxin on 2018/8/1.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tableView: UITableView!
    var dataSource: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray

        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "AddDish", style: .plain, target: self, action: #selector(addDish)),
            UIBarButtonItem(title: "DeleteDish", style: .plain, target: self, action: #selector(deleteDish))
        ]

        dataSource = ["回锅肉", "青椒肉丝", "麻婆豆腐", "火锅", "冷串串", "凉粉", "剁椒鱼头", "酸菜鱼", "锅盔", "天蚕土豆", "春卷"]

        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        let bottomSheet = JXBottomSheetView(contentView: tableView)
        bottomSheet.defaultMininumDisplayHeight = 100
        bottomSheet.defaultMaxinumDisplayHeight = 300
        bottomSheet.displayState = .minDisplay
        bottomSheet.frame = self.view.bounds
        view.addSubview(bottomSheet)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan")
    }

    @objc func addDish() {
        let dishs = ["回锅肉", "青椒肉丝", "麻婆豆腐", "火锅", "冷串串", "凉粉", "剁椒鱼头", "酸菜鱼", "锅盔", "天蚕土豆", "春卷"]
        let index = Int(arc4random()%UInt32(dishs.count))
        let dish = dishs[index]
        dataSource.insert(dish, at: 0)
        if dataSource.last == "空空如也" {
            dataSource.removeLast()
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }else {
            tableView.reloadData()
        }
    }

    @objc func deleteDish() {
        dataSource.removeFirst()
        if dataSource.count == 0 {
            dataSource.append("空空如也")
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }else {
            tableView.reloadData()
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
}
