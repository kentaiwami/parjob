//
//  Utility.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Eureka
import PopupDialog
import NVActivityIndicatorView
import TinyConstraints

class Utility {
    func showRowError(row: BaseRow) {
        let rowIndex = row.indexPath!.row
        while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
            row.section?.remove(at: rowIndex + 1)
        }
        
        if !row.isValid {
            for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                let labelRow = LabelRow() {
                    $0.title = err
                    $0.cell.height = { 30 }
                    $0.cell.contentView.backgroundColor = UIColor.red
                    $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                    $0.cell.textLabel?.textAlignment = .right
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .white
                    })
                row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
            }
        }
    }
    
    func isValidateFormValue(form: Form) -> Bool {
        var err_count = 0
        for row in form.allRows {
            if !row.isHidden {
                err_count += row.validate().count
            }
        }
        
        if err_count == 0 {
            return true
        }
        
        return false
    }
    
    func isHTTPStatus2XX(statusCode: Int?) -> Bool {
        let code = String(statusCode!)
        var results:[String] = []
        
        if code.pregMatche(pattern: "2..", matches: &results) {
            return true
        }else {
            return false
        }
    }
    
    func showStandardAlert(title: String, msg: String, vc: UIViewController, isLeft: Bool = false, completion: @escaping (() -> Void) = {}) {
        let button = DefaultButton(title: "OK", dismissOnTap: true) {}
        let popup = PopupDialog(title: title, message: msg) {
            completion()
        }
        popup.transitionStyle = .zoomIn
        popup.addButtons([button])
        
        if isLeft {
            PopupDialogDefaultView.appearance().messageTextAlignment = .left
        }
        
        vc.present(popup, animated: true, completion: nil)
    }
    
    func getFormatterStringFromDate(format: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: date)
    }
    
    func getFormatterDateFromString(format: String, dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: dateString)!
    }
    
    func get24hourTime() -> [String] {
        var time: [String] = []
        
        for hour in 0...23 {
            for minute in [0, 30] {
                time.append(String(format: "%02d", hour) + ":" + String(format: "%02d", minute))
            }
        }
        return time
    }
    
    func getMatchStrings(targetString: String, pattern: String) -> [String] {
        
        var matchStrings:[String] = []
        
        do {
            
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let targetStringRange = NSRange(location: 0, length: (targetString as NSString).length)
            
            let matches = regex.matches(in: targetString, options: [], range: targetStringRange)
            
            for match in matches {
                let range = match.range(at: 0)
                let result = (targetString as NSString).substring(with: range)
                
                matchStrings.append(result)
            }
            
            return matchStrings
            
        } catch {
            print("error: getMatchStrings")
        }
        return []
    }
    
    func getFlatDate(date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.calendar = calendar
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return components.date!
    }
    
    func getEmptyView(msg: String) -> UIView {
        let imageView = UIImageView(image: UIImage(named: "empty")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UIColor.lightGray
        let msgLabel = UILabel()
        msgLabel.text = msg
        msgLabel.textColor = UIColor.lightGray
        msgLabel.numberOfLines = 0
        msgLabel.textAlignment = .center
        msgLabel.sizeToFit()
        
        let view = UIView()
        view.addSubview(imageView)
        view.addSubview(msgLabel)
        imageView.centerY(to: view, offset: -30)
        imageView.centerX(to: view)
        imageView.width(40)
        imageView.height(40)
        msgLabel.centerX(to: view)
        msgLabel.topToBottom(of: imageView, offset: 10)
        
        return view
    }
    
    func dismissViews(targetViewController: UIViewController, selectedIndex: Int) {
        let navigationController = targetViewController.navigationController
        let tabBarController = navigationController?.viewControllers.first as! UITabBarController
        tabBarController.selectedIndex = selectedIndex
        
        // 表示しているモーダルがある場合は、それを閉じてからナビゲーションのトップへ
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: {
            UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
        })
        
        // モーダルが特にない場合はそのままナビゲーションのトップへ
        UIApplication.topViewController()?.navigationController?.popToRootViewController(animated: true)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
    }
}

class Indicator {
    let indicator = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: UIColor.lightGray)
    let wh: CGFloat = 50
    
    func start() {
        if let topController = UIApplication.topViewController() {
            topController.view.addSubview(indicator)
            indicator.center(in: topController.view)
            indicator.width(wh)
            indicator.height(wh)
            indicator.startAnimating()
        }
    }
    
    func stop() {
        indicator.stopAnimating()
    }
}
