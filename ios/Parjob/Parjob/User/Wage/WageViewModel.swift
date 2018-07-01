//
//  WageViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol WageViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}

class WageViewModel {
    weak var delegate: WageViewModelDelegate?
    private let api = API()
    
    func getUsername() -> String {
        let keychain = Keychain()
        return (try! keychain.get("userName"))!
    }
    
    func updateUserName(newUserName: String) {
        api.updateUserName(newUserName: newUserName).done { (json) in
            let keychain = Keychain()
            try! keychain.set(newUserName, key: "userName")
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
