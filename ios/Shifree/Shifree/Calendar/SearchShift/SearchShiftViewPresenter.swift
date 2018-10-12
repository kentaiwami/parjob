//
//  SearchShiftViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftViewPresentable: class {
    var username: String { get }
}

class SearchShiftViewPresenter {
    
    weak var view: SearchShiftViewInterface?
    let model: SearchShiftViewModel
    
    init(view: SearchShiftViewInterface) {
        self.view = view
        self.model = SearchShiftViewModel()
        model.delegate = self
    }
    
    func setInitData() {
        model.setInitData()
    }
    
    func getUsers() -> [String] {
        return model.getUsers()
    }
    
    func getCategories() -> [String] {
        return model.getCategories()
    }
    
    func getShifts() -> [String] {
        return model.getShifts()
    }
    
    func getTables() -> [String] {
        return model.getTables()
    }
    
    func search(isForced: Bool) {
        guard let formValue = view?.formValue else {return}
        model.search(formValue: formValue, isForced: isForced)
    }
}

extension SearchShiftViewPresenter: SearchShiftViewModelDelegate {
    func showReConfirmAlert() {
        view?.showReConfirmAlert()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
