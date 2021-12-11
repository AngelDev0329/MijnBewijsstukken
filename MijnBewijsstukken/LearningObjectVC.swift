//
//  LearningObjectVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 28-08-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import Floaty
import AVFoundation
import AlamofireObjectMapper
import Alamofire
import AlamofireImage
import Agrume
import MobileCoreServices
import AVKit
import AVFoundation
import SCLAlertView

class LearningObjectVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, mySwiftyCamDelegate,DocumentScannerVCDelegate,PhotoVCDelegate,VideoVCDelegate{
    func completeUploadPhotoReport(_ isSuccess: Bool) {
        print("LEARNING completeUploadPhotoReport")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    
    func completeUploadFileReport(_ isSuccess: Bool) {
        print("Learning completeUploadFileReport")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    
    @IBOutlet weak var currentLevel: UILabel!
    @IBOutlet weak var completedStar: DOFavoriteButton!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var goalDescription: UILabel!
    @IBOutlet weak var CategoryIcon: UIImageView!
    @IBOutlet weak var Id: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backButtonSearch: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var pendingIcon: UIImageView!
    
    @IBOutlet weak var backToNotifications: UIButton!
    
    var completes_list: [Any] = []
    var completes_list_types: [Any] = []
    var completes_list_files: [Any] = []
    var completes_list_ids: [Int] = []
    
    var module_approving: Bool? = false
    var show_star: Bool? = false
    var is_pending: Bool? = false
    var approval_is_approved: Bool?
    var approval_message: String?
    var approval_teacher: String?
    var approval_teacher_photo: String?
    
    var floaty = Floaty()
    
    //uploadedImages
    var uploadedImages: [Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentButton.isHidden = true
        pendingIcon.isHidden = true
        
        //Add toolbar
        addGeneralToolbarItems()
        
        self.ImagesCollectionView.delegate = self
        self.ImagesCollectionView.dataSource = self
        
        self.completedStar.isUserInteractionEnabled = false
        
        //Make the label of the current level a circle (top right in title)
        currentLevel.layer.masksToBounds = true
        currentLevel.layer.cornerRadius = currentLevel.frame.width / 2
        
        backButtonSearch.isHidden = true
        backToNotifications.isHidden = true
        
        let defaults = UserDefaults.standard
        if let goal_description = defaults.string(forKey: "goal_description")
        {
            self.goalDescription.text = goal_description
        }
        if (defaults.string(forKey: "hide_back_btn") != nil)
        {
            self.backButton.isHidden = true
            self.backButtonSearch.isHidden = false
        } else {
            //            self.backButtonSearch.isHidden = false
        }
        
        if (defaults.string(forKey: "hide_back_btn_all") != nil)
        {
            self.backButton.isHidden = true
            self.backButtonSearch.isHidden = true
            self.backToNotifications.isHidden = false
        }
        
        if (defaults.string(forKey: "from_podium") != nil)
        {
            self.backButton.isHidden = true
            self.backButtonSearch.isHidden = true
            
        }
        
        
        defaults.set(nil, forKey: "report_slug")
        defaults.set(nil, forKey: "report_id")
        defaults.set(nil, forKey: "hide_back_btn")
        defaults.set(nil, forKey: "from_podium")
        defaults.set(nil, forKey: "hide_back_btn_all")
        
        defaults.removeObject(forKey: "opened_settings")
        defaults.removeObject(forKey: "hide_back_btn")
        defaults.removeObject(forKey: "hide_back_btn_all")
        
        if let goal_id = defaults.string(forKey: "goal_id")
        {
            self.Id.setTitle(goal_id, for: .normal)
            self.Id.isHidden = true;
            self.activity.startAnimating()
        }
        
        
        if let objective_niveau = defaults.string(forKey: "objective_niveau")
        {
            self.currentLevel.text = objective_niveau
        }
        if let category_icon = defaults.string(forKey: "category_icon")
        {
            self.CategoryIcon.image = UIImage(named: category_icon);
        }
        
        self.sheetBtn.isHidden = true
        if let sheet_document = defaults.string(forKey: "sheet_document")
        {
            if(sheet_document != "empty") {
                self.sheetBtn.isHidden = false
            }
        }
        
        defaults.set(nil, forKey: "report_id")
        
        //Set collection sizes
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let containerHeight = screenHeight - 250 // Toptitle 130 + Toolbar 60 + inset below
        let containerWidth = screenWidth // Inset below
        let itemWidth = containerWidth * 0.25
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemWidth, height: containerHeight / 2)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        ImagesCollectionView.collectionViewLayout = layout
        
        
        //Add buttons to Floaty button (Floaty)
        //Info:github.com/kciter/Floaty
        //and cocoadocs.org/docsets/KCFloatingActionButton/1.1.6/Classes/KCFloatingActionButton.html#/s:vC22KCFloatingActionButton22KCFloatingActionButton9itemSpaceV12CoreGraphics7CGFloat
        
        self.addFloaty(_completes: 0)
        
        completedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
        
        //Back button
        backButton.addTarget(self, action: #selector(self.popBack), for: UIControl.Event.touchUpInside)
        backButtonSearch.addTarget(self, action: #selector(self.popBackSearch), for: UIControl.Event.touchUpInside)
        backToNotifications.addTarget(self, action: #selector(self.popBackNotifications), for: UIControl.Event.touchUpInside)
        
        
        //Swipe gestures
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        //Shake gesture
        self.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    @IBOutlet weak var sheetBtn: UIButton!
    
    @IBAction func sheetOpener(_ sender: Any) {
        let defaults = UserDefaults.standard
        self.activity.isHidden = false
        self.activity.startAnimating()
        
        if let sheet_document = defaults.string(forKey: "sheet_document")
        {
            if(sheet_document != "empty") {
                print("sheet_document")
                print(sheet_document)
                let url = URL(string: sheet_document )!
                print(url)
                let data = try? Data(contentsOf: url)
                print(data)
                if let image: UIImage = UIImage(data: data!) {
                    let agrume = Agrume(image: image, background: .blurred(.light))
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                    agrume.show(from: self)
                }
            }
        }
        
    }
    
    
    @objc func reloadData()
    {
        self.reloadCompletions()
    }
    
    @IBAction func showComment(_ sender: Any) {
        let appearance_comment = SCLAlertView.SCLAppearance(
            kCircleHeight: CGFloat(100),
            kCircleIconHeight: CGFloat(90),
//            kTitleTop: CGFloat(56),
            kWindowWidth: CGFloat(400),
            kTextFieldHeight: CGFloat(46),
            kTitleFont: UIFont(name: "Roboto", size: 36)!,
            kTextFont: UIFont(name: "Roboto", size: 18)!,
            kButtonFont: UIFont(name: "Roboto", size: 18)!,
            showCloseButton: false,
            showCircularIcon: true,
            shouldAutoDismiss: true
            
        )
        
        let comment = SCLAlertView(appearance: appearance_comment)
        self.theCommentAlert = comment
        let message = self.approval_teacher!+": "+self.approval_message!+"\n _________________________________________________________"
        print(message)
        
        var alertViewIcon = UIImage(named: "Award-Popup-Icon")
        
        
        /* #########
         CUSTOM STYLING - Auto height van de label werkt nog niet bij korte teksten. Gehele styling uitgezet aangezien de standaard styling niet werkt. Het lijkt erop dat de popup deels iets pakt van de eregalerij popup o.i.d. Als ik bijv. hierboven bij appearance de 'showCloseButton' op 'true' zet, dan komt deze close button ook in de eregalerij popup.
         Zie ook de comment onder de 'annuleren knop' hier beneden.
         #########*/
        
        //Sizes and aligments of the custom subview
        let subviewY = -20
        let titleY = 44
        let messageY = titleY + 62
        
        //Create subview
        let subview = UIView()
        
        //Create custom title
        let customTitle = UILabel(frame: CGRect(x: 0, y: titleY, width: 370, height: 50))
        let customTitleHeight = customTitle.bounds.size.height
        customTitle.font = UIFont(name: "Roboto", size: 36)
        customTitle.textAlignment = NSTextAlignment.center
        customTitle.textColor = UIColor(red: 64.0/255.0, green: 165.0/255.0, blue: 188.0/255.0, alpha: 1.0)
        if(self.approval_is_approved!) {
            customTitle.text = "Goedgekeurd!"
        } else {
            customTitle.text = "Afgekeurd"
        }
        subview.addSubview(customTitle)
        
        //Create message
        let messageLabelHeight = heightForView(text: message, font: UIFont(name: "Roboto", size: 18)!, width: 360)
        let messageLabel = UILabel(frame: CGRect(x: 10, y: messageY, width: 360, height: Int(messageLabelHeight)))
        messageLabel.numberOfLines = 0
        
        messageLabel.textAlignment = .center
        messageLabel.textColor = UIColor.gray
        messageLabel.text = message
        messageLabel.sizeToFit()
        subview.addSubview(messageLabel)
        
        
        //Set subview height
        let subviewHeight = customTitleHeight + messageLabelHeight
        subview.frame = CGRect(x: 0, y: subviewY, width: 370, height: Int(subviewHeight))
        
        comment.customSubview = subview
        
        comment.addButton("Sluiten", backgroundColor: UIColor.white, textColor: UIColor.gray) {
            print("CLOSE")
        }
        
        // Afgerond
        if(self.approval_is_approved!) {
            alertViewIcon = UIImage(named: "Star-Circle-Big")
            comment.showTitle("", subTitle: message, style: SCLAlertViewStyle.success, timeout: SCLAlertView.SCLTimeoutConfiguration?.none, colorStyle: 0xFFFFFF,  colorTextButton: 0xa2a2a2, circleIconImage: alertViewIcon)
            
        } else {
            alertViewIcon = UIImage(named: "Star-Unfinished-Circle-Big")
            comment.showTitle("", subTitle: message, style: SCLAlertViewStyle.warning, timeout: SCLAlertView.SCLTimeoutConfiguration?.none, colorStyle: 0xFFFFFF,  colorTextButton: 0xa2a2a2, circleIconImage: alertViewIcon)
        }
    }
    
    //Calculate height of label based on text size and width
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        //return label.frame.height
        return label.frame.height  - 20 // + 20 // 40
    }
    
    
    var textField: UITextField?
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!        //Save reference to the UITextField
            self.textField?.placeholder = "Waarom ben jij hier trots op?";
        }
    }
    
    var theAlert: SCLAlertView?
    var theCommentAlert: SCLAlertView?
    
    @IBAction func makePodiumPlace(_ sender: UIButton, forEvent event: UIEvent) {
        
        /// https://github.com/vikmeup/SCLAlertView-Swift
        let appearance = SCLAlertView.SCLAppearance(
            kCircleHeight: CGFloat(100),
            kCircleIconHeight: CGFloat(90),
//            kTitleTop: CGFloat(56),
            kWindowWidth: CGFloat(400),
            kTextFieldHeight: CGFloat(46),
            kTitleFont: UIFont(name: "Roboto", size: 36)!,
            kTextFont: UIFont(name: "Roboto", size: 18)!,
            kButtonFont: UIFont(name: "Roboto", size: 18)!,
            showCloseButton: false,
            showCircularIcon: true,
            shouldAutoDismiss: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        self.theAlert = alert
        
        let hitPoint = sender.convert(CGPoint.zero, to: self.ImagesCollectionView)
        if let indexPath = self.ImagesCollectionView.indexPathForItem(at: hitPoint) {
            let complete_id : Int = self.completes_list_ids[indexPath.row]
            let defaults = UserDefaults.standard
            defaults.set(complete_id, forKey: "award_complete_id")
            defaults.set("", forKey: "award_reason")
            /*let txt = alert.addTextField("Waarom ben jij hier trots op?")
             txt.autocapitalizationType = (UITextAutocapitalizationType.none)
             txt.font = UIFont(name: "Roboto", size: 16)*/
            
            //Sizes and aligments of the custom subview
            let subviewHeight = 264
            let subviewY = -20
            let titleY = 44
            let subTitleY = titleY + 42
            let textY = subTitleY + 56
            let buttonsY = textY + 72
            let buttonsWidth = 70
            let buttonsHeight = 70
            let firstButtonLeft = 70
            
            let subview = UIView(frame: CGRect(x: 0, y: subviewY, width: 370, height: subviewHeight))
            
            //Create title
            let customTitle = UILabel(frame: CGRect(x: 0, y: titleY, width: 370, height: 50))
            customTitle.font = UIFont(name: "Roboto", size: 36)
            customTitle.textAlignment = NSTextAlignment.center
            customTitle.textColor = UIColor(red: 64.0/255.0, green: 165.0/255.0, blue: 188.0/255.0, alpha: 1.0)
            customTitle.text = "Eregalerij"
            subview.addSubview(customTitle)
            
            //Create subtitle
            let customSubtitle = UILabel(frame: CGRect(x: 0, y: subTitleY, width: 370, height: 50))
            customSubtitle.textAlignment = NSTextAlignment.center
            customSubtitle.textColor = UIColor.gray
            customSubtitle.text = "Voeg dit bewijsstuk toe aan je eregalerij!"
            subview.addSubview(customSubtitle)
            
            // Add textfield
            let grayBorderColor = UIColor(red: 190.0/255.0, green: 190.0/255.0, blue: 190.0/255.0, alpha: 1.0)
            let txt = UITextField(frame: CGRect(x: 10, y: textY, width: 350, height: 50))
            txt.layer.borderColor = grayBorderColor.cgColor
            txt.layer.borderWidth = 1.5
            txt.layer.cornerRadius = 5
            txt.textAlignment = NSTextAlignment.center
            txt.attributedPlaceholder = NSAttributedString(string:"Waarom ben jij hier trots op?", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            txt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            txt.spellCheckingType = .no
            txt.autocorrectionType = .no
            
            subview.addSubview(txt)
            
            //Add gold button
            let goldButton = UIButton(frame: CGRect(x: firstButtonLeft, y: buttonsY, width: buttonsWidth, height: buttonsHeight))
            goldButton.setBackgroundColor(color: UIColor(red: 241/255, green: 219/255, blue: 68/255, alpha: 1), forState: .normal)
            goldButton.setBackgroundColor(color: UIColor(red: 241/255, green: 219/255, blue: 68/255, alpha: 0.5), forState: .highlighted)
            goldButton.setTitle("1", for: .normal)
            goldButton.setTitleColor(.white, for: .normal)
            goldButton.clipsToBounds = true
            goldButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 24)
            goldButton.layer.cornerRadius = 0.5 * goldButton.bounds.size.width
            goldButton.addTarget(self, action: #selector(self.savePodiumPlaceGold), for: .touchUpInside)
            subview.addSubview(goldButton)
            
            //Add silver button
            let silverButton = UIButton(frame: CGRect(x: firstButtonLeft + buttonsWidth + 10, y: buttonsY, width: buttonsWidth, height: buttonsHeight))
            silverButton.setBackgroundColor(color: UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1), forState: .normal)
            silverButton.setBackgroundColor(color: UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.5), forState: .highlighted)
            silverButton.setTitle("2", for: .normal)
            silverButton.setTitleColor(.white, for: .normal)
            silverButton.clipsToBounds = true
            silverButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 24)
            silverButton.layer.cornerRadius = 0.5 * goldButton.bounds.size.width
            silverButton.addTarget(self, action: #selector(self.savePodiumPlaceSilver), for: .touchUpInside)
            subview.addSubview(silverButton)
            
            //Add bronze button
            let bronzeButton = UIButton(frame: CGRect(x: firstButtonLeft + buttonsWidth * 2 + 20, y: buttonsY, width: buttonsWidth, height: buttonsHeight))
            bronzeButton.setBackgroundColor(color: UIColor(red: 240/255, green: 183/255, blue: 101/255, alpha: 1), forState: .normal)
            bronzeButton.setBackgroundColor(color: UIColor(red: 240/255, green: 183/255, blue: 101/255, alpha: 0.5), forState: .highlighted)
            bronzeButton.setTitle("3", for: .normal)
            bronzeButton.setTitleColor(.white, for: .normal)
            bronzeButton.clipsToBounds = true
            bronzeButton.titleLabel?.font = UIFont(name: "Roboto-Bold", size: 24)
            bronzeButton.layer.cornerRadius = 0.5 * goldButton.bounds.size.width
            bronzeButton.addTarget(self, action: #selector(self.savePodiumPlaceBronze), for: .touchUpInside)
            
            subview.addSubview(bronzeButton)
            
            alert.customSubview = subview
            
            /*alert.addButton("Goud", backgroundColor: UIColor(red: 241/255, green: 219/255, blue: 68/255, alpha: 1), textColor: UIColor.white) {
             print("Goud Button tapped")
             self.savePodiumPlace(place: "gold", reason: txt.text!, complete_id: complete_id)
             }
             alert.addButton("Zilver", backgroundColor: UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1), textColor: UIColor.white) {
             self.savePodiumPlace(place: "silver", reason: txt.text!, complete_id: complete_id)
             }
             
             alert.addButton("Brons", backgroundColor: UIColor(red: 240/255, green: 183/255, blue: 101/255, alpha: 1), textColor: UIColor.white) {
             self.savePodiumPlace(place: "bronze", reason: txt.text!, complete_id: complete_id)
             }*/
            
            alert.addButton("Annuleren", backgroundColor: UIColor.white, textColor: UIColor.gray) {
                print("CLOSE")
            }
            
            let alertViewIcon = UIImage(named: "Award-Popup-Icon")
            alert.showTitle("", subTitle: "Voeg dit bewijsstuk toe aan je eregalerij!", style: SCLAlertViewStyle.success, timeout: SCLAlertView.SCLTimeoutConfiguration?.none, colorStyle: 0xFFFFFF,  colorTextButton: 0xa2a2a2, circleIconImage: alertViewIcon)
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let defaults = UserDefaults.standard
        defaults.set(textField.text, forKey: "award_reason")
    }
    
    func savePodiumPlace(place: String, reason: String, complete_id: Int)
    {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = [
                "api_token": token,
                "podiumplace": place,
                "complete_id": complete_id,
                "reason": reason
            ]
            let requestURL = "https://beheer.mijnbewijsstukken.nl/api/swift/podium?api_token="+token
            print(requestURL)
            let request = Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            
            request.responseString { (response) in
                print(response)
                let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "AwardStoryBoardID")
                self.navigationController?.pushViewController(innerPage!, animated: true)
                self.theAlert?.hideView()
            }
        }
    }
    
    @objc func savePodiumPlaceGold()
    {
        let defaults = UserDefaults.standard
        self.savePodiumPlace(place: "gold", reason: defaults.string(forKey: "award_reason")!, complete_id: defaults.integer(forKey: "award_complete_id"))
    }
    @objc func savePodiumPlaceSilver()
    {
        let defaults = UserDefaults.standard
        self.savePodiumPlace(place: "silver", reason: defaults.string(forKey: "award_reason")!, complete_id: defaults.integer(forKey: "award_complete_id"))
    }
    @objc func savePodiumPlaceBronze()
    {
        let defaults = UserDefaults.standard
        self.savePodiumPlace(place: "bronze", reason: defaults.string(forKey: "award_reason")!, complete_id: defaults.integer(forKey: "award_complete_id"))
    }
    
    func addFloaty(_completes :Int) {
        //Main styling Floaty button
        let floaty = Floaty()
        floaty.buttonImage = UIImage(named: "Add-File")
        floaty.size = 80
        floaty.hasShadow = false
        floaty.buttonColor = UIColor(white: 1, alpha: 0)
        floaty.itemSize = 66
        floaty.itemSpace = 20
        floaty.paddingX = 40 //center > self.view.frame.width/2 - floaty.frame.width/2
        floaty.paddingY = 40
        floaty.hasShadow = true
        floaty.overlayColor = UIColor(red: 18/255, green: 88/255, blue: 105/255, alpha: 0.6)
        
        floaty.addItem("Document", icon: UIImage(named: "Add-Scan")!, handler: { item in
            self.performSegue(withIdentifier: "segueDocScanner", sender: nil)
        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.addItem("Foto/Video", icon: UIImage(named: "Add-Cam")!, handler: { item in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller : mySwiftyCam  = storyboard.instantiateViewController(withIdentifier: "mySwiftCamStoryboardId") as! mySwiftyCam
            controller.delegate = self
            self.present(controller, animated: false, completion: nil)
        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.addItem("Audio", icon: UIImage(named: "Add-Audio")!, handler: { item in
            //            let alert = UIAlertController(title: "Audio opnemen?", message: "Dit kan binnenkort!", preferredStyle: UIAlertControllerStyle.alert)
            //            alert.addAction(UIAlertAction(title: "Jammer, maar helaas", style: UIAlertActionStyle.default, handler: nil))
            
//            let alert = UIAlertController(title: "Audio opnemen?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
//
//            let actionYes = UIAlertAction.init(title: "Ja", style: .default, handler: { (action) in
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller : RecorderVC  = storyboard.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
//                self.present(controller, animated: false, completion: nil)
//            })
//
//            alert.addAction(actionYes)
//
//            let actionNo = UIAlertAction.init(title: "Nee", style: .default, handler: { (action) in
//                alert.dismiss(animated: true, completion: nil)
//            })
//
//            alert.addAction(actionNo)
//
//            self.present(alert, animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller : RecorderVC  = storyboard.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
            self.present(controller, animated: false, completion: nil)
            
        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.addItem("Galerij", icon: UIImage(named: "Add-Gallery")!, handler: { item in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary;
                imagePicker.mediaTypes = [ (kUTTypeImage as String),(kUTTypeMovie as String)]
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.tag = 123
        
        
        // https://stackoverflow.com/questions/28197079/swift-addsubview-and-remove-it
        if let viewWithFloaty = self.view.viewWithTag(123) {
            if _completes >= 3 {
                viewWithFloaty.removeFromSuperview()
            }
        } else {
            self.view.addSubview(floaty)
        }
    }
    
    func purchaseSuccessful() {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
    }
    
    //Back button
    @objc func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is LearningObjectsVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    //Back button search
    @objc func popBackSearch(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is SearchVC {
                if((self.navigationController) != nil) {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                } else {
                    let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "learningObjectStoryBoardId")
                    self.navigationController?.pushViewController(innerPage!, animated: true)
                }
                
            }
        }
    }
    
    
    //Back button notifications
    @objc func popBackNotifications(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ReviewsVC {
                if((self.navigationController) != nil) {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                } else {
                    let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "learningObjectStoryBoardId")
                    self.navigationController?.pushViewController(innerPage!, animated: true)
                }
                
            }
        }
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LearningObjectsVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
            
        }
    }
    
    // Shake gesture - We are willing to become first responder to get shake motion
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    // Shake function Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is ClassesOverviewVC {
                    let transition = CATransition()
                    transition.duration = 0.3
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromTop
                    navigationController?.view.layer.add(transition, forKey: nil)
                    self.navigationController!.popToViewController(aViewController, animated: false)
                }
            }
        }
    }
    
    
    //    mySwiftyCam Delegate
    func completeUploadFile(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // Document Scanner Delegate
    func completeUploadScanedDocument(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // PhotoVC Delegate
    func completeUploadPhoto(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // VideoVC Delegate
    func completeUploadVideo(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    func reloadCompletions () {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
    }
    
    
    func getCompletions(token: String)
    {
        self.completes_list_ids = []
        self.completes_list = []
        self.completes_list_types = []
        self.completes_list_files = []
        self.pendingIcon.isHidden = true
        self.commentButton.isHidden = true
        
        let defaults = UserDefaults.standard
        let parameters: Parameters = ["api_token": token]
        let goal_id = defaults.string(forKey: "goal_id")
        print("GETCOMPLETES")
        let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completes/"+goal_id!
        print(URL)
        Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<CompletesResponse>) in
            
            let completeResponse = response.result.value
            
            self.module_approving = completeResponse!.module_approving
            self.show_star = completeResponse!.show_star
            self.is_pending = completeResponse!.is_pending
            self.approval_is_approved = completeResponse!.approval_is_approved
            self.approval_message = completeResponse!.approval_message
            self.approval_teacher = completeResponse!.approval_teacher
            self.approval_teacher_photo = completeResponse!.approval_teacher_photo
            
            if(self.approval_message != nil) {
                self.commentButton.isHidden = false
            }
            if(self.is_pending!) {
                self.pendingIcon.isHidden = false
            }
            
            if let completes = completeResponse?.completes {
                for complete in completes {
                    self.completes_list_ids.append(complete.id!)
                    self.completes_list.append(complete.path!)
                    self.completes_list_types.append(complete._type!)
                    self.completes_list_files.append(complete.document!)
                }
                
            }
            self.ImagesCollectionView.reloadData()
            self.activity.stopAnimating()
            print("self.completes_list.count")
            print(self.completes_list.count)
            
            self.addFloaty(_completes: self.completes_list.count)
            
            self.completedStar.deselect()
            print("AMOUNT COMPLETE")
            print(self.completes_list.count)
            
            let defaults = UserDefaults.standard
            if(self.show_star!) {
                if(self.completes_list_ids.count > 0) {
                    if let justCompleted = defaults.string(forKey: "completed")
                    {
                        if(justCompleted != "") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                if(!self.completedStar.isSelected) {
                                    self.completedStar.sendActions(for: .touchUpInside)
                                }
                            })
                        }
                        defaults.set(nil, forKey: "completed")
                    }
                    else if(self.completes_list.count > 0) {
                        if(defaults.string(forKey: "completed") == nil)
                        {
                            self.completedStar.select()
                        }
                    }
                }
            }
        }
    }
    
