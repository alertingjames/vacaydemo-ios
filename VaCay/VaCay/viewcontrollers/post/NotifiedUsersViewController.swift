//
//  NotifiedUsersViewController.swift
//  VaCay
//
//  Created by Andre on 7/26/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher

class NotifiedUsersViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var userList: UITableView!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var btn_all_add: UIButton!
    
    var users = [User]()
    var searchUsers = [User]()
    
    let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
            .foregroundColor: UIColor.white,
    //        .underlineStyle: NSUnderlineStyle.single.rawValue
    ]
    
    let icUnchecked = UIImage(named: "ic_add_user")
    let icChecked = UIImage(named: "ic_checked")

    override func viewDidLoad() {
        super.viewDidLoad()

        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        
        btn_all_add.setImageTintColor(.white)
        btn_all_add.layer.cornerRadius = 3
        btn_all_add.layer.masksToBounds = true
        
        self.userList.delegate = self
        self.userList.dataSource = self
        
        self.userList.estimatedRowHeight = 50.0
        self.userList.rowHeight = UITableView.automaticDimension
        
        edt_search.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
        for: UIControl.Event.editingChanged)
        
        self.users = gUsers
        self.searchUsers = gUsers
        
        if gSelectedUsers.count == gUsers.count {
            self.btn_all_add.setImage(icChecked, for: .normal)
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
    
     /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
            
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell:NotifiedUserCell = tableView.dequeueReusableCell(withIdentifier: "NotifiedUserCell", for: indexPath) as! NotifiedUserCell
            
        userList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                
        let index:Int = indexPath.row
                
        if users.indices.contains(index) {
            
            let user = users[index]
                    
            if user.photo_url != ""{
                loadPicture(imageView: cell.userPicture, url: URL(string: user.photo_url)!)
            }
                    
            cell.userName.text = user.name
            cell.userUsername.text = user.username
                
            if user.cohort == "admin" { cell.userCohort.text = "VaCay Community" } else { cell.userCohort.text = user.cohort}
                
            if gSelectedUsers.contains(where: {$0 === user}){
                cell.userAddButton.setImage(icChecked, for: .normal)
            }else{
                cell.userAddButton.setImage(icUnchecked, for: .normal)
                cell.userAddButton.setImageTintColor(UIColor.white)
            }
                
            cell.userAddButton.tag = index
            cell.userAddButton.addTarget(self, action: #selector(addUser), for: .touchUpInside)
                    
        }
                
        cell.view_content.sizeToFit()
        cell.view_content.layoutIfNeeded()
                
        return cell
    }
            
    @objc func addUser(sender : UIButton){
        let user = self.users[sender.tag]
        if gSelectedUsers.contains(where: { $0 === user }){
            gSelectedUsers.remove(at: gSelectedUsers.firstIndex(where: {$0 === user})!)
            sender.setImage(icUnchecked, for: .normal)
            sender.setImageTintColor(.white)
        }else{
            gSelectedUsers.append(user)
            sender.setImage(icChecked, for: .normal)
        }
        
        if gNewPostViewController != nil{
            if gSelectedUsers.count > 0{
                gNewPostViewController.edt_notify.text = "Selected " + String(gSelectedUsers.count) + " users"
            }else{
                gNewPostViewController.edt_notify.text = ""
            }
        }else if gEditPostViewController != nil{
            if gSelectedUsers.count > 0{
                gEditPostViewController.edt_notify.text = "Selected " + String(gSelectedUsers.count) + " users"
            }else{
                gEditPostViewController.edt_notify.text = ""
            }
        }
        
        
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
    
    @IBAction func selectAllUsers(_ sender: Any) {
        if gSelectedUsers.count == gUsers.count {
            gSelectedUsers.removeAll()
            self.btn_all_add.setImage(icUnchecked, for: .normal)
            self.btn_all_add.setImageTintColor(.white)
            if gNewPostViewController != nil{
                gNewPostViewController.edt_notify.text = ""
            }else if gEditPostViewController != nil{
                gEditPostViewController.edt_notify.text = ""
            }
        }else{
            gSelectedUsers = gUsers
            self.btn_all_add.setImage(icChecked, for: .normal)
            if gNewPostViewController != nil{
                gNewPostViewController.edt_notify.text = "Selected all users"
            }else if gEditPostViewController != nil{
                gEditPostViewController.edt_notify.text = ""
            }
        }
        self.userList.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
