//
//  ExpandableTableView.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/26/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import PDFKit

protocol ExpandableTableViewDelegate{
    func tableView(_ tableView: ExpandableTableView, _ selectedOutline: String)
    func tableView(_ tableView: ExpandableTableView, _ didExpand: Bool)
}

class ExpandableTableView: UIView {
    
//    private var view: UIView!
    public var mainTable:UITableView!
    public var delegate:ExpandableTableViewDelegate?
    
    private var dataSource:[PDFOutline] = []

    convenience init(dataSource: [PDFOutline]){
        self.init()
        self.dataSource = dataSource
        _Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

extension ExpandableTableView{
    
    private func _Initialize() {
//        view = ExpandableTableView.init(dataSource: self.dataSource)
//        view.frame = self.frame
//        view.backgroundColor = App_Constants.Instance.Color(.light)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(view)
//        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
//        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
//        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.mainTable = UITableView()
        self.mainTable.backgroundColor = .clear
        self.mainTable.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(mainTable)
        mainTable.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        mainTable.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        mainTable.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainTable.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mainTable.register(ExpandableTableViewCell.self, forCellReuseIdentifier: "cell")
        mainTable.dataSource = self
        mainTable.delegate = self
        mainTable.estimatedRowHeight = UITableView.automaticDimension
    }
    
}

extension ExpandableTableView:UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource[section].numberOfChildren
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var ds:[PDFOutline] = []
        for d in 0..<dataSource[indexPath.row].numberOfChildren{
            ds.append(dataSource[indexPath.row].child(at: d) ?? PDFOutline())
        }
        let cell = ExpandableTableViewCell.init(style: .default, reuseIdentifier: "cell", dataSource: ds, delegate: self)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view:ExpandableHeaderView!
        view = ExpandableHeaderView.init(title: dataSource[section].label ?? "", id: "header", isExpandable: dataSource[section].numberOfChildren > 0)
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let header = tableView.headerView(forSection: indexPath.section) as? ExpandableHeaderView{
            return header.isExpanded ? UITableView.automaticDimension : 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ExpandableTableView: ExpandableHeaderViewDelegate{
    func titleTapped(header: ExpandableHeaderView) {
        delegate?.tableView(self, header.title)
    }
    
    func ExpandButtonTapped(header: ExpandableHeaderView, isExpanded: Bool) {
        self.mainTable.beginUpdates()
        self.mainTable.reloadData()
        self.mainTable.endUpdates()
        delegate?.tableView(self, isExpanded)
    }
    
    
}

extension ExpandableTableView: ExpandableTableViewDelegate{
    func tableView(_ tableView: ExpandableTableView, _ selectedOutline: String) {
        
    }
    
    func tableView(_ tableView: ExpandableTableView, _ didExpand: Bool) {
        
    }
    
    
}
