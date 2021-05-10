//
//  LikesViewController.swift
//  VaCay
//
//  Created by Andre on 7/27/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import DropDown

class LikesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var noResult: UILabel!
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
            .foregroundColor: UIColor.white,
    //        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    var users = [User]()
    var searchUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        
        self.userList.delegate = self
        self.userList.dataSource = self
        
        self.userList.estimatedRowHeight = 50.0
        self.userList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.getLikes(post_id: gPost.idx)
        
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
    
     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:LikedUserCell = tableView.dequeueReusableCell(withIdentifier: "LikedUserCell", for: indexPath) as! LikedUserCell
            
        userList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if users.indices.contains(index) {
            
            let user = users[index]
                    
            if user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: user.photo_url)!)
            }
                    
            cell.userName.text = user.name
                
            if user.cohort == "admin" { cell.userCohort.text = "VaCay Community" } else { cell.userCohort.text = user.cohort}
            
            cell.menuButton.setImageTintColor(UIColor.white)
                
            cell.menuButton.tag = index
            cell.menuButton.addTarget(self, action: #selector(openLikesDropDownMenu), for: .touchUpInside)
                    
        }
                
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
            
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        edt_search.attributedText = NSAttributedString(string: edt_search.text!,
        attributes: attrs)
        
        users = filter(keyword: (textField.text?.lowercased())!)
        if users.isEmpty{
            
        }
        self.userList.reloadData()
    }
    
    func filter(keyword:String) -> [User]{
        if keyword == ""{
            return searchUsers
        }
        var filteredUsers = [User]()
        for user in searchUsers{
            if user.name.lowercased().contains(keyword){
                filteredUsers.append(user)
            }else{
                if user.phone_number.lowercased().contains(keyword){
                    filteredUsers.append(user)
                }else{
                    if user.city.lowercased().contains(keyword){
                        filteredUsers.append(user)
                    }else{
                        if user.address.contains(keyword){
                            filteredUsers.append(user)
                        }else{
                            if user.cohort.contains(keyword){
                                filteredUsers.append(user)
                            }
                        }
                    }
                }
            }
        }
        return filteredUsers
    }
    
    @objc func openLikesDropDownMenu(sender:UIButton){
        let index = sender.tag
        let cell = sender.superview?.superviewOfClassType(LikedUserCell.self) as! LikedUserCell
            
        let dropDown = DropDown()
        
        let user = self.users[sender.tag]
            
        dropDown.anchorView = cell.menuButton
        if user.idx != thisUser.idx{
            dropDown.dataSource = ["  Message"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = user
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeSendMessageViewController")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }else{
            dropDown.dataSource = ["  Unlike"]
            // Action triggered on selection
            dropDown.selectionAction = { [unowned self] (idx: Int, item: String) in
                print("Selected item: \(item) at index: \(idx)")
                if idx == 0{
                    gUser = user
                    self.likePost(member_id: thisUser.idx, post: gPost)
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
    
    func getLikes(post_id:Int64){
        self.showLoadingView()
        APIs.getLikes(post_id: post_id, handleCallback: {
            users, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.users = users!
                self.searchUsers = users!
                
                if users!.count == 0 {
                    self.noResult.isHidden = false
                }

                self.userList.reloadData()

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
    
    func likePost(member_id: Int64, post: Post){
        print("post id: \(post.idx)")
        APIs.likePost(member_id: member_id, post_id: post.idx, handleCallback: {
            likes, result_code in
            if result_code == "0"{
                gPostDetailViewController.likeButton.setImage(UIImage(named: "ic_like"), for: .normal)
                gPostDetailViewController.likeButton.setImageTintColor(.white)
                gPostDetailViewController.likesLabel.text = likes
                self.getLikes(post_id: post.idx)
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
    

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
