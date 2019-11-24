//
//  LibraryListModelTableViewCell.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/9/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class LibraryListModelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mNameLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mCategoryLabel: UILabel!
    @IBOutlet weak var mPDFStateButton: UIButton!
    @IBOutlet weak var mTypeImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
