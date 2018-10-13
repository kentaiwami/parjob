//
//  SearchShiftResultsViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

protocol SearchShiftResultsViewInterface: class {}


class SearchShiftResultsViewController: UIViewController, SearchShiftResultsViewInterface {
    
    private var presenter: SearchShiftResultsViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
        initializeNavigationItem()
        self.navigationItem.title = "検索結果"
    }
    
    init(tmpSearchResults: [[String:Any]]) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = SearchShiftResultsViewPresenter(view: self)
        presenter.setResults(results: tmpSearchResults)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeForm() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.edges(to: self.view)
    }
    
    private func initializeNavigationItem() {
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchShiftResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = presenter.getJoinString(index: indexPath.section)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getResultsCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.getDateString(index: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle = view as? UITableViewHeaderFooterView
        var txtColor = UIColor.black
        
        if presenter.isToday(index: section) {
            txtColor = UIColor.red
        }
        
        headerTitle?.textLabel?.textColor = txtColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedShiftCategoryName = presenter.getShiftCategories(tag: tableView.tag)[indexPath.section]
//        let detailVC = CalendarDetailViewController()
//        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: presenter.getCurrentAndPageDate().currentDate)
//        detailVC.setSelectedData(
//            memo: presenter.getMemo(),
//            isFollowing: presenter.getIsFollowing(),
//            title: currentDateStr + " " + selectedShiftCategoryName,
//            indexPath: indexPath,
//            tableViewShifts: presenter.getTableViewShift(tag: tableView.tag),
//            targetUserShift: presenter.getTargetUserShift()
//        )
//
//        self.navigationController!.pushViewController(detailVC, animated: true)
    }
    
    
}
