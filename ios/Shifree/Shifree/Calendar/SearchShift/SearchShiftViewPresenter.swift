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
    
    func postContact() {
        guard let formValues = view?.formValue else {return}
        model.postContact(formValues: formValues)
    }
    
}

extension SearchShiftViewPresenter: SearchShiftViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
