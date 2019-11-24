//
//  HelpContentTableViewCell.swift
//  EFB Client
//
//  Created by Mr.Zee on 11/3/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

import UIKit

class HelpContentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mDescription: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
