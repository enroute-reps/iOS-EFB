//
//  LibraryListModelCollectionViewCell.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/9/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class LibraryListModelCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mImageView: UIView!
    @IBOutlet weak var mTypeImage: UIImageView!
    @IBOutlet weak var mNameLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mDescLabel: UILabel!
    @IBOutlet weak var mPDFStateButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mImageView.cornerRadius = 5
    }

}
