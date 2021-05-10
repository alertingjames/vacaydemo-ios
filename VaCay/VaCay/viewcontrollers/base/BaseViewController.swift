
import UIKit
import Toast_Swift
import FirebaseCore
import FirebaseDatabase
import VoxeetSDK
import VoxeetUXKit

class BaseViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var loadingView:UIActivityIndicatorView = UIActivityIndicatorView()
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    let cancel = UIImage(named: "ic_cancel_w")
    let search = UIImage(named: "ic_search_w")
    
    var inputDialog:InputDialog!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITextField.appearance().tintColor = UIColor(rgb: 0xEE06C6, alpha: 1.0)
        
    }
    
    func setRoundShadowButton(button:UIButton, corner:CGFloat){
        button.layer.cornerRadius = corner
        button.layer.shadowRadius = 2.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        button.layer.shadowOpacity = 0.2
    }
    
    func setRoundShadowView(view:UIView, corner:CGFloat){
        view.layer.cornerRadius = corner
        view.layer.shadowRadius = 2.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize.init(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.2
    }
    
    func addShadowToNavBar(navBar:UINavigationBar) {
        navBar.layer.shadowColor = UIColor.lightGray.cgColor
        navBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        navBar.layer.shadowRadius = 4.0
        navBar.layer.shadowOpacity = 0.8
        navBar.layer.masksToBounds = false
    }
    
    func addShadowToBar(view:UIView) {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        view.layer.shadowRadius = 4.0
        view.layer.shadowOpacity = 0.8
        view.layer.masksToBounds = false
    }
    
    func showToast(msg:String){
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = .red
        style.imageSize = CGSize(width: 20, height: 20)
        style.cornerRadius = 22
        style.horizontalPadding = 15
        style.verticalPadding = 12
        //      self.view.makeToast(msg, duration: 3.0, position: .bottom, style: style)
        self.view.makeToast(msg, duration: 3.0, point: CGPoint(x: screenWidth/2, y: screenHeight - 80), title: nil, image: UIImage(named: "ic_alert"), style: style, completion: nil)
    }
    
    func showToast2(msg:String){
        var style = ToastStyle()
        style.messageColor = .white
        style.backgroundColor = UIColor(rgb: 0x00bfff, alpha: 1.0)
        style.imageSize = CGSize(width: 20, height: 20)
        style.cornerRadius = 22
        style.horizontalPadding = 15
        style.verticalPadding = 12
        //      self.view.makeToast(msg, duration: 3.0, position: .bottom, style: style)
        self.view.makeToast(msg, duration: 3.0, point: CGPoint(x: screenWidth/2, y: screenHeight - 80), title: nil, image: UIImage(named: "ic_alert"), style: style, completion: nil)
    }
    
    func showAlertDialog(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel){(ACTION) in
            
        }
        alert.addAction(okAction)
        self.present(alert, animated:true, completion:nil);
    }
    
    func showInputDialog(title:String, button_text:String, index:Int){
        inputDialog = self.storyboard!.instantiateViewController(withIdentifier: "InputDialog") as? InputDialog
        inputDialog.view.frame = CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight)
        inputDialog.titleBox.text = title
        inputDialog.button.setTitle(button_text, for: .normal)
        inputDialog.index = index
        inputDialog.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        inputDialog.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.addChild(self.inputDialog)
        self.view.addSubview(self.inputDialog.view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    func showLoadingView(){
        loadingView.center = self.view.center
        loadingView.hidesWhenStopped = true
        loadingView.style = UIActivityIndicatorView.Style.large
        loadingView.color = UIColor.orange
        view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func dismissLoadingView(){
        loadingView.stopAnimating()
    }
    
    func showLoadingView(color:UIColor){
        loadingView.center = self.view.center
        loadingView.hidesWhenStopped = true
        loadingView.style = UIActivityIndicatorView.Style.large
        loadingView.color = color
        view.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    
    func getDateTimeFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YY, hh:mm"
        // UnComment below to get only time
        //  dayTimePeriodFormatter.dateFormat = "hh:mm a"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    func getDateFromTimeStamp(timeStamp : Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YY"
        // UnComment below to get only time
        //  dayTimePeriodFormatter.dateFormat = "hh:mm a"
        
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
    
    func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    func setIconTintColor(imageView:UIImageView, color:UIColor){
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
    }
    
    func getImageFromURL(url: URL) -> UIImage {
        var image:UIImage? = nil
        if let data = try? Data(contentsOf: url) {
            if let image = UIImage(data: data) {
                return image
            }
        }
        return image!
    }
    
    func logout() {
        
        UserDefaults.standard.set("", forKey: "email")
        UserDefaults.standard.set("", forKey: "role")

        thisUser.idx = 0
        gNote = "Logged Out"
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SplashViewController")
        vc.modalPresentationStyle = .fullScreen
        self.transitionVc(vc: vc, duration: 0.3, type: .fromLeft)
        
    }
    
    func showCallAlertDialog(title:String, message:String, alias:String, ref:DatabaseReference){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Accept", style: .destructive){(ACTION) in
            self.acceptCall(alias: alias, ref:ref)
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){(ACTION) in
            ref.removeValue()
        }
        alert.addAction(cancelAction)
        self.present(alert, animated:true, completion:nil);
    }
    
    func acceptCall(alias:String, ref:DatabaseReference) {
        VoxeetUXKit.shared.appearMaximized = true
        VoxeetUXKit.shared.telecom = true

        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .callKit
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = true

        // Conference login
        let myParticipantInfo = VTParticipantInfo(externalID: String(thisUser.idx) + String(thisUser.idx), name: thisUser.name, avatarURL: thisUser.photo_url)
        // Connect a session with participant information.
        VoxeetSDK.shared.session.open(info: myParticipantInfo) { error in
           let options = VTConferenceOptions()
            options.alias = alias
           VoxeetSDK.shared.conference.create(options: options, success: { conference in
            let joinOptions = VTJoinOptions()
            joinOptions.constraints.video = true
            VoxeetSDK.shared.conference.join(conference: conference, options: joinOptions, fail: { error in print(error) })
            
            ref.removeValue()
            
            // Notify the caller that I accepted his/her call
            var newRef:DatabaseReference!
            newRef = Database.database().reference(fromURL: ReqConst.FIREBASE_URL + "call_response").child(alias).childByAutoId()
            let load:[String:AnyObject] =
                [
                    "receiver_id": String(thisUser.idx) as AnyObject,
                    "status": "accepted" as AnyObject,
                    "time": String(Date().currentTimeMillis()) as AnyObject
                ]
            newRef.setValue(load)

           }, fail: { error in print(error)})
        }
    }

}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: Float) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha))
    }
    
    convenience init(rgb: Int, alpha: Float) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}

