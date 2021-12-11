//
//  AwardVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 21-08-18.
//  Copyright © 2018 Wndworks. All rights reserved.
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


class AwardVC: UIViewController {
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var itemSilver: UIView!
    @IBOutlet weak var topBarSilver: UIView!
    @IBOutlet weak var imageFrameSilver: UIView!
    @IBOutlet weak var imageSilver: UIImageView!
    
    @IBOutlet weak var itemGold: UIView!
    @IBOutlet weak var topBarGold: UIView!
    @IBOutlet weak var imageFrameGold: UIView!
    @IBOutlet weak var imageGold: UIImageView!
    
    @IBOutlet weak var itemBronze: UIView!
    @IBOutlet weak var topBarBronze: UIView!
    @IBOutlet weak var imageFrameBronze: UIView!
    @IBOutlet weak var imageBronze: UIImageView!
    
    @IBOutlet weak var silverReason: UILabel!
    @IBOutlet weak var goldReason: UILabel!
    @IBOutlet weak var bronzeReason: UILabel!
    @IBOutlet weak var silverProudTitle: UILabel!
    @IBOutlet weak var goldProudTitle: UILabel!
    @IBOutlet weak var bronzeProudTitle: UILabel!
    
    @IBOutlet weak var podiumItems: UIView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //Constraint outlets
    @IBOutlet weak var trailingConstraintSilver: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraintBronze: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintSilver: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintGold: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintBronze: NSLayoutConstraint!
    
    var gold_description: String?
    var gold_id: Int?
    var gold_icon: String?
    
    var silver_description: String?
    var silver_id: Int?
    var silver_icon: String?
    
    var bronze_description: String?
    var bronze_id: Int?
    var bronze_icon: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //ItemSilver style
        
            //topBar
            topBarSilver.layer.cornerRadius = 3
        
            //imageFrame
            imageFrameSilver.layer.cornerRadius = imageFrameSilver.frame.width/2
            imageFrameSilver.layer.masksToBounds = true
            imageFrameSilver.clipsToBounds = true
        
            //image
            imageSilver.layer.cornerRadius = imageSilver.frame.width/2
            imageSilver.layer.masksToBounds = true
            imageSilver.clipsToBounds = true
        
        //ItemGold style
        
            //topBar
            topBarGold.layer.cornerRadius = 3
        
            //imageFrame
            imageFrameGold.layer.cornerRadius = imageFrameGold.frame.width/2
            imageFrameGold.layer.masksToBounds = true
            imageFrameGold.clipsToBounds = true
        
            //image
            imageGold.layer.cornerRadius = imageGold.frame.width/2
            imageGold.layer.masksToBounds = true
            imageGold.clipsToBounds = true
        
        //ItemBronze style
        
            //topBar
            topBarBronze.layer.cornerRadius = 3
        
            //imageFrame
            imageFrameBronze.layer.cornerRadius = imageFrameBronze.frame.width/2
            imageFrameBronze.layer.masksToBounds = true
            imageFrameBronze.clipsToBounds = true
        
            //image
            imageBronze.layer.cornerRadius = imageBronze.frame.width/2
            imageBronze.layer.masksToBounds = true
            imageBronze.clipsToBounds = true
        
        //Add toolbar
        addGeneralToolbarItems()
        
        silverReason.isHidden = true
        goldReason.isHidden = true
        bronzeReason.isHidden = true
        silverProudTitle.isHidden = true
        goldProudTitle.isHidden = true
        bronzeProudTitle.isHidden = true
        
