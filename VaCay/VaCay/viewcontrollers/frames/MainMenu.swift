//
//  MainMenu.swift
//  VaCay
//
//  Created by Andre on 7/20/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class MainMenu: BaseViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var profileNameBox: UILabel!
    @IBOutlet weak var networkButton: UIView!
    @IBOutlet weak var groupsButton: UIView!
    @IBOutlet weak var communitiesButton: UIView!
    @IBOutlet weak var conferencesButton: UIView!
    @IBOutlet weak var postsButton: UIView!
    @IBOutlet weak var messagesButton: UIView!
    @IBOutlet weak var profileButton: UIView!
    @IBOutlet weak var logoutButton: UIView!
    
    @IBOutlet weak var networkIcon: UIImageView!
    @IBOutlet weak var groupsIcon: UIImageView!
    @IBOutlet weak var communitiesIcon: UIImageView!
    @IBOutlet weak var conferencesIcon: UIImageView!
    @IBOutlet weak var postsIcon: UIImageView!
    @IBOutlet weak var messagesIcon: UIImageView!
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var logoutIcon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.layer.cornerRadius = 35
        
        setIconTintColor(imageView:networkIcon, color: UIColor.white)
        setIconTintColor(imageView:groupsIcon, color: UIColor.white)
        setIconTintColor(imageView:communitiesIcon, color: UIColor.white)
        setIconTintColor(imageView:conferencesIcon, color: UIColor.white)
        setIconTintColor(imageView:postsIcon, color: UIColor.white)
        setIconTintColor(imageView:messagesIcon, color: UIColor.white)
        setIconTintColor(imageView:profileIcon, color: UIColor.white)
        setIconTintColor(imageView:logoutIcon, color: UIColor.white)
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(self.getNetworkUsers(_:)))
        networkButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getGroups(_:)))
        groupsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getCommunities(_:)))
        communitiesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getConferences(_:)))
        conferencesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getPosts(_:)))
        postsButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMessages(_:)))
        messagesButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.getMyProfile(_:)))
        profileButton.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.logout(_:)))
        logoutButton.addGestureRecognizer(tap)
        
    }
    
    @objc func getNetworkUsers(_ sender: UITapGestureRecognizer? = nil) {
        gNote = ""
        self.dismissViewController()
        gHomeViewController.close_menu()
    }
    
    @objc func getGroups(_ sender: UITapGestureRecognizer? = nil) {
        gUsers = gHomeViewController.searchUsers
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeCohortViewController")
        self.present(vc, animated: true, completion: nil)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func getCommunities(_ sender: UITapGestureRecognizer? = nil) {
        if gGroups.count == 0{
            showToast(msg: "No community you belong to.")
            return
        }
        gUsers = gHomeViewController.searchUsers
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "HomeGroupViewController")
        self.present(vc, animated: true, completion: nil)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func getConferences(_ sender: UITapGestureRecognizer? = nil) {
        gSelectedGroupId = 0
        gSelectedCohort = ""
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ConferencesViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func getPosts(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        gPostOpt = "all"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PostsViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func getMessages(_ sender: UITapGestureRecognizer? = nil) {
        gId = 0
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MessageViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func getMyProfile(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ProfileViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        gHomeViewController.close_menu()
        resetSelectedUsers()
    }
    
    @objc func logout(_ sender: UITapGestureRecognizer? = nil) {
        
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "role")

        thisUser.idx = 0
        gNote = "Logged Out"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SplashViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromLeft)
        
    }
    
    func resetSelectedUsers(){
        gHomeViewController.getHomeData(member_id: thisUser.idx)
    }
    

}
