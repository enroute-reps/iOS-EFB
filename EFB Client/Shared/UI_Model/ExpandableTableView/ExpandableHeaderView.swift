//
//  ExpandableHeaderView.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/26/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate{
    func titleTapped(header: ExpandableHeaderView)
    func ExpandButtonTapped(header: ExpandableHeaderView, isExpanded: Bool)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    private var view: UIView!
    public var title:String = ""
    public var isExpanded:Bool = false
    public var isExpandable:Bool = false
    public var delegate:ExpandableHeaderViewDelegate?
    
    convenience init(title: String, id: String?, isExpandable: Bool){
        self.init(reuseIdentifier: id)
        self.title = title
        self.isExpandable = isExpandable
        self._Initialize()
    }
    
    override init(reuseIdentifier: String?){
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ExpandableHeaderView{
    
    private func _Initialize(){
        self.view = UIView()
        self.view.frame = self.contentView.bounds
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.view)
        view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        view.backgroundColor = .clear
        let goButton = UIButton()
        if isExpandable{
            self.view.addSubview(goButton)
            goButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 16).isActive = true
            goButton.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
            goButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
            goButton.setImage(App_Constants.Instance.Image(.forward), for: .normal)
            goButton.tintColor = .white
            goButton.addTarget(self, action: #selector(_ExpandButtonTapped(_:)), for: .touchUpInside)
        }
        let titleLabel = UILabel()
        titleLabel.font = App_Constants.Instance.Font(.semiBold, 14)
        titleLabel.text = title
        titleLabel.frame = view.bounds
        titleLabel.numberOfLines = 0
        self.view.addSubview(titleLabel)
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        if isExpandable{
            titleLabel.trailingAnchor.constraint(equalTo: goButton.leadingAnchor).isActive = true
        }else{
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        }
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(_TitleTap(_:))))
    }
    
    @objc private func _TitleTap(_ sender: UITapGestureRecognizer){
        delegate?.titleTapped(header: self)
    }
    
    @objc private func _ExpandButtonTapped(_ sender: UIButton){
        self.isExpanded = !self.isExpanded
        delegate?.ExpandButtonTapped(header: self, isExpanded: self.isExpanded)
    }
    
}
