

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mSeenView: UIView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mBackImage: UIImageView!
    @IBOutlet weak var mSeenViewWidth: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mSeenView.round = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