        podiumItems.isHidden = true
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = ["api_token": token]
            let podiumURL = "https://beheer.mijnbewijsstukken.nl/api/swift/podium"
            print(podiumURL)
            print(token)
            Alamofire.request(podiumURL, parameters:parameters).responseObject { (response: DataResponse<PodiumResponse>) in
                
                let PodiumResponse = response.result.value
                if((PodiumResponse?.gold_document) != nil){
                    self.goldReason.isHidden = false
                    self.goldProudTitle.isHidden = false
                    self.goldReason.text = PodiumResponse?.gold_reason
                    
                    
                    self.gold_description = PodiumResponse?.gold_description
                    self.gold_id = PodiumResponse?.gold_id
                    self.gold_icon = PodiumResponse?.gold_icon
                    
                  


                    if(PodiumResponse?.gold_document_type == "video") {
                        print("Video")
                        let urlGold = URL(string: PodiumResponse?.gold_document as! String + "&thumb=true")
                        if((urlGold) != nil) {
                            if let thumbnailImage = self.getThumbnailImage(forUrl: urlGold!) {
                                self.imageGold.image = thumbnailImage
                            }
                        }
                    } else if(PodiumResponse?.gold_document_type == "audio") {
                        print("Audio")
                        let urlGold = URL(string: PodiumResponse?.gold_document as! String + "&thumb=true")
                        if((urlGold) != nil) {
                            self.imageGold.image = UIImage(named: "microphone")
                        }
                    } else {
                        if((PodiumResponse?.gold_document) != nil){
                            let urlGold = URL(string: PodiumResponse?.gold_document as! String)!
                            if((urlGold) != nil) {
                                let data = try? Data(contentsOf: urlGold)
                                let image: UIImage = UIImage(data: data!)!
                                self.imageGold.image = image
                            }
                        }
                    }
                }

                //ZILVER
                if((PodiumResponse?.silver_document) != nil){
                    self.silverReason.isHidden = false
                    self.silverProudTitle.isHidden = false
                    self.silverReason.text = PodiumResponse?.silver_reason
                    
                    self.silver_description = PodiumResponse?.silver_description
                    self.silver_id = PodiumResponse?.silver_id
                    self.silver_icon = PodiumResponse?.silver_icon
                    
                    if(PodiumResponse?.silver_document_type == "video") {
                        print("Video")
                        let urlSilver = URL(string: PodiumResponse?.silver_document as! String + "&thumb=true")
                        if((urlSilver) != nil) {
                            if let thumbnailImage = self.getThumbnailImage(forUrl: urlSilver!) {
                                self.imageSilver.image = thumbnailImage
                            }
                        }
                    } else if(PodiumResponse?.silver_document_type == "audio") {
                        print("Audio")
                        let urlGold = URL(string: PodiumResponse?.gold_document as! String + "&thumb=true")
                        if((urlGold) != nil) {
                            self.imageSilver.image = UIImage(named: "microphone")
                        }
                    } else {
                        if((PodiumResponse?.silver_document) != nil){
                            let urlSilver = URL(string: PodiumResponse?.silver_document as! String)!
                            if((urlSilver) != nil) {
                                let data = try? Data(contentsOf: urlSilver)
                                let image: UIImage = UIImage(data: data!)!
                                self.imageSilver.image = image
                            }
                        }
                    }
                }
                
                
                //BRONS
                if((PodiumResponse?.bronze_document) != nil){
                    self.bronzeReason.isHidden = false
                    self.bronzeProudTitle.isHidden = false
                    self.bronzeReason.text = PodiumResponse?.bronze_reason
                    
                    self.bronze_description = PodiumResponse?.bronze_description
                    self.bronze_id = PodiumResponse?.bronze_id
                    self.bronze_icon = PodiumResponse?.bronze_icon
                    
                    
                    if(PodiumResponse?.bronze_document_type == "video") {
                        print("Video")
                        let urlBronze = URL(string: PodiumResponse?.bronze_document as! String + "&thumb=true")
                        if((urlBronze) != nil) {
                            if let thumbnailImage = self.getThumbnailImage(forUrl: urlBronze!) {
                                self.imageBronze.image = thumbnailImage
                            }
                        }
                    } else if(PodiumResponse?.bronze_document_type == "audio") {
                        print("Audio")
                        let urlGold = URL(string: PodiumResponse?.gold_document as! String + "&thumb=true")
                        if((urlGold) != nil) {
                            self.imageBronze.image = UIImage(named: "microphone")
                        }
                    } else {
                        if((PodiumResponse?.bronze_document) != nil){
                            let urlBronze = URL(string: PodiumResponse?.bronze_document as! String)!
                            if((urlBronze) != nil) {
                                let data = try? Data(contentsOf: urlBronze)
                                let image: UIImage = UIImage(data: data!)!
                                self.imageBronze.image = image
                            }
                        }
                    }
                }
                self.podiumItems.isHidden = false
                self.activity.isHidden = true
                
            }
        }
        
        //Back button
        backButton.addTarget(self, action: #selector(self.popBack), for: UIControl.Event.touchUpInside)
        
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
        
    }
    
    @IBAction func clickSilver(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(self.silver_description, forKey: "goal_description")
        defaults.set(self.silver_id, forKey: "goal_id")
        defaults.set(self.silver_icon, forKey: "category_icon")
        defaults.set("hide_back_btn", forKey: "hide_back_btn")
        defaults.set("from_podium", forKey: "from_podium")
        
    }
    
    @IBAction func clickGold(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        defaults.set(self.gold_description, forKey: "goal_description")
        defaults.set(self.gold_id, forKey: "goal_id")
        defaults.set(self.gold_icon, forKey: "category_icon")
        defaults.set("hide_back_btn", forKey: "hide_back_btn")
        defaults.set("from_podium", forKey: "from_podium")
    }
    
    
    @IBAction func clickBronze(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        defaults.set(self.bronze_description, forKey: "goal_description")
        defaults.set(self.bronze_id, forKey: "goal_id")
        defaults.set(self.bronze_icon, forKey: "category_icon")
        defaults.set("hide_back_btn", forKey: "hide_back_btn")
        defaults.set("from_podium", forKey: "from_podium")
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "podiumSilverSegue" {
                if self.silver_id == nil {
                    return false
                }
            }
            if ident == "podiumGoldSegue" {
                if self.gold_id == nil {
                    return false
                }
            }
            if ident == "podiumBronzeSegue" {
                if self.bronze_id == nil {
                    return false
                }
            }
        }
        return true
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //Change sizes on landscape mode
        if UIApplication.shared.statusBarOrientation.isLandscape {
            
            trailingConstraintSilver.constant = 40
            leadingConstraintBronze.constant = 40
            widthConstraintSilver.constant = 240
            widthConstraintGold.constant = 240
            widthConstraintBronze.constant = 240
            
        } else{ //Change sizes on portrait mode
            
            trailingConstraintSilver.constant = 14
            leadingConstraintBronze.constant = 14
            widthConstraintSilver.constant = 234
            widthConstraintGold.constant = 234
            widthConstraintBronze.constant = 234
            
        }
        
    }
    
    //Back button
    @objc func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is LearningObjectVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LearningObjectVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
            
        }
    }
    
}