extension UIView {
    
    enum Visibility {
        case visible
        case invisible
        case gone
    }
    
    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }
    
    private func setVisibility(_ visibility: Visibility) {
        let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
        
        switch visibility {
        case .visible:
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            self.isHidden = true
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
        }
    }
    
    var visibilityh: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .width && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibilityh != newValue {
                self.setVisibilityh(newValue)
            }
        }
    }
    
    private func setVisibilityh(_ visibility: Visibility) {
        let constraint = (self.constraints.filter{$0.firstAttribute == .width && $0.constant == 0}.first)
        
        switch visibility {
        case .visible:
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            self.isHidden = true
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
        }
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            var masked = CACornerMask()
            if corners.contains(.topLeft) { masked.insert(.layerMinXMinYCorner) }
            if corners.contains(.topRight) { masked.insert(.layerMaxXMinYCorner) }
            if corners.contains(.bottomLeft) { masked.insert(.layerMinXMaxYCorner) }
            if corners.contains(.bottomRight) { masked.insert(.layerMaxXMaxYCorner) }
            self.layer.maskedCorners = masked
        }
        else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}

extension UIViewController {
    func transitionVc(vc: UIViewController, duration: CFTimeInterval, type: CATransitionSubtype) {
        let customVcTransition = vc
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.push
        transition.subtype = type
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        customVcTransition.modalPresentationStyle = .fullScreen
        present(customVcTransition, animated: false, completion: nil)
    }
    
    func dismissViewController() {
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
    
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

extension UITextView{
    
    func setPlaceholder(string:String) {
        
        let placeholderLabel = UILabel()
        placeholderLabel.text = string
        placeholderLabel.font = UIFont.systemFont(ofSize: (self.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 222
        placeholderLabel.frame.origin = CGPoint(x: 12, y: (self.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
    }
    
    func checkPlaceholder() {
        let placeholderLabel = self.viewWithTag(222) as! UILabel
        placeholderLabel.isHidden = !self.text.isEmpty
    }
    
}


extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

extension UIButton{

    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }

}

extension String {
    var decodeEmoji: String{
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
}

extension String {
    var encodeEmoji: String{
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }
}

extension UITextField{
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

@IBDesignable
extension UITextField {

    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }

    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
}


extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}


extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }

    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }

    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }

        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0

        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }

        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)

        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth

        return contentSize
    }
}
