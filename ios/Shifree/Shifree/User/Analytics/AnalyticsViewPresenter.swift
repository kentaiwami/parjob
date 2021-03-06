//
//  AnalyticsViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class AnalyticsViewPresenter {
    
    weak var view: AnalyticsViewInterface?
    let model: AnalyticsViewModel
    
    init(view: AnalyticsViewInterface) {
        self.view = view
        self.model = AnalyticsViewModel()
        model.delegate = self
    }
    
    func setData() {
        model.setData()
    }
    
    func setRange(range: String) {
        model.setRange(range: range)
    }
    
    func isNodata() -> Bool {
        return model.isNodata()
    }
    
    func getFollowTitle() -> String {
        return model.getFollowTitle()
    }
}


// MARK: - PieChart
extension AnalyticsViewPresenter {
    func getPieChartCenterTitle() -> String? {
        return model.getPieChartCenterTitle()
    }
    
    func getPieChartTables() -> [AnalyticsResultCategory]? {
        return model.getPieChartTableValue()
    }
    
    func getPieChartCustomLegend() -> [AnalyticsResultCategory] {
        return model.getPieChartCustomLegend()
    }
    
    func getPieChartColorHex() -> [String] {
        return model.getPieChartColorHex()
    }
}



// MARK: - BarChart
extension AnalyticsViewPresenter {
    func getBarChartCategoryCount() -> [[Double]] {
        return model.getBarChartCategoryCount()
    }
    
    func getBarChartLabelAndColor() -> (label: [String], color: [String]) {
        return model.getBarChartLabelAndColor()
    }
    
    func getBarChartTableTitle() -> [String] {
        return model.getBarChartTableTitle()
    }
    
    func getNodataText() -> String {
        return model.getNodataText()
    }
}


extension AnalyticsViewPresenter: AnalyticsViewModelDelegate {
    func drawPieChartView() {
        view?.drawPieChartView()
    }
    
    func drawBarChartView() {
        view?.drawBarChartView()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}