import ObjectMapper

class PodiumResponse: Mappable {
    var gold_reason: String?
    var gold_document: String?
    var gold_document_type: String?
    var silver_reason: String?
    var silver_document: String?
    var silver_document_type: String?
    var bronze_reason: String?
    var bronze_document: String?
    var bronze_document_type: String?
    
    var gold_description: String?
    var gold_id: Int?
    var gold_icon: String?
    
    var silver_description: String?
    var silver_id: Int?
    var silver_icon: String?
    
    var bronze_description: String?
    var bronze_id: Int?
    var bronze_icon: String?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        gold_reason <- map["gold_reason"]
        silver_reason <- map["silver_reason"]
        bronze_reason <- map["bronze_reason"]
        
        gold_document <- map["gold.document"]
        silver_document <- map["silver.document"]
        bronze_document <- map["bronze.document"]
        
        gold_document_type <- map["gold.type"]
        silver_document_type <- map["silver.type"]
        bronze_document_type <- map["bronze.type"]
        
        gold_description <- map["gold.goal.description"]
        gold_id <- map["gold.goal.id"]
        gold_icon <- map["gold.goal.objective.category.icon.name"]
        
        silver_description <- map["silver.goal.description"]
        silver_id <- map["silver.goal.id"]
        silver_icon <- map["silver.goal.objective.category.icon.name"]
        
        bronze_description <- map["bronze.goal.description"]
        bronze_id <- map["bronze.goal.id"]
        bronze_icon <- map["bronze.goal.objective.category.icon.name"]
    }
}
