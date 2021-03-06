

import UIKit
import RPCircularProgress

protocol CollectionDownloadDelegate{
    func downloadDidBegin(_ cell: PDFListCollectionViewCell)
    func downloadDidStop(_ cell: PDFListCollectionViewCell)
}

class PDFListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mImageView: UIView!
    @IBOutlet weak var mTypeImage: UIImageView!
    @IBOutlet weak var mNameLabel: UILabel!
    @IBOutlet weak var mDateLabel: UILabel!
    @IBOutlet weak var mDescLabel: UILabel!
    @IBOutlet weak var mPDFStateButton: UIButton!
    @IBOutlet weak var mDownloadView: UIView!
    @IBOutlet weak var mProgressDetail: UILabel!
    @IBOutlet weak var mCancelButton: UIButton!
    @IBOutlet weak var mProgressView: RPCircularProgress!
    
    public var delegate:CollectionDownloadDelegate?
    
    override func awakeFromNib() {
        self.mImageView.cornerRadius = 5
        self.mProgressView.thicknessRatio = 0.1
        self.mProgressView.enableIndeterminate()
    }
    
    override func prepareForReuse() {
        if !self.mDownloadView.isHidden{
            mProgressView.enableIndeterminate()
        }
    }

    
    @IBAction func _CancelButtonTapped(_ sender: Any) {
        self.mProgressView.enableIndeterminate(false, completion: {
            self.mProgressView.updateProgress(0.0)
            self.mProgressView.layer.removeAllAnimations()
        })
        delegate?.downloadDidStop(self)
    }
    
    @IBAction func _DownloadButtonTapped(_ sender: Any) {
        delegate?.downloadDidBegin(self)
    }
}

extension PDFListCollectionViewCell{
    
    func _Configure(download: Download_Model?){
        self.mDownloadView.isHidden = !(download?.isDownloading ?? false)
        if self.mDownloadView.isHidden{
            self.mProgressView.layer.removeAllAnimations()
            self.mProgressView.enableIndeterminate(false, completion: nil)
        }else{
            self.mProgressView.enableIndeterminate()
        }
        self.mPDFStateButton.isHidden = (download?.isDownloading ?? false)
    }
    
    func _UpdateDisplay(_ bytesWritten: Int64,_ totalBytesWritten: Int64,_ totalBytesExpectedToWrite: Int64,_ speed: Int,_ time: String){
        DispatchQueue.main.async{
            self.mProgressView.updateProgress(CGFloat(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)))
            self.mProgressDetail.text = "\(String(format: "%.1f", Float(totalBytesWritten)/1000000)) MB of \(String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)) MB (\(String(format: "%.1f", (Float(speed)/1000) > Float(1024) ? (Float(speed) / 1000000) : (Float(speed) / 1000))) \((Float(speed)/1000) > Float(1024) ? "MB/s" : "KB/s")) - \(time) remaining"
            if totalBytesWritten == totalBytesExpectedToWrite{
                self.mProgressView.enableIndeterminate(false, completion: nil)
            }
        }
    }
}
