//
//  MainNavigationController.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 06-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import SCLAlertView

class MainNavigationVC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateUserInterface()
    }
    
}

//SetToolbar

class ToolbarClass: UIToolbar {
    
    //Set height of toolbar
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = 60
        return size
    }

}
    
    //Toolbar settings
extension UIViewController {
    
    func addGeneralToolbarItems()  {
        
//        if Reachability.isConnectedToNetwork(){
//            print("Internet Connection Available!")
//        }else{
//            print("Internet Connection not Available!")
//            SCLAlertView().showError("De internetverbinding is offline", subTitle: "We kunnen de App niet starten, omdat er geen werkende WiFi connectie is.")
//        }
        //Default
        //self.barStyle = UIBarStyle.default
        //self.sizeToFit()
        //Below settings are set by interface
        //self.isTranslucent = false
        //self.barTintColor = UIColor(red: 48/255, green: 148/255, blue: 172/255, alpha: 1)
        //self.backgroundColor = UIColor(red: 48/255, green: 148/255, blue: 172/255, alpha: 1)
        //self.clipsToBounds = true
        
        //Buttons ios11+
        
        //Space
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceBetween:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceBetween.width = 1.0

        let nameSpace:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        nameSpace.width = 10
        
        let negativeFixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        negativeFixedSpace.width = -20
        
        //Logo
        let logoImage = UIImage(named: "MBS-Logo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.frame = CGRect(x: -46, y: 0, width: 48, height: 54)
        logoImageView.contentMode = .scaleAspectFit
        let logoView = UIView(frame: CGRect(x: 0, y: 0, width: 48, height: 54))
        logoView.clipsToBounds = false
        logoView.layer.cornerRadius = logoView.frame.width / 2
        logoView.addSubview(logoImageView)
        let logoImg = UIBarButtonItem(customView: logoView)
        logoImg.customView = logoView

        //Profile
        let profileImage = UIImage(named: "No-Profile")
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.frame = CGRect(x: 40, y: 0, width: 50, height: 50)
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        let profileView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        profileView.clipsToBounds = false
        profileView.addSubview(profileImageView)
        let profileImg = UIBarButtonItem(customView: profileView)
        profileImg.customView = profileView
        
        //Alert
        let alertBtn = UIButton()
        alertBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.0, bottom: 0, right: 0)
        alertBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        alertBtn.setImage(UIImage(named: "Alert-Button")?.withRenderingMode(.alwaysOriginal), for: .normal) //@JASPER Alert-Button-Active indien nieuwe berichten




        alertBtn.addTarget(self, action: #selector(self.alertPressed), for: .touchUpInside)
        let alertButton = UIBarButtonItem()
        alertButton.customView = alertBtn

        //NameLabel
        let nameLbl = UILabel()
        nameLbl.frame = CGRect(x: 0, y: 0, width: 200, height: 60)

        let defaults = UserDefaults.standard
        if defaults.string(forKey: "user_name") != nil {
            nameLbl.text = "Hoi "+defaults.string(forKey: "user_name")!
        } else {
            nameLbl.text = "Hoi, succes vandaag!"
        }

        if defaults.bool(forKey: "has_notification") == true {
            alertBtn.setImage(UIImage(named: "Alert-Button-Active")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        if defaults.string(forKey: "user_photo") != nil {
            if let profilePhoto = defaults.string(forKey: "user_photo") {
                print("profilePhoto")
                print(profilePhoto)
                if let url = URL(string: profilePhoto) {
                    if let data = try? Data(contentsOf: url) {
                        if let image: UIImage = UIImage(data: data) {
                            profileImageView.image = image
                        }
                    }
                }
            }
        }
        
        nameLbl.font = UIFont(name: "Roboto", size: 22)
        nameLbl.textColor = UIColor.white
        let nameLabel = UIBarButtonItem()
        nameLabel.customView = nameLbl

        //Settings
        let settingsBtn = UIButton()
        settingsBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        settingsBtn.setImage(UIImage(named: "Settings-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        settingsBtn.addTarget(self, action: #selector(self.settingsPressed), for: .touchUpInside)
        let settingsButton = UIBarButtonItem()
        settingsButton.customView = settingsBtn

        //Classes
        let classesBtn = UIButton()
        classesBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        classesBtn.setImage(UIImage(named: "Classes-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        classesBtn.addTarget(self, action: #selector(self.classesPressed), for: .touchUpInside)
        let classesButton = UIBarButtonItem()
        classesButton.customView = classesBtn
        
        //Forms
        let formsBtn = UIButton()
        formsBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        formsBtn.setImage(UIImage(named: "Forms-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        formsBtn.addTarget(self, action: #selector(self.formsPressed), for: .touchUpInside)
        let formsButton = UIBarButtonItem()
        formsButton.customView = formsBtn
        
        //Search
        let searchBtn = UIButton()
        searchBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        searchBtn.setImage(UIImage(named: "Search-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtn.addTarget(self, action: #selector(self.searchPressed), for: .touchUpInside)
        let searchButton = UIBarButtonItem()
        searchButton.customView = searchBtn
        
        //Scan
        let scanBtn = UIButton()
        scanBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        scanBtn.setImage(UIImage(named: "Scan-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        scanBtn.addTarget(self, action: #selector(self.qrScanPressed), for: .touchUpInside)
        let scanButton = UIBarButtonItem()
        scanButton.customView = scanBtn
        
        //Award
        let awardBtn = UIButton()
        awardBtn.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        awardBtn.setImage(UIImage(named: "Award-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        awardBtn.addTarget(self, action: #selector(self.awardPressed), for: .touchUpInside)
        let awardButton = UIBarButtonItem()
        awardButton.customView = awardBtn
        
        //Buttons ios9 & 10
        
        //Space
        let spaceButtonOld = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceBetweenOld:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        spaceBetweenOld.width = -9.0
        let endSpaceOld:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        endSpaceOld.width = -19.0
        
        let profileSpaceOld:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        profileSpaceOld.width = 20.0
        let logoSpaceOld:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        logoSpaceOld.width = -96.0
        
        let nameSpaceOld:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        nameSpaceOld.width = 44.0
        
        //Logo
        let logoBtnOld = UIButton()
        logoBtnOld.frame = CGRect(x: 0, y: 0, width: 45, height: 50)
        logoBtnOld.setImage(UIImage(named: "MBS-Logo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        logoBtnOld.addTarget(self, action: #selector(self.logoPressed), for: .touchUpInside)
        logoBtnOld.isUserInteractionEnabled = false
        let logoButtonOld = UIBarButtonItem()
        logoButtonOld.customView = logoBtnOld
        
        //Profile
        let profileImageOld = UIImage(named: "No-Profile")
        let profileImageViewOld = UIImageView(image: profileImageOld)
        profileImageViewOld.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        profileImageViewOld.contentMode = .scaleAspectFit
        profileImageViewOld.clipsToBounds = true
        profileImageViewOld.layer.cornerRadius = profileImageViewOld.frame.width / 2
        let profileViewOld = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        profileViewOld.clipsToBounds = false
        profileViewOld.addSubview(profileImageViewOld)
        let profileImgOld = UIBarButtonItem(customView: profileViewOld)
        profileImgOld.customView = profileViewOld

        if defaults.string(forKey: "user_photo") != nil {
            if let profilePhoto = defaults.string(forKey: "user_photo") {
                print("profilePhoto")
                print(profilePhoto)
                if let url = URL(string: profilePhoto) {
                    if let data = try? Data(contentsOf: url) {
                        if let image: UIImage = UIImage(data: data) {
                            profileImageViewOld.image = image
                        }
                    }
                }
            }
        }
        
        //Alert
        let alertBtnOld = UIButton()
        alertBtnOld.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        alertBtnOld.setImage(UIImage(named: "Alert-Button")?.withRenderingMode(.alwaysOriginal), for: .normal) //@JASPER Alert-Button-Active indien nieuwe berichten
        alertBtnOld.addTarget(self, action: #selector(self.alertPressed), for: .touchUpInside)
        let alertButtonOld = UIBarButtonItem()
        alertButtonOld.customView = alertBtnOld
        
        //NameLabel
        let nameLblOld = UILabel()
        nameLblOld.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
        
        if defaults.string(forKey: "user_name") != nil {
            nameLblOld.text = "Hoi "+defaults.string(forKey: "user_name")!
        } else {
            nameLblOld.text = "Hoi, succes vandaag!"
        }
        
        nameLblOld.font = UIFont(name: "Roboto", size: 22)
        nameLblOld.textColor = UIColor.white
        let nameLabelOld = UIBarButtonItem()
        nameLabelOld.customView = nameLblOld
        
        //Settings
        let settingsBtnOld = UIButton()
        settingsBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        settingsBtnOld.setImage(UIImage(named: "Settings-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        settingsBtnOld.addTarget(self, action: #selector(self.settingsPressed), for: .touchUpInside)
        let settingsButtonOld = UIBarButtonItem()
        settingsButtonOld.customView = settingsBtnOld
        
        //Classes
        let classesBtnOld = UIButton()
        classesBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        classesBtnOld.setImage(UIImage(named: "Classes-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        classesBtnOld.addTarget(self, action: #selector(self.classesPressed), for: .touchUpInside)
        let classesButtonOld = UIBarButtonItem()
        classesButtonOld.customView = classesBtnOld
        
        //Forms
        let formsBtnOld = UIButton()
        formsBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        formsBtnOld.setImage(UIImage(named: "Forms-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        formsBtnOld.addTarget(self, action: #selector(self.formsPressed), for: .touchUpInside)
        let formsButtonOld = UIBarButtonItem()
        formsButtonOld.customView = formsBtnOld
        
        //Search
        let searchBtnOld = UIButton()
        searchBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        searchBtnOld.setImage(UIImage(named: "Search-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        searchBtnOld.addTarget(self, action: #selector(self.searchPressed), for: .touchUpInside)
        let searchButtonOld = UIBarButtonItem()
        searchButtonOld.customView = searchBtnOld
        
        //Scan
        let scanBtnOld = UIButton()
        scanBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        scanBtnOld.setImage(UIImage(named: "Scan-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        scanBtnOld.addTarget(self, action: #selector(self.qrScanPressed), for: .touchUpInside)
        let scanButtonOld = UIBarButtonItem()
        scanButtonOld.customView = scanBtnOld
        
        //Award
        let awardBtnOld = UIButton()
        awardBtnOld.frame = CGRect(x: 0, y: 0, width: 64, height: 60)
        awardBtnOld.setImage(UIImage(named: "Award-Bar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        awardBtnOld.addTarget(self, action: #selector(self.awardPressed), for: .touchUpInside)
        let awardButtonOld = UIBarButtonItem()
        awardButtonOld.customView = awardBtnOld
        
        if #available(iOS 11, *) {
            self.setToolbarItems([negativeFixedSpace, profileImg, logoImg, nameSpace, nameLabel, spaceButton, alertButton, spaceBetween, classesButton, spaceBetween, formsButton, spaceBetween, awardButton, spaceBetween, scanButton, spaceBetween, searchButton, spaceBetween, settingsButton, negativeFixedSpace], animated: false)
        } else {
            self.setToolbarItems([profileSpaceOld, profileImgOld, logoSpaceOld, logoButtonOld, nameSpaceOld, nameLabelOld, spaceButtonOld, alertButtonOld, spaceBetweenOld, classesButtonOld, spaceBetweenOld, formsButtonOld, spaceBetweenOld, awardButtonOld, spaceBetweenOld, scanButtonOld, spaceBetweenOld, searchButtonOld, spaceBetweenOld, settingsButtonOld, endSpaceOld], animated: false)
        }
        updateUserInterface()
//        self.toolbarItems?.remove(at: <#T##Int#>)
    }
    
    @objc func logoPressed(){
       
    }
    
    func profilePressed() {
    }
    
    @objc func settingsPressed() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String?
      
        let dialog = AZDialogViewController(title: "Instellingen", message: "Versie "+version!!)
        
        dialog.addAction(AZDialogAction(title: "Profielfoto veranderen") { (dialog) -> (Void) in
            let defaults = UserDefaults.standard
            defaults.set("profielfoto", forKey: "settings_action")
            
            let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "mySwiftCamStoryboardId")
            UIApplication.shared.keyWindow?.rootViewController = innerPage
            
        })
        
        dialog.addAction(AZDialogAction(title: "Uitloggen") { (dialog) -> (Void) in
            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: "user_name")
            defaults.removeObject(forKey: "user_token")
            
            let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
            UIApplication.shared.keyWindow?.rootViewController = innerPage
            
            dialog.dismiss()
        })
        
        dialog.imageHandler = { (imageView) in
            imageView.image = #imageLiteral(resourceName: "MBS-Logo")
            imageView.contentMode = .scaleAspectFill
            
            let defaults = UserDefaults.standard
            if let profilePhoto = defaults.string(forKey: "user_photo") {
                if let url = URL(string: profilePhoto) {
                    if let data = try? Data(contentsOf: url) {
                        if(data != nil) {
                            if(!(imageView.image != nil)) {
                                print("failure")
                            }
                            imageView.image = UIImage(data: data)!
                            
                        }
                    }
                }
            }
            
            return true //must return true, otherwise image won't show.
        }
                
        dialog.buttonStyle = { (button,height,position) in
            //button.setBackgroundImage(UIImage.imageWithColor(self.primaryColorDark), for: .highlighted)
            button.titleLabel!.font =  UIFont(name: "Roboto", size: 20)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            button.setTitleColor(UIColor.white, for: .highlighted)
            button.setTitleColor(UIColor.white, for: .normal)
            button.layer.cornerRadius = 6
            button.setBackgroundColor(color: UIColor(red: 48.0/255.0, green: 148.0/255.0, blue: 172.0/255.0, alpha: 1.0), forState: .highlighted)
            button.setBackgroundColor(color: UIColor(red: 48.0/255.0, green: 148.0/255.0, blue: 172.0/255.0, alpha: 1.0), forState: .normal)
            button.layer.masksToBounds = true
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 0
            
        }        
     
        dialog.cancelEnabled = true
        
        dialog.cancelButtonStyle = { (button,height) in
            button.tintColor = UIColor(red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0, alpha: 1.0)
            button.setTitle("Annuleren", for: [])
            button.titleLabel!.font =  UIFont(name: "Roboto", size: 16)
            return true //must return true, otherwise cancel button won't show.
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        mainStoryboard.instantiateViewController(withIdentifier: "loginBoard")
        
        
        
        
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String?
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = ["api_token": token]
            
            defaults.set("yea", forKey: "opened_settings")
            
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/version"
            Alamofire.request(URL, method: HTTPMethod.get, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                print(response.result)
               
                defaults.set("yea", forKey: "opened_settings")
                if let status = response.response?.statusCode {
                    switch(status)
                    {
                        case 200:
                            var _version = "" // response.response? //.value(forKey: "version")
                            
                            if response.result.value is NSNull {
                                return
                            }
                            let JSON = response.result.value as? NSDictionary
                            _version = JSON?["version"] as! String
                            
                            print(_version)
                            if(_version != nil) {
                                if(_version != currentVersion) {
                                    let alertMessage = "De versie die nu beschikbaar is in de AppStore is verie "+_version
                                    let alert = UIAlertController(title: "Er is een nieuwe versie van de app!", message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                                    
                                    
                                    let okBtn = UIAlertAction(title:"Vertel het aan je leerkracht" , style: .default, handler: {(_ action: UIAlertAction) -> Void in
                                        self.topMostController().present(dialog, animated: false, completion: nil)
                                    })
                                    alert.addAction(okBtn)
                                    self.topMostController().present(alert, animated: true, completion: nil)
                                } else {
                                    self.topMostController().present(dialog, animated: false, completion: nil)
                                }
                            } else {
                                self.topMostController().present(dialog, animated: false, completion: nil)
                            }
                        case 201:
                            print("example success")
                        default:
                            self.topMostController().present(dialog, animated: false, completion: nil)
                            print("error with response status: \(status)")
                    }
                }
               
               
            }
        }
        
//        topMostController().present(dialog, animated: false, completion: nil)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    @objc func classesPressed() {

        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is ClassesOverviewVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
        
    }
    
    @objc func formsPressed() {
        
        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "FormsStoryBoard")
        self.navigationController?.pushViewController(innerPage!, animated: true)
        
    }
    
    @objc func searchPressed() {
        
        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoryboardId")
        self.navigationController?.pushViewController(innerPage!, animated: true)
        
    }
    
    @objc func qrScanPressed() {

        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "qrCode") as! QRCodeVC
        innerPage.delegate = self
        innerPage.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(innerPage, animated: true, completion: nil)
    }
    
    @objc func awardPressed() {
        
        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "AwardStoryBoardID")
        self.navigationController?.pushViewController(innerPage!, animated: true)
        
    }
    
    @objc func alertPressed() {
        
        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "ReviewsStoryBoardID")
        self.navigationController?.pushViewController(innerPage!, animated: true)
        
    }
    
    func updateUserInterface() {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available via MainNavVc!")
            SCLAlertView().showError("Daar ging wat mis!", subTitle: "De internetverbinding is offline")
        }
    }
    
    
    
    
}
import AlamofireObjectMapper
import Alamofire

extension UIViewController: QRCodeVCDelegate {
    @objc func QRScanResult (_ qrCode: String) {
        
    }
    func didScanResult(_ result: QRCodeReaderResult) {
        
        print("DISCANRESULT")
        QRScanResult(result.value)
        print(result.value)
        
        let qr = result.value
        let defaults = UserDefaults.standard
        
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = ["api_token": token]
            
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/qr-goal/"+qr+"?api_token="+token
            print(URL)
            
            Alamofire.request(URL, method: HTTPMethod.post, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                if response.result.isSuccess {
//                    print(response.data.id)
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        print(JSON)
                        
                        print(JSON.value(forKey: "description")!)
                        
                        let defaults = UserDefaults.standard
                        defaults.set(JSON.value(forKey: "description"), forKey: "goal_description")
                        defaults.set(JSON.value(forKey: "id"), forKey: "goal_id")
                        defaults.set(JSON.value(forKey: "objective_niveau"), forKey: "objective_niveau")
                        defaults.set(JSON.value(forKey: "category_icon"), forKey: "category_icon")
                        defaults.set("hide_back_btn", forKey: "hide_back_btn")

                        let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "learningObjectStoryBoardId")
                        self.navigationController?.pushViewController(innerPage!, animated: true)
                    }
                } else {
                    // ALERT...? Hier gaan dingen fout.
                }
            }
            
            
            Alamofire.request(URL, parameters:parameters).responseObject { (response: DataResponse<CategoryResponse>) in
                
              
            }
        }

    }
}

