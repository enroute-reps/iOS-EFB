//
//  PDFListCollectionViewCell.swift
//  EFB Client
//
//  Created by Mr.Zee on 10/26/19.
//  Copyright © 2019 MehrPardaz. All rights reserved.
//

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
        self.mProgressView.enableIndeterminate()
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
        self.mPDFStateButton.isHidden = (download?.isDownloading ?? false)
    }
    
    func _UpdateDisplay(_ bytesWritten: Int64,_ totalBytesWritten: Int64,_ totalBytesExpectedToWrite: Int64,_ time: String){
        DispatchQueue.main.async{
            self.mProgressView.updateProgress(CGFloat(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)))
            self.mProgressDetail.text = "\(String(format: "%.1f", Float(totalBytesWritten)/1000000)) MB of \(String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)) MB (\(String(format: "%.1f", Float(bytesWritten)/1000)) KB/s) - \(time) remaining"
            if totalBytesWritten == totalBytesExpectedToWrite{
                self.mProgressView.enableIndeterminate(false, completion: nil)
            }
        }
    }
}
