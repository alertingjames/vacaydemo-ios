//
//  ReplyMessageViewController.swift
//  VaCay
//
//  Created by Andre on 7/27/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class ReplyMessageViewController:  BaseViewController {

    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPicture.layer.cornerRadius = 35 / 2
        
        loadPicture(imageView: userPicture, url: URL(string: gMessage.sender.photo_url)!)
        
        sendButton.roundCorners(corners: [.topLeft], radius: 35 / 2)

        textBox.setPlaceholder(string: "Write something here...")
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
    
    @IBAction func sendMessage(_ sender: Any) {
        if textBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            showToast(msg: "Please write your message...")
            return
        }
        
        self.sendReplyMessage(me_id: thisUser.idx, member_id: gMessage.sender.idx, message_id: gMessage.idx, message: textBox.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    
    func sendReplyMessage(me_id:Int64, member_id: Int64, message_id:Int64, message:String){
        self.showLoadingView()
        APIs.replyMessage(me_id:me_id, member_id: member_id, message_id: message_id, message: message, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Message sent!")
                self.textBox.text = ""
                self.textBox.checkPlaceholder()
                self.sendButton.isHidden = true
            }else if result_code == "1"{
                self.showToast(msg: "Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg: "This user doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showToast(msg: "Somthing wrong")
                
            }
        })
    }
    
}
