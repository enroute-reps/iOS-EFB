

import UIKit

class HelpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mTitle: UILabel!
    @IBOutlet weak var mForwardButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
