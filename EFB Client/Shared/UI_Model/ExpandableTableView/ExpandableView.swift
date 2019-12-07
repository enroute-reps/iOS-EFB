//
//  ExpandableView.swift
//  EFB Client
//
//  Created by Mr.Zee on 12/3/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import PDFKit

struct ExpandableModel{
    public var isOpen:Bool = false
    public var outline:PDFOutline?
}

protocol ExpandableViewDelegate{
    func goToOutline(_ outline: PDFOutline)
}

class ExpandableView: UIView {
    
    private var source:PDFOutline?
    private var data:[ExpandableModel] = []
    private var mainStack:UIStackView!
    private var scrollView:UIScrollView!
    private var delegate:ExpandableViewDelegate?
    
    convenience init(dataSource: PDFOutline, delegate: ExpandableViewDelegate){
        self.init()
        self.source = dataSource
        self.delegate = delegate
        self._Initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}

extension ExpandableView{
    
    private func _Initialize(){
        self.backgroundColor = App_Constants.Instance.Color(.light)
        self.cornerRadius = 10
        self.generateData()
        scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.isExclusiveTouch = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        mainStack = UIStackView()
        mainStack.alignment = .fill
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.addSubview(mainStack)
        self.mainStack.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
        self.mainStack.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
        self.mainStack.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
        self.mainStack.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor).isActive = true
        self.mainStack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        generateViews()
    }
    
    private func generateData(){
        self.data = []
        for c in 0..<(self.source?.numberOfChildren ?? 0){
            self.data.append(ExpandableModel.init(isOpen: false, outline: self.source?.child(at: c)))
        }
        
    }
    
    private func generateViews(){
        for (_,d) in data.enumerated(){
            mainStack.addArrangedSubview(HeaderExpandableView.init(outline: d.outline ?? PDFOutline(), delegate: self))
        }
    }
    
}


extension ExpandableView: HeaderExpandableViewDelegate{
    func outline(_ outline: PDFOutline) {
        delegate?.goToOutline(outline)
    }
}