    //    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    //        return UIInterfaceOrientationMask.landscape
    //    }
    
    //    override var shouldAutorotate: Bool {
    //        return false;
    //    }
    //
    @IBAction func deleteCompletion(_ sender: UIButton) {
        let alert = UIAlertController(title: "Verwijderen", message: "Zeker weten dat je dit bewijs wilt verwijderen?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Verwijderen", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let hitPoint = sender.convert(CGPoint.zero, to: self.ImagesCollectionView)
            if let indexPath = self.ImagesCollectionView.indexPathForItem(at: hitPoint) {
                print(self.completes_list_ids[indexPath.row])
                print(indexPath)
                let defaults = UserDefaults.standard
                if let token = defaults.string(forKey: "user_token")
                {
                    let id : String = String(self.completes_list_ids[indexPath.row])
                    let parameters: Parameters = ["api_token": token, id: id]
                    
                    let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completion/"+id
                    Alamofire.request(URL, method: .delete, parameters: parameters)
                        .responseJSON { response in
                            
                            self.completes_list = []
                            self.completes_list_types = []
                            self.completes_list_files = []
                            self.completes_list_ids = []
                            self.completedStar.deselect()
                            
                            self.getCompletions(token: token)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Annuleren", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    //Images count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.completes_list.count
    }
    
    //Center cells
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
        
        if cellCount > 0 {
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            
            let totalCellWidth = cellWidth * cellCount
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - flowLayout.headerReferenceSize.width - flowLayout.footerReferenceSize.width
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            }
        }
        
        print("items:", cellCount)
        
        return .zero
    }
    
    /*END CENTER CELLS*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "class", for: indexPath) as! UploadedFileCell
        
        let typeComplete = self.completes_list_types[indexPath.row] as! String
        
        if(typeComplete == "video") {
            print("Video")
            let url = URL(string: self.completes_list_files[indexPath.row] as! String + "&thumb=true")
            if let thumbnailImage = getThumbnailImage(forUrl: url!) {
                cell.fileImage.image = thumbnailImage
            }
        } else if(typeComplete == "audio") {
            print("audio")
            cell.fileImage.image = UIImage(named: "microphone")
            
        } else {
            let url = URL(string: self.completes_list_files[indexPath.row] as! String)!
            let data = try? Data(contentsOf: url)
            let image: UIImage = UIImage(data: data!)!
            
            cell.fileImage.image = image
        }
        
        cell.fileImage.layer.cornerRadius = cell.fileImage.frame.width/2
        cell.fileImage.layer.masksToBounds = true
        cell.fileImage.clipsToBounds = true
        
        return cell
    }
    
    //Completed star button animation function
    
    @objc func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }
    
    
    
    @IBAction func popup(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: self.ImagesCollectionView)
        if let indexPath = self.ImagesCollectionView.indexPathForItem(at: hitPoint) {
            print(self.completes_list[indexPath.row])
            
            let url = URL(string: self.completes_list_files[indexPath.row] as! String)!
            let data = try? Data(contentsOf: url)
            let typeComplete = self.completes_list_types[indexPath.row] as! String
            if(typeComplete == "photo") {
                if let image: UIImage = UIImage(data: data!) {
                    let agrume = Agrume(image: image, background: .blurred(.light))
                    agrume.show(from: self)
                }
            }
            if(typeComplete == "video") {
                print("VIDEOPRINTER")
                print(url)
                let videoURL = URL(string: self.completes_list_files[indexPath.row] as! String)!
                //                let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            if(typeComplete == "audio") {
                print("AUDIO PRINTER")
                print(url)
                let videoURL = URL(string: self.completes_list_files[indexPath.row] as! String)!
                //                let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                
            }
        }
    }
    //    ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType.rawValue] as! String
        picker.dismiss(animated: false, completion:{
            if (mediaType == (kUTTypeImage as String) ){
                let photo = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
                let photoVC = PhotoViewController(image: photo)
                photoVC.delegate = self
                self.present(photoVC, animated: true, completion: nil)
            }else if(mediaType == (kUTTypeMovie as String) ){
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as! URL
                let videoVC = VideoViewController(videoURL: videoURL)
                videoVC.delegate = self
                self.present(videoVC, animated: true, completion: nil)
            }
        })
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDocScanner" {
            
            let vc : DocumentScannerVC = segue.destination as! DocumentScannerVC
            vc.delegate = self
        }
    }
}

extension UIImagePickerController
{
    //    override open var shouldAutorotate: Bool {
    //        return true
    //    }
    //    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
    //        return .all
    //    }
}

import ObjectMapper

class CompletesResponse: Mappable {
    var id: Int?
    var completes: [Complete]?
    var module_approving: Bool?
    var show_star: Bool?
    var is_pending: Bool?
    var approval_is_approved: Bool?
    var approval_message: String?
    var approval_teacher: String?
    var approval_teacher_photo: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        completes <- map["completes"]
        module_approving <- map["module_approving"]
        show_star <- map["show_star"]
        is_pending <- map["is_pending"]
        approval_message <- map["approval.message"]
        approval_is_approved <- map["approval.is_approved"]
        approval_teacher <- map["approval.teacher.name"]
        approval_teacher_photo <- map["approval.teacher.photo_url"]
    }
}

class Complete: Mappable {
    var id: Int?
    var path: String?
    var document: String?
    var _type: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        path <- map["path"]
        document <- map["document"]
        _type <- map["type"]
    }
}
