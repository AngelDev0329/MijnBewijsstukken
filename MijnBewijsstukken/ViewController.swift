//
//  ViewController.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 24-01-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import AlamofireObjectMapper
import Alamofire
import Foundation
import SCLAlertView

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {

    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        // was true
        return true
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var qrCodeLoginButton: UIButton!
    
    var loginSuccess = false
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
//            $0.cancelButtonTitle = "Annuleren"
//            let readerView = QRCodeReaderContainer(displayable: YourCustomView())
//            $0.readerView = readerView

            
//            // Configure the view controller (optional)
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton       = true
            $0.cancelButtonTitle        = "Annuleren"
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available View!")
//            SCLAlertView().showError("Geen internet", subTitle: "We kunnen de App niet starten, omdat er geen werkende WiFi connectie is.")
        }
        
        self.activity.isHidden = true
        
        //Textfield styles
        nameField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        nameField.layer.cornerRadius = 3
        passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0)
        passwordField.layer.cornerRadius = 3
        
        //Buttons styles
        yellowButton.layer.cornerRadius = 3
        yellowButton.backgroundColor =  UIColor(red: 248.0/255.0, green: 208.0/255.0, blue: 37/255.0, alpha: 1.0)
        
        qrCodeLoginButton.layer.cornerRadius = 3
        qrCodeLoginButton.backgroundColor =  UIColor(red: 248.0/255.0, green: 208.0/255.0, blue: 37/255.0, alpha: 1.0)
        
        //Center loginFrame when keyboard opens
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.nameField.keyboardType = UIKeyboardType.emailAddress
      
    }
    
    
    //Center loginFrame when keyboard opens
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height - 150 //minus half of the content height
            }
        }
    }
    
    //Center loginFrame when keyboard hides
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height - 150 //minus half of the content height
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "login" {
                if loginSuccess != true {
                    return false
                }
            }
            if ident == "login-qr" {
                if loginSuccess != true {
                    return false
                }
            }
        }
        return true
    }
    
    @IBAction func Test(_ sender: Any) {
    }
    
    @IBAction func NameValueInput(_ sender: UITextField) {
        //
    }
    
    @IBAction func yellowButtonPressed(_ sender: Any) {
        self.activity.isHidden = false
        self.activity.startAnimating()
        
        let user = nameField.text
        let password = passwordField.text
        
//        let defaults = UserDefaults.standard
        //        defaults.removeObject(forKey: "user_name")
        //        defaults.removeObject(forKey: "user_token")
        
        yellowButton.backgroundColor = UIColor(red: 29.0/255.0, green: 120.0/255.0, blue: 142/255.0, alpha: 1.0)
        let parameters: Parameters = ["email": user!, "password": password!]
        
        let URL = "https://beheer.mijnbewijsstukken.nl/api/authenticate"
        // .authenticate(user: user!, password: password!)
        Alamofire.request(URL, method: .post, parameters: parameters).responseObject { (response: DataResponse<UserResponse>) in
            switch response.result {
            case .success:
                let userResponse = response.result.value
                //                    debugPrint(response.result.value?)
                print((userResponse?.name)!)
                self.loginSuccess = true
                print("LoginSuccess")
                let defaults = UserDefaults.standard
                defaults.set((userResponse?.name)!, forKey: "user_name")
                defaults.set((userResponse?.token)!, forKey: "user_token")
                defaults.set((userResponse?.photo)!, forKey: "user_photo")
                defaults.set((userResponse?.has_notification)!, forKey: "has_notification")
                
                self.yellowButton.sendActions(for: .touchUpInside)
                
            case .failure:
                print("error!!!!")
                self.yellowButton.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
                
            }
            print(response)
            debugPrint(response.result)
            if let httpStatusCode = response.response?.statusCode {
                print("httpStatusCode")
                print(httpStatusCode)
                switch(httpStatusCode) {
                case 418:
                    let alert = UIAlertController(title: "Oeps", message: "Je probeert in te loggen met een leerkracht account, maar de app is alleen door leerlingen te gebruiken. Als leerkracht kan je inloggen op het beheer via https://beheer.mijnbewijsstukken.nl.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.yellowButton.backgroundColor = UIColor(red: 29.0/255.0, green: 120.0/255.0, blue: 142/255.0, alpha: 1.0)
                    self.nameField.text = ""
                    self.passwordField.text = ""
                    break
                default:
                    print("CODE")
                    break
                    //
                }
            }
            self.activity.stopAnimating()
        }
        
    }
    
    @IBAction func yellowButtonReleased(_ sender: Any) {
        yellowButton.backgroundColor =  UIColor(red: 248.0/255.0, green: 208.0/255.0, blue: 37/255.0, alpha: 1.0)
    }
    
    @IBOutlet weak var email_login_form_view: UIView!
    @IBOutlet weak var qr_login_form_view: UIView!
    
    @IBAction func showEmailForm(_ sender: Any) {
        self.email_login_form_view.isHidden = false
        self.qr_login_form_view.isHidden = true
    }
    
    @IBAction func gotoSwiftCamAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "mySwiftCamStoryboardId")
        self.present(controller, animated: false, completion: nil)
      //  self.performSegue(withIdentifier: "gotoSwiftCam", sender: nil)
    }
    
    @IBAction func scanQRAction(_ sender: Any) {

        readerVC.delegate = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            print(result)
        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true)
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        
        var qr = result.value
        
        let fullQR: String = qr
        let fullQrArr = fullQR.components(separatedBy: "_")
        if fullQR.range(of:"_") != nil {
            qr = fullQrArr[1]
        } else {
            qr = fullQrArr[0]
        }
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available via MainNavVc!")
            SCLAlertView().showError("Daar ging wat mis!", subTitle: "De internetverbinding is offline")
        }

        let parameters: Parameters = ["api_token": qr]
        let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/qr"
        Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<UserResponse>) in
            switch response.result {
            case .success:
                let userResponse = response.result.value
                self.loginSuccess = true
                print("LoginSuccess")
                let defaults = UserDefaults.standard
                defaults.set((userResponse?.name)!, forKey: "user_name")
                defaults.set((userResponse?.token)!, forKey: "user_token")
                defaults.set((userResponse?.photo)!, forKey: "user_photo")
                defaults.set((userResponse?.has_notification)!, forKey: "has_notification")
                self.yellowButton.backgroundColor = UIColor(red: 55.0/255.0, green: 200.0/255.0, blue: 0.0/255.0, alpha: 1.0)
                
                self.yellowButton.sendActions(for: .touchUpInside)
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let innerPage: MainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "mainBoardId") as! MainNavigationVC
                self.present(innerPage, animated: true, completion: nil)

            case .failure:
                print("No QR")
                self.yellowButton.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
                self.yellowButton.sendActions(for: .touchUpInside)
                self.yellowButton.sendActions(for: .touchDown)
                
            }
            print(response.result)
            self.activity.stopAnimating()
        }
        
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
//        print("VieWillAppear")
        super.viewWillAppear(animated)
//        if Reachability.isConnectedToNetwork(){
//            print("Internet Connection Available!")
//        }else{
//            print("Internet Connection not Available via ViewVC!")
//            self.yellowButton.backgroundColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
//            self.yellowButton.setTitle("De internetverbinding is offline", for: .normal)
//
////            let alert = UIAlertController(title: "De internetverbinding is offline", message: "We kunnen de App daardoor niet starten...", preferredStyle: UIAlertControllerStyle.alert)
////            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
////            self.present(alert, animated: true, completion: nil)
//            print("YEA")
//        }
    }
}

import ObjectMapper

class UserResponse: Mappable {
    var name: String?
    var email: String?
    var lastname: String?
    var photo: String?
    var token: String?
    var has_notification: Bool?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        lastname <- map["lastname"]
        email <- map["email"]
        photo <- map["picture"]
        token <- map["api_token"]
        has_notification <- map["has_notification"]
    }
}

