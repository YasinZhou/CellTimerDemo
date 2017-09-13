//
//  ViewController.swift
//  CellTimerDemo
//
//  Created by Yasin on 2017/9/12.
//  Copyright © 2017年 Yasin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    fileprivate let data: [TimeInterval] = Array(0..<60).map { (item:Int) in
        var time = NSDate().timeIntervalSince1970
        time -= 60*60*3
        time += TimeInterval(60*60*item)
        return time
    }
    fileprivate let timerTableViewCellID = "TimerTableViewCell"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化YZTimerUtil，并且获取服务器当前时间
        YZTimerUtil.sharedInstance.resetServerTime()
        YZTimerUtil.sharedInstance.timerStart()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: timerTableViewCellID, for: indexPath) as! TimerTableViewCell
        cell.textLabel?.text = "第\(indexPath.row)个数据"
        cell.time = data[indexPath.row]
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let timerCell = cell as! TimerTableViewCell
//        YZTimerUtil.sharedInstance.addListener(listener: timerCell)
//    }
//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let timerCell = cell as! TimerTableViewCell
//        YZTimerUtil.sharedInstance.removeListener(listener: timerCell)
//    }
}

