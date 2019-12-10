

import UIKit

protocol DownloadDelegate{
    func downloadDidBegin(_ cell: PDFListTableViewCell)
    func downloadDidStop(_ cell: PDFListTableViewCell)
}

class PDFListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mNameLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mCategoryLabel: UILabel!
    @IBOutlet weak var mPDFStateButton: UIButton!
    @IBOutlet weak var mProgressView: UIProgressView!
    @IBOutlet weak var mProgressDetail: UILabel!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mDownloadStack: UIStackView!
    @IBOutlet weak var mTypeImage: UIImageView!
    
    
    var delegate:DownloadDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func _DownloadButtonTapped(_ sender: Any) {
        delegate?.downloadDidBegin(self)
    }
    
    @IBAction func _CancelDownloadButtonTapped(_ sender: Any) {
        self.mProgressView.setProgress(0, animated: false)
        delegate?.downloadDidStop(self)
    }
    
}

extension PDFListTableViewCell{
    
    func _Configure(download: Download_Model?){
        self.mDownloadStack.isHidden = !(download?.isDownloading ?? false)
        self.mPDFStateButton.isHidden = (download?.isDownloading ?? false)
    }
    
    func _UpdateDisplay(_ bytesWritten: Int64,_ totalBytesWritten: Int64,_ totalBytesExpectedToWrite: Int64,_ speed: Int,_ time: String){
        DispatchQueue.main.async{
            self.mProgressView.setProgress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite), animated: true)
            self.mProgressDetail.text = "\(String(format: "%.1f", Float(totalBytesWritten)/1000000)) MB of \(String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)) MB (\(String(format: "%.1f", (Float(speed)/1000) > Float(1024) ? (Float(speed) / 1000000) : (Float(speed) / 1000))) \((Float(speed)/1000) > Float(1024) ? "MB/s" : "KB/s")) - \(time) remaining"
        }
    }
    
}
