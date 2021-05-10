//
//  HomeGroupViewController.swift
//  VaCay
//
//  Created by Andre on 7/21/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class HomeGroupViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var view_community: UIView!
    @IBOutlet weak var communtiyBox: UITextField!
    
    @IBOutlet weak var membersButton: UIView!
    @IBOutlet weak var conferenceButton: UIView!
    @IBOutlet weak var groupChatButton: UIView!
    
    @IBOutlet weak var ic_members: UIImageView!
    @IBOutlet weak var ic_conference: UIImageView!
    @IBOutlet weak var ic_groupchat: UIImageView!
    @IBOutlet weak var ic_community: UIImageView!
    
    let thePicker = UIPickerView()
    
    var selectedCommunityId:Int64 = 0
    
    class Community{
        var idx:Int64 = 0
        var name:String = ""
    }
    
    var communities = [Community]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        membersButton.layer.cornerRadius = 23
        
        conferenceButton.layer.cornerRadius = 23
        
        groupChatButton.layer.cornerRadius = 23
        
        view_community.layer.borderColor = UIColor.lightGray.cgColor
        
        view_community.layer.borderWidth = 1.0
        
        view_community.layer.cornerRadius = view_community.frame.height / 2
        
        setIconTintColor(imageView: ic_members, color: UIColor.white)
        
        setIconTintColor(imageView: ic_conference, color: UIColor.white)
        
        setIconTintColor(imageView: ic_groupchat, color: UIColor.white)
        
        setIconTintColor(imageView: ic_community, color: UIColor.lightGray)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.getGroupMembers(_:)))
        membersButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getCohortConferences(_:)))
        conferenceButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.cohortGroupChat(_:)))
        groupChatButton.addGestureRecognizer(tap)
        
        thePicker.delegate = self
        communtiyBox.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        let community = Community()
        community.idx = 0
        community.name = "- Choose a Community -"
        communities.append(community)
        
        for group in gGroups{
            let community = Community()
            community.idx = group.idx
            community.name = group.name
            communities.append(community)
        }
        
        communities.sort {
            $0.name < $1.name
        }
        
    }
    
    @objc func getGroupMembers(_ sender: UITapGestureRecognizer? = nil) {
        if communtiyBox.text?.count == 0 {
            showToast(msg: "Please choose a community.")
            return
        }
        self.getGroupMembers(member_id: thisUser.idx, group_id: self.selectedCommunityId, option: "group_members")
    }
    
    @objc func getCohortConferences(_ sender: UITapGestureRecognizer? = nil) {
        if communtiyBox.text?.count == 0 {
            showToast(msg: "Please choose a community.")
            return
        }
        gSelectedGroupId = self.selectedCommunityId
        gSelectedCohort = ""
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
    }
    
    @objc func cohortGroupChat(_ sender: UITapGestureRecognizer? = nil) {
        if communtiyBox.text?.count == 0 {
            showToast(msg: "Please choose a community.")
            return
        }
        gSelectedGroupId = self.selectedCommunityId
        gSelectedCohort = ""
        self.getGroupMembers(member_id: thisUser.idx, group_id: self.selectedCommunityId, option: "group_chat")
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return communities.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            communtiyBox.text = communities[row].name
            self.selectedCommunityId = communities[row].idx
        }else{
            communtiyBox.text = ""
            self.selectedCommunityId = 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return communities[row].name
    }
    
    @objc func closePickerView()
    {
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label:UILabel
        
        if let v = view as? UILabel{
            label = v
        }
        else{
            label = UILabel()
        }
        
        if row == 0{
            label.textColor = UIColor.systemOrange
        }else{
            label.textColor = UIColor.black
        }
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 20)
        label.text = self.communities[row].name
        
        return label
    }
    
    func createToolbar()
    {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.tintColor = primaryDarkColor
        toolbar.backgroundColor = UIColor.lightGray
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SignupViewController.closePickerView))
        toolbar.setItems([doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        communtiyBox.inputAccessoryView = toolbar
    }
    
    func getGroupMembers(member_id:Int64, group_id:Int64, option:String){
        self.showLoadingView()
        APIs.getGroupMembers(member_id: member_id, group_id: group_id, handleCallback: {
            users, result in
            self.dismissLoadingView()
            gUsers = users!
            gGroupName = self.communtiyBox.text!
            if option == "group_members" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupMembersViewController")
                vc.modalPresentationStyle = .fullScreen
                self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            }else if option == "group_chat" {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "GroupChatViewController")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
            
        })
    }
    
}
