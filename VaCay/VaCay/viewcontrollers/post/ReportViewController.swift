//
//  ReportViewController.swift
//  VaCay
//
//  Created by Andre on 9/14/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class ReportViewController: BaseViewController {
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        userPicture.layer.cornerRadius = 35 / 2
        
        loadPicture(imageView: userPicture, url: URL(string: gUser.photo_url)!)
        
        sendButton.roundCorners(corners: [.topLeft], radius: 35 / 2)

        textBox.setPlaceholder(string: "Write your report here...")
        textBox.textContainerInset = UIEdgeInsets(top: textBox.textContainerInset.top, left: 8, bottom: textBox.textContainerInset.bottom, right: textBox.textContainerInset.right)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.isHidden = true
        }else{
            sendButton.isHidden = false
        }
    }
    
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
            >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "logo.jpg"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                imageView.layer.cornerRadius = imageView.frame.width/2
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitReport(_ sender: Any) {
        if textBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Please write your report here...")
            return
        }
        
        self.submitReport(member_id: gUser.idx, reporter_id: thisUser.idx, message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    
    func submitReport(member_id:Int64, reporter_id: Int64, message:String){
        self.showLoadingView()
        APIs.reportMember(member_id:member_id, reporter_id: reporter_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Your report submitted!")
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "This member doesn\'t exist")
            }else{
                self.showToast(msg: "Something wrong")
                
            }
        })
    }

}
