//
//  PostDetailViewController.swift
//  VaCay
//
//  Created by Andre on 7/26/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import YPImagePicker
import SwiftyJSON
import GSImageViewerController

class PostDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userPicture: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCohort: UILabel!
    
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postDateTime: UILabel!
    
    @IBOutlet weak var postImageContainer: UIView!
    @IBOutlet weak var postImageScrollView: UIScrollView!
    
    @IBOutlet weak var postDesc: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentBox: UITextView!
    @IBOutlet weak var commentImageBox: UIImageView!
    @IBOutlet weak var noResult: UILabel!
    @IBOutlet weak var view_emoji: UIView!
    @IBOutlet weak var commentLayout: UIView!
    @IBOutlet weak var commentButton2: UIButton!
    
    @IBOutlet weak var lbl_emoji1: UILabel!
    @IBOutlet weak var lbl_emoji2: UILabel!
    @IBOutlet weak var lbl_emoji3: UILabel!
    @IBOutlet weak var lbl_emoji4: UILabel!
    @IBOutlet weak var lbl_emoji5: UILabel!
    @IBOutlet weak var lbl_emoji6: UILabel!
    @IBOutlet weak var lbl_emoji7: UILabel!
    @IBOutlet weak var lbl_emoji8: UILabel!
    @IBOutlet weak var lbl_emoji9: UILabel!
    
    var blurView:DynamicBlurView!
    var sliderImagesArray = NSMutableArray()
    
    var picker:YPImagePicker!
    var imageFile:Data!
    var ImageArray = NSMutableArray()
    
    var comments = [Comment]()
    
    var emojiButtons = [UILabel]()
    var emojiStrings = [String]()
    
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gPostDetailViewController = self
        
        sendButton.visibilityh = .gone
        
        commentBox.layer.cornerRadius = commentBox.frame.height / 2
        
        self.commentImageBox.isHidden = true
        
        commentBox.setPlaceholder(string: "Write something ...")
        commentBox.textContainerInset = UIEdgeInsets(top: commentBox.textContainerInset.top, left: 8, bottom: commentBox.textContainerInset.bottom, right: 5)
        
        commentBox.delegate = self
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        emojiButtons = [lbl_emoji1, lbl_emoji2, lbl_emoji3, lbl_emoji4, lbl_emoji5, lbl_emoji6, lbl_emoji7, lbl_emoji8, lbl_emoji9]
        emojiStrings = ["💖","👍","😊","😄","😍","🙁","😂","😠","😛"]
        
        for emjButton in emojiButtons {
            let index = emojiButtons.firstIndex(of: emjButton)!
            emjButton.text = emojiStrings[index].decodeEmoji
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(addEmoji))
            emjButton.tag = index
            emjButton.isUserInteractionEnabled = true
            emjButton.addGestureRecognizer(tap)
        }
        
        self.commentLayout.isHidden = true
        
        userPicture.layer.cornerRadius = userPicture.frame.height / 2
        
        if gPost.user.photo_url != ""{
            loadPicture(imageView: userPicture, url: URL(string: gPost.user.photo_url)!)
        }
                
        userName.text = gPost.user.name
        userCohort.text = gPost.user.cohort
        postTitle.text = gPost.title
        postCategory.text = gPost.category
        postDateTime.text = gPost.posted_time
        if gPost.status == "updated" {
            postDateTime.text = "Updated at " + gPost.posted_time
        }
        
        UITextView.appearance().linkTextAttributes = [ .foregroundColor: UIColor(rgb: 0x0BFFFF, alpha: 1.0) ]
        postDesc.text = gPost.content
        likesLabel.text = String(gPost.likes)

        commentsLabel.text = String(gPost.comments)
        
        if gPost.isLiked {
            likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
        }else{
            likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
        }
        
        self.commentList.delegate = self
        self.commentList.dataSource = self
        
        self.commentList.estimatedRowHeight = 170.0
        self.commentList.rowHeight = UITableView.automaticDimension
        
        menuButton.setImageTintColor(UIColor(rgb: 0xffffff, alpha: 0.8))
        likeButton.setImageTintColor(.white)
        commentButton.setImageTintColor(.white)
        
        attachButton.setImageTintColor(.white)
        sendButton.setImageTintColor(.white)
        
        self.getPostPictures(post: gPost)
        self.getComments(post_id: gPost.idx)
        
        if gPost.user.idx == thisUser.idx{
            self.commentButton2.isHidden = true
        }
        
        if gPost.pictures == 0{
            self.postImageContainer.visibility = .gone
        }
    }
    
    @objc func addEmoji(sender:UITapGestureRecognizer){
        let label = sender.view as! UILabel
        let index = label.tag
        self.commentBox.text = self.commentBox.text + emojiStrings[index].decodeEmoji
        self.commentBox.checkPlaceholder()
        if self.commentBox.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.commentList.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        self.commentList.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.commentList.removeObserver(self, forKeyPath: "contentSize")
        self.commentList.reloadData()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if object is UITableView {
                if let newvalue = change?[.newKey]{
                    let newsize = newvalue as! CGSize
                    self.tableViewHeight.constant = newsize.height
                }
            }
        }
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        textView.checkPlaceholder()
        if textView.text == ""{
            sendButton.visibilityh = .gone
        }else{
            sendButton.visibilityh = .visible
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
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
    
    func getPostPictures(post: Post){
        self.showLoadingView()
        APIs.getPostPictures(post_id: post.idx,handleCallback: {
            pictures, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                self.postImageScrollView.auk.settings.contentMode = .scaleAspectFit
                self.blurView = DynamicBlurView(frame: self.postImageContainer.bounds)
                        
                // self.sliderImagesArray.addObjects(from: gPostPictures)
                            
                for pic in pictures! {
                    self.postImageScrollView.auk.show(url: pic.image_url)
                }
                            
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
                self.postImageScrollView.addGestureRecognizer(tap)
            }
        })
            
    }
    
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let index = self.postImageScrollView.auk.currentPageIndex
    //        print("tapped on Image: \(index)")
        let images = self.postImageScrollView.auk.images
        let image = images[index!]
            
        let imageInfo   = GSImageInfo(image: image , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView:self.postImageScrollView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }
    
    @IBAction func openDropDownMenu(_ sender:Any){
        
        let dropDown = DropDown()
        
        dropDown.anchorView = self.menuButton
        if gPost.user.idx == thisUser.idx{
            dropDown.dataSource = ["  Likes", "  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    gNewPostViewController = nil
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "EditPostViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 2{
                    let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                        (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                        self.deletePost(post_id: gPost.idx)
                    })
                    
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.dataSource = ["  Likes", "  Message"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LikesViewController")
                    self.present(vc, animated: true, completion: nil)
                }else if idx == 1{
                    gUser = gPost.user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 15.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 50
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 120
        
        dropDown.show()
        
    }
    
    @IBAction func toggleLike(_ sender: Any) {
        if gPost.idx > 0 && gPost.user.idx != thisUser.idx {
            likePost(member_id: thisUser.idx, post: gPost)
        }
    }
        
    func likePost(member_id: Int64, post: Post){
        print("post id: \(post.idx)")
        APIs.likePost(member_id: member_id, post_id: post.idx, handleCallback: {
            likes, result_code in
            if result_code == "0"{
                if !post.isLiked {
                    post.isLiked = true
                    self.likeButton.setImage(UIImage(named: "ic_liked"), for: .normal)
                }else{
                    post.isLiked = false
                    self.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
                }
                self.likesLabel.text = likes
                self.likeButton.setImageTintColor(.white)
            }else if result_code == "1"{
                self.showToast(msg:"Your account doesn\'t exist")
                self.logout()
            }else if result_code == "2"{
                self.showToast(msg:"This post doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func openCommentBox(_ sender: Any) {
        if gPost.idx > 0 && gPost.user.idx != thisUser.idx {
            self.commentLayout.isHidden = false
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func deletePost(post_id: Int64){
        self.showLoadingView()
        APIs.deletePost(post_id: post_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Deleted")
                self.dismiss(animated: true, completion: nil)
            }else if result_code == "1"{
                self.showToast(msg: "This post doesn\'t exist")
                self.dismiss(animated: true, completion: nil)
            }else {
                self.showToast(msg:"Something wrong")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
                
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                    
        let cell:CommentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
                    
        let index:Int = indexPath.row
                    
        if comments.indices.contains(index) {
                
            let comment = comments[index]
                        
            if comment.image_url != ""{
                loadPicture(imageView: cell.imageBox, url: URL(string: comment.image_url)!)
                cell.imageBox.visibilityh = .visible
            }else{
                cell.imageBox.visibilityh = .gone
            }
            
            self.commentList.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
                
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(gesture:)))

            cell.imageBox.tag = index
            cell.imageBox.addGestureRecognizer(tapGesture)
            cell.imageBox.isUserInteractionEnabled = true
                
            if comment.user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: comment.user.photo_url)!)
            }
                
            cell.userPicture.layer.cornerRadius = cell.userPicture.frame.width / 2
                        
            cell.userNameBox.text = comment.user.name
            cell.userCohortBox.text = comment.user.cohort
            cell.commentBox.text = comment.comment.decodeEmoji
            cell.commentedTimeBox.text = comment.commented_time
                
            cell.menuButton.setImageTintColor(UIColor.lightGray)
                
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(self.openCommentDropDownMenu), for: .touchUpInside)
                
    //      setRoundShadowView(view: cell.contentLayout, corner: 5.0)
                        
            cell.commentBox.sizeToFit()
            cell.contentLayout.sizeToFit()
            cell.contentLayout.layoutIfNeeded()
                    
        }
            
        return cell
            
    }
        
    @objc func imageTapped(gesture:UITapGestureRecognizer){
        if (gesture.view as? UIImageView) != nil {
            print("Image Tapped")
            let imgView = gesture.view as! UIImageView
            let index = imgView.tag
                
            let image = self.getImageFromURL(url: URL(string: comments[index].image_url)!)
            if image != nil {
                let imageInfo   = GSImageInfo(image: image, imageMode: .aspectFit)
                let transitionInfo = GSTransitionInfo(fromView:imgView)
                let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
                        
                imageViewer.dismissCompletion = {
                    print("dismissCompletion")
                }
                        
                self.present(imageViewer, animated: true, completion: nil)
            }
        }
    }
        
    @objc func openCommentDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(CommentCell.self) as! CommentCell
            
        let dropDown = DropDown()
            
        dropDown.anchorView = cell.menuButton
        if comments[index].user.idx == thisUser.idx{
            dropDown.dataSource = ["  Edit", "  Delete"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    self.commentBox.text = cell.commentBox.text.decodeEmoji
                    self.commentBox.checkPlaceholder()
                    self.commentBox.becomeFirstResponder()
                    self.commentLayout.isHidden = false
                }else if idx == 1{
                    let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this comment?", preferredStyle: .alert)
                    let noAction = UIAlertAction(title: "No", style: .cancel, handler: {
                            (action : UIAlertAction!) -> Void in })
                    let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: { alert -> Void in
                        self.deleteComment(comment_id: self.comments[index].idx)
                    })
                        
                    alert.addAction(yesAction)
                    alert.addAction(noAction)
                        
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.dataSource = ["  Message"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = self.comments[index].user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
            
        DropDown.appearance().textColor = UIColor.black
        DropDown.appearance().selectedTextColor = UIColor.white
        DropDown.appearance().textFont = UIFont.boldSystemFont(ofSize: 13.0)
        DropDown.appearance().backgroundColor = UIColor.white
        DropDown.appearance().selectionBackgroundColor = UIColor.gray
        DropDown.appearance().cellHeight = 40
        
        dropDown.separatorColor = UIColor.lightGray
        dropDown.width = 100
            
        dropDown.show()
            
    }
    
    func getComments(post_id:Int64){
        self.showLoadingView()
        APIs.getComments(post_id: post_id, handleCallback: {
            comments, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.comments = comments!
                
                self.commentsLabel.text = String(self.comments.count)
                
                if comments!.count == 0 {
                    self.noResult.isHidden = false
                }

                self.commentList.reloadData()

            }
            else{
                if result_code == "1" {
                    self.showToast(msg: "The post doesn\'t exist.")
                } else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    @IBAction func openCamera(_ sender: Any) {
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.commentImageBox.image = photo.image
                self.commentImageBox.layer.cornerRadius = 5
                self.commentImageBox.isHidden = false
                self.imageFile = photo.image.jpegData(compressionQuality: 0.8)
            }
            picker!.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func submitComment(_ sender: Any) {
        if commentBox.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showToast(msg: "Please type something...")
            return
        }
                
        let parameters: [String:Any] = [
            "member_id" : String(thisUser.idx),
            "post_id" : String(gPost.idx),
            "content" : commentBox.text?.trimmingCharacters(in: .whitespacesAndNewlines).encodeEmoji as Any,
        ]
                
        if self.imageFile != nil{
            let ImageDic = ["image" : self.imageFile!]
            // Here you can pass multiple image in array i am passing just one
            ImageArray = NSMutableArray(array: [ImageDic as NSDictionary])
                    
            self.showLoadingView()
            APIs().registerWithPicture(withUrl: ReqConst.SERVER_URL + "submitcomment", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        self.getComments(post_id: gPost.idx)
                        self.commentImageBox.isHidden = true
                        self.commentBox.text = ""
                        self.commentBox.resignFirstResponder()
                        self.commentBox.checkPlaceholder()
                        self.sendButton.visibilityh = .gone
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getPosts(member_id:thisUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getPosts(member_id:thisUser.idx)
                        }
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "This user doesn\'t exist.")
                        self.logout()
                    }else if result_code as! String == "2"{
                        self.showToast(msg: "This post doesn\'t exist.")
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getPosts(member_id:thisUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getPosts(member_id:thisUser.idx)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showToast(msg: "Something wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }else{
            self.showLoadingView()
            APIs().registerWithoutPicture(withUrl: ReqConst.SERVER_URL + "submitcomment", withParam: parameters) { (isSuccess, response) in
                // Your Will Get Response here
                self.dismissLoadingView()
                print("Response: \(response)")
                if isSuccess == true{
                    let result_code = response["result_code"] as Any
                    if result_code as! String == "0"{
                        self.getComments(post_id: gPost.idx)
                        self.commentImageBox.isHidden = true
                        self.commentBox.text = ""
                        self.commentBox.resignFirstResponder()
                        self.sendButton.visibilityh = .gone
                        self.commentBox.checkPlaceholder()
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getPosts(member_id:thisUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getPosts(member_id:thisUser.idx)
                        }
                    }else if result_code as! String == "1"{
                        self.showToast(msg: "This user doesn\'t exist.")
                        self.logout()
                    }else if result_code as! String == "2"{
                        self.showToast(msg: "This post doesn\'t exist.")
                        if gRecentViewController == gPostViewController{
                            gPostViewController.getPosts(member_id:thisUser.idx)
                        }else if gRecentViewController == gMyPostViewController{
                            gMyPostViewController.getPosts(member_id:thisUser.idx)
                        }
                        self.dismiss(animated: true, completion: nil)
                    }else {
                        self.showToast(msg: "Something wrong")
                    }
                }else{
                    let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                    self.showToast(msg: "Issue: \n" + message)
                }
            }
        }
                
    }
    
    func deleteComment(comment_id: Int64){
        self.showLoadingView()
        APIs.deleteComment(comment_id: comment_id, handleCallback: {
            result_code in
            self.dismissLoadingView()
            if result_code == "0"{
                self.showToast2(msg: "Deleted")
                self.getComments(post_id: gPost.idx)
                if gRecentViewController == gPostViewController{
                    gPostViewController.getPosts(member_id:thisUser.idx)
                }else if gRecentViewController == gMyPostViewController{
                    gMyPostViewController.getPosts(member_id:thisUser.idx)
                }
            }else if result_code == "1"{
                self.showToast(msg: "This comment doesn\'t exist")
                self.getComments(post_id: gPost.idx)
            }else {
                self.showToast(msg:"Something wrong")
            }
        })
    }
    
}
