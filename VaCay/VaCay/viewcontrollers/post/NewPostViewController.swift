//
//  NewPostViewController.swift
//  VaCay
//
//  Created by Andre on 7/25/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import SCLAlertView
import Kingfisher
import YPImagePicker
import GSImageViewerController

class NewPostViewController: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var view_opencamera: UIView!
    @IBOutlet weak var btn_opencamera: UIButton!
    @IBOutlet weak var view_picturelist: UIView!
    @IBOutlet weak var image_scrollview: UIScrollView!
    @IBOutlet weak var pagecontroll: UIPageControl!
    @IBOutlet weak var view_postname: UIView!
    @IBOutlet weak var edt_postname: UITextField!
    @IBOutlet weak var view_category: UIView!
    @IBOutlet weak var edt_category: UITextField!
    @IBOutlet weak var view_desc: UIView!
    @IBOutlet weak var edt_desc: UITextView!
    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var view_notify: UIView!
    @IBOutlet weak var edt_notify: UITextField!
    
    @IBOutlet weak var image_label: UILabel!
    
    var sliderImagesArray = NSMutableArray()
    var sliderImageFilesArray = NSMutableArray()
    
    var picker:YPImagePicker!
    let thePicker = UIPickerView()
    
    let categories = [String](arrayLiteral:
        "- Choose a category -",
        "Positive Quotes",
        "Inspiration",
        "Shout-outs",
        "Wellness",
        "Activities Suggestions",
        "Resource")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gNewPostViewController = self
        
        gSelectedUsers.removeAll()
        
        setRoundShadowView(view: view_postname, corner: view_postname.frame.height / 2)
        setRoundShadowView(view: view_category, corner: view_category.frame.height / 2)
        setRoundShadowView(view: view_notify, corner: view_notify.frame.height / 2)
        setRoundShadowView(view: view_desc, corner: 5)
        setRoundShadowButton(button: btn_submit, corner: btn_submit.frame.height / 2)
        
        edt_desc.delegate = self
        edt_desc.setPlaceholder(string: "Write something here...")
        edt_desc.textContainerInset = UIEdgeInsets(top: edt_desc.textContainerInset.top, left: 8, bottom: edt_desc.textContainerInset.bottom, right: edt_desc.textContainerInset.right)
        
        image_scrollview.delegate = self
        
        image_scrollview.layer.cornerRadius = 8
        image_scrollview.layer.masksToBounds = true
        
        btn_opencamera.setImageTintColor(.white)
        view_picturelist.visibility = .gone
        
        pagecontroll.numberOfPages = 0
        
        var config = YPImagePickerConfiguration()
        config.wordings.libraryTitle = "Gallery"
        config.wordings.cameraTitle = "Camera"
        YPImagePickerConfiguration.shared = config
        picker = YPImagePicker()
        
        thePicker.delegate = self
        edt_category.inputView = thePicker
        thePicker.backgroundColor = UIColor.white
        createToolbar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.openUsersPage(_:)))
        view_notify.addGestureRecognizer(tap)
        
    }
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        textView.checkPlaceholder()
    }
    
    @IBAction func delPicture(_ sender: Any) {
        if self.sliderImagesArray.count > 0{
            self.sliderImagesArray.remove(self.sliderImagesArray[self.pagecontroll.currentPage])
            self.sliderImageFilesArray.remove(self.sliderImageFilesArray[self.pagecontroll.currentPage])
            self.loadPictures()
        }
    }
    
    func loadPictures(){
        if sliderImagesArray.count == 0{
            self.view_picturelist.visibility = .gone
            self.image_label.text = "Load pictures"
        }else{
            self.view_picturelist.visibility = .visible
            self.image_label.text = "Picked: " + String(sliderImagesArray.count)
        }
        
        print("Files: \(sliderImageFilesArray.count)")
        for i in 0..<sliderImagesArray.count {
            var imageView : UIImageView
            let xOrigin = self.image_scrollview.frame.width * CGFloat(i)
            imageView = UIImageView(frame: CGRect(x: xOrigin, y: 0, width: self.image_scrollview.frame.width, height: self.image_scrollview.frame.height))
            imageView.isUserInteractionEnabled = true
    //      let urlStr = sliderImagesArray.object(at: i)
    //      print(image_scrollview,imageView, urlStr)
    //
    //      let url = URL(string: sliderImagesArray[i] as! String)
    //      let data = try? Data(contentsOf: url!)
    //      let image = UIImage(data: data!)
            imageView.image = (sliderImagesArray.object(at: i) as! UIImage)
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
            imageView.tag = i
            imageView.addGestureRecognizer(tap)
            
            self.image_scrollview.addSubview(imageView)
        }
            
        self.image_scrollview.isPagingEnabled = true
        self.image_scrollview.bounces = false
        self.image_scrollview.showsVerticalScrollIndicator = false
        self.image_scrollview.showsHorizontalScrollIndicator = false
        self.image_scrollview.contentSize = CGSize(width:
            self.image_scrollview.frame.size.width * CGFloat(sliderImagesArray.count), height: self.image_scrollview.frame.size.height)
        self.pagecontroll.addTarget(self, action: #selector(self.changePage(_ :)), for: UIControl.Event.valueChanged)
            
        self.pagecontroll.numberOfPages = sliderImagesArray.count
            
        let x = CGFloat(self.pagecontroll.numberOfPages - 1) * self.image_scrollview.frame.size.width
        self.image_scrollview.setContentOffset(CGPoint(x: x, y :0), animated: true)
        self.pagecontroll.currentPage = self.pagecontroll.numberOfPages - 1
    }
    
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let imageView:UIImageView = (sender?.view as? UIImageView)!
        let index = imageView.tag
        let image = self.sliderImagesArray[index]
            
        let imageInfo   = GSImageInfo(image: image as! UIImage , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView: imageView)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }
        
    func loadPicture(imageView:UIImageView, url:URL){
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
                >> ResizingImageProcessor(referenceSize: imageView.frame.size, mode: .aspectFill)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "appicon.jpg"),
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
    
    @IBAction func addPicture(_ sender: Any) {
        self.view_picturelist.visibility = .visible
        self.pickPostPicture()
    }
    
    func pickPostPicture(){
        picker.didFinishPicking { [picker] items, _ in
            if let photo = items.singlePhoto {
                self.sliderImagesArray.add(photo.image)
                let imageFile = photo.image.jpegData(compressionQuality: 0.8)
                self.sliderImageFilesArray.add(imageFile!)
                self.loadPictures()
            }
            picker!.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func changePage(_ sender: Any) {
        let x = CGFloat(pagecontroll.currentPage) * image_scrollview.frame.size.width
        image_scrollview.setContentOffset(CGPoint(x: x,y :0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(image_scrollview.contentOffset.x / image_scrollview.frame.size.width)
        pagecontroll.currentPage = Int(pageNumber)
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0{
            edt_category.text = categories[row]
        }else{
            edt_category.text = ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
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
        label.text = self.categories[row]
        
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
        edt_category.inputAccessoryView = toolbar
    }
    
    @objc func openUsersPage(_ sender: UITapGestureRecognizer? = nil) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NotifiedUsersViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func createNewPost(_ sender: Any) {
        
        if self.edt_postname.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.showToast(msg: "Enter a title")
            return
        }
        
        if self.edt_category.text == ""{
            self.showToast(msg: "Choose a category")
            return
        }
        
        if self.edt_desc.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            self.showToast(msg: "Write something about the post")
            return
        }
        
        var selectedUsersJsonStr = ""
        if gSelectedUsers.count > 0{
            selectedUsersJsonStr = createSelUsersJsonString()
        }
        
        let parameters: [String:Any] = [
            "post_id" : "0",
            "member_id" : String(thisUser.idx),
            "title" : self.edt_postname.text as Any,
            "category" : self.edt_category.text as Any,
            "content" : self.edt_desc.text as Any,
            "pic_count" : String(self.sliderImageFilesArray.count) as Any,
            "members" : selectedUsersJsonStr
        ]
        
        let ImageArray:NSMutableArray = []
        for image in self.sliderImageFilesArray{
            ImageArray.add(image as! Data)
        }
        
        self.showLoadingView()
        APIs().postImageArrayRequestWithURL(withUrl: ReqConst.SERVER_URL + "createpost", withParam: parameters, withImages: ImageArray) { (isSuccess, response) in
            // Your Will Get Response here
            self.dismissLoadingView()
            print("Post Response: \(response)")
            if isSuccess == true{
                let result = response["result_code"] as Any
                print("Result: \(result)")
                if result as! String == "0"{
                    if gRecentViewController == gPostViewController{
                        gPostViewController.getPosts(member_id:thisUser.idx)
                        gPostViewController.postList.setContentOffset(.zero, animated: true)
                    }else if gRecentViewController == gMyPostViewController{
                        gMyPostViewController.getPosts(member_id:thisUser.idx)
                        gMyPostViewController.postList.setContentOffset(.zero, animated: true)
                    }
                    self.dismiss(animated: true, completion: nil)
                }else if result as! String == "1"{
                    self.showToast(msg: "Your account doesn\'t exist")
                    self.logout()
                }else{
                    self.showToast(msg: "Something is wrong")
                    if gRecentViewController == gPostViewController{
                        gPostViewController.getPosts(member_id:thisUser.idx)
                    }else if gRecentViewController == gMyPostViewController{
                        gMyPostViewController.getPosts(member_id:thisUser.idx)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }else{
                let message = "File size: " + String(response.fileSize()) + "\n" + "Description: " + response.description
                self.showToast(msg: "Issue: \n" + message)
            }
        }
    }
    
    func createSelUsersJsonString() -> String{
        var jsonArray = [Any]()
        for user in gSelectedUsers{
            let jsonObject: [String: String] = [
                    "member_id": String(user.idx),
                    "name": String(user.name),
            ]
            
            jsonArray.append(jsonObject)
        }
        
        let jsonItemsObj:[String: Any] = [
            "members":jsonArray
        ]
        
        let jsonStr = self.stringify(json: jsonItemsObj)
        return jsonStr
        
    }
    
    func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
    
}
