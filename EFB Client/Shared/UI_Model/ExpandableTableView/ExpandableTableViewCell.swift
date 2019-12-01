//
//  ExpandableTableViewCell.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/26/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit
import PDFKit

class ExpandableTableViewCell: UITableViewCell {
    
    private var dataSource:[PDFOutline] = []
    private var table:ExpandableTableView!
    
    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, dataSource: [PDFOutline], delegate: ExpandableTableViewDelegate){
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        self.dataSource = dataSource
        table = ExpandableTableView.init(dataSource: dataSource)
        table.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(table)
        table.delegate = delegate
        self._Initialize()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension ExpandableTableViewCell{
    private func _Initialize(){
        table.frame = self.contentView.bounds
        table.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.contentView.frame.size.width * 0.1).isActive = true
        table.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        table.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        table.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        table.mainTable.reloadData()
    }
}
