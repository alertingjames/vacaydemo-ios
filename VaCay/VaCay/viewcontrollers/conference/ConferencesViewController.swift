//
//  ConferencesViewController.swift
//  VaCay
//
//  Created by Andre on 7/29/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import SCLAlertView
import DropDown
import Auk
import DynamicBlurView
import GSImageViewerController
import AVFoundation
import AudioToolbox

class ConferencesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var confList: UITableView!
    
    @IBOutlet weak var btn_search: UIButton!
    @IBOutlet weak var view_searchbar: UIView!
    @IBOutlet weak var edt_search: UITextField!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var noResult: UILabel!
    
    var confs = [Conference]()
    var searchConfs = [Conference]()
    
    let attrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Comfortaa-Medium", size: 16.0)!,
        .foregroundColor: UIColor.white,
    //   .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view_searchbar.isHidden = true
        edt_search.attributedPlaceholder = NSAttributedString(string: "Search...",
            attributes: attrs)
        
        edt_search.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view_searchbar.layer.cornerRadius = view_searchbar.frame.height / 2
        view_searchbar.backgroundColor = UIColor(rgb: 0xffffff, alpha: 0.3)
        
        self.confList.delegate = self
        self.confList.dataSource = self
        
        self.confList.estimatedRowHeight = 150.0
        self.confList.rowHeight = UITableView.automaticDimension
        
        if gSelectedCohort != "" || gSelectedGroupId > 0 {
            self.getGroupConferences(member_id: thisUser.idx, group_id: gSelectedGroupId, cohort: gSelectedCohort)
        }else{
            self.getConferences(member_id: thisUser.idx)
        }
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gConference = Conference()
        gConference.idx = 0
    }
    
    @IBAction func tap_search(_ sender: Any) {
        if view_searchbar.isHidden{
            view_searchbar.isHidden = false
            btn_search.setImage(cancel, for: .normal)
            lbl_title.isHidden = true
            edt_search.becomeFirstResponder()
            
        }else{
            view_searchbar.isHidden = true
            btn_search.setImage(search, for: .normal)
            lbl_title.isHidden = false
            self.edt_search.text = ""
            self.confs = searchConfs
            edt_search.resignFirstResponder()
            
            self.confList.reloadData()
        }
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
           
           
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return confs.count
    }
               
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                   
        let cell:ConfCell = tableView.dequeueReusableCell(withIdentifier: "ConfCell", for: indexPath) as! ConfCell
               
        confList.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
                   
        let index:Int = indexPath.row
        let conf = self.confs[index]
                   
        if confs.indices.contains(index) {
                       
            if conf.type == "live"{
                cell.icon.image = UIImage(named: "liveicon")
            }else if conf.type == "file" {
                cell.icon.image = UIImage(named: "videoicon")
            }else if conf.type == "youtube" {
                cell.icon.image = UIImage(named: "youtubeicon")
            }
               
            cell.icon.layer.cornerRadius = cell.icon.frame.width / 2
                       
            cell.lbl_conf_name.text = conf.name
            cell.lbl_group_name.text = conf.group_name
            if conf.event_time != ""{
                cell.lbl_start_time.visibility = .visible
                cell.lbl_start_time.text = "Start At " + conf.event_time
            }else{
                cell.lbl_start_time.visibility = .gone
            }
            
            cell.lbl_created_time.text = "Created At " + conf.created_time
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView(gesture:)))
            cell.view_content.tag = index
            cell.view_content.addGestureRecognizer(tap)
            cell.view_content.isUserInteractionEnabled = true
                       
            cell.view_content.sizeToFit()
            cell.view_content.layoutIfNeeded()
                   
        }
           
        return cell
           
    }
    
    @objc func tappedView(gesture:UIGestureRecognizer){
        let index = gesture.view?.tag
        let conf = self.confs[index!]
        if conf.type == "live"{
            
            gConference = conf
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LiveVideoConfViewController")
            self.modalPresentationStyle = .fullScreen
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
            
//            self.showInputDialog(title: "Enter security code", button_text: "Entry", index: 0)
            
        }else if conf.type == "youtube" {
            if conf.status != "notified"{
                self.showAlertDialog(title:"Sorry", message: "You don\'t have any access to this conference yet. Please be patient to wait to get notified.")
                return
            }
            gConference = conf
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "YouTubeConfViewController")
            self.modalPresentationStyle = .fullScreen
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        }else if conf.type == "file" {
            if conf.status != "notified"{
                self.showAlertDialog(title:"Sorry", message: "You don\'t have any access to this conference yet. Please be patient to wait to get notified.")
                return
            }
            gConference = conf
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "VideoFileConfViewController")
            self.modalPresentationStyle = .fullScreen
            self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
        }
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
    @objc func textFieldDidChange(_ textField: UITextField) {
            
        edt_search.attributedText = NSAttributedString(string: edt_search.text!, attributes: attrs)
            
        confs = filter(keyword: (textField.text?.lowercased())!)
        if confs.isEmpty{
                
        }
        self.confList.reloadData()
    }
        
    func filter(keyword:String) -> [Conference]{
        if keyword == ""{
            return searchConfs
        }
        var filtereds = [Conference]()
        for conf in searchConfs{
            if conf.name.lowercased().contains(keyword){
                filtereds.append(conf)
            }else{
                if conf.type.lowercased().contains(keyword){
                    filtereds.append(conf)
                }else{
                    if conf.cohort.lowercased().contains(keyword){
                        filtereds.append(conf)
                    }else{
                        if conf.group_name.lowercased().contains(keyword){
                            filtereds.append(conf)
                        }else{
                            if conf.created_time.lowercased().contains(keyword){
                                filtereds.append(conf)
                            }else{
                                if conf.event_time.lowercased().contains(keyword){
                                    filtereds.append(conf)
                                }
                            }
                        }
                    }
                }
            }
        }
        return filtereds
    }
    
    func getConferences(member_id:Int64){
        self.showLoadingView()
        APIs.getConferences(member_id: member_id, handleCallback: {
            confs, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.confs = confs!
                self.searchConfs = confs!
                
                if confs!.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.confList.reloadData()

            }
            else{
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }
    
    func getGroupConferences(member_id:Int64, group_id:Int64, cohort:String){
        self.showLoadingView()
        APIs.getGroupConferences(member_id: member_id, group_id: group_id, cohort: cohort, handleCallback: {
            confs, result_code in
            self.dismissLoadingView()
            print(result_code)
            if result_code == "0"{
                
                self.confs = confs!
                self.searchConfs = confs!
                
                if confs!.count == 0 {
                    self.noResult.isHidden = false
                }
                
                self.confList.reloadData()

            }
            else{
                if result_code == "1" {
                    self.logout()
                } else {
                    self.showToast(msg: "Something wrong!")
                }
            }
        })
    }

}
