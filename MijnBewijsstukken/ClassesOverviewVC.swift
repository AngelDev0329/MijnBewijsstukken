//
//  ClassesOverviewViewController.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 03-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//


import UIKit
import SwiftyCam
import AlamofireObjectMapper
import Alamofire
import QRCodeReader
import  SCLAlertView
class ClassesOverviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var ClassesCollectionView: UICollectionView!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //Set class Categories
    var images: [Any] = []
    var names: [Any] = []
    var slugs: [Any] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add toolbar
        addGeneralToolbarItems()
        
        updateUserInterface()
        
        self.ClassesCollectionView.delegate = self
        self.ClassesCollectionView.dataSource = self
        
        //Set collection sizes
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let containerHeight = screenHeight - 250 // Toptitle 130 + Toolbar 60 + inset below
        let containerWidth = screenWidth - 80 // Inset below
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 40, bottom: 40, right: 40)
        layout.itemSize = CGSize(width: containerWidth*0.25, height: containerHeight / 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        ClassesCollectionView.collectionViewLayout = layout
        
        let defaults = UserDefaults.standard
        defaults.set("rekenen", forKey: "category_slug")
        defaults.removeObject(forKey: "opened_settings")
        if Reachability.isConnectedToNetwork(){
            
        } else {
            return 
        }
        // Data ophalen
        if let token = defaults.string(forKey: "user_token")
        {
            self.activity.startAnimating()
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
            let systemVersion = UIDevice.current.systemVersion as String
            
            let parameters: Parameters = ["api_token": token, "version": currentVersion, "ios": systemVersion ]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/categories"

            Alamofire.request(URL, parameters: parameters).responseArray { (response: DataResponse<[Category]>) in
                switch response.result {
                case .success:
                    let categoriesArray = response.result.value
                    if let categoriesArray = categoriesArray {
                        for category in categoriesArray {
                            //                    print(category.name!)
                            self.images.append(category.icon!)
                            self.names.append(category.name!)
                            self.slugs.append(category.slug!)
                        }
                    }
                    
                    
                   
                    
                case .failure:
                    print("error!!!!")
                    // MBS-324
                    print("MBS-324")
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "user_name")
                    defaults.removeObject(forKey: "user_token")
                    
                    let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "loginBoard")
                    UIApplication.shared.keyWindow?.rootViewController = innerPage
                    
                }
//                let categoriesArray = response.result.value
//                if let categoriesArray = categoriesArray {
//                    for category in categoriesArray {
//    //                    print(category.name!)
//                        self.images.append(category.icon!)
//                        self.names.append(category.name!)
//                        self.slugs.append(category.slug!)
//                    }
//                }
                self.ClassesCollectionView.reloadData()
                self.activity.stopAnimating()
                
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("VieWillAppear")
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        defaults.set("rekenen", forKey: "category_slug")
        defaults.removeObject(forKey: "opened_settings")
        
        // Data ophalen
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = ["api_token": token]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/qr"
            Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<UserResponse>) in
                switch response.result {
                case .success:
                    let userResponse = response.result.value
                    print("CheckUserSettings")
                    let defaults = UserDefaults.standard
                    defaults.set((userResponse?.name)!, forKey: "user_name")
                    defaults.set((userResponse?.token)!, forKey: "user_token")
                    defaults.set((userResponse?.photo)!, forKey: "user_photo")
                    defaults.set((userResponse?.has_notification)!, forKey: "has_notification")
                    self.addGeneralToolbarItems()
                    
                case .failure:
                    print("No User")
                }
            }
        }
    }
    
    override func QRScanResult(_ qrCode: String) {
     print(qrCode)
    }
//    func didScanResult(_ result: QRCodeReaderResult) {
//        
//    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = ClassesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let containerHeight = screenHeight - 250 // Toptitle 130 + Toolbar 60 + inset below
        let containerWidth = screenWidth - 80 // Inset below
        
        if UIApplication.shared.statusBarOrientation.isLandscape {
            flowLayout.itemSize = CGSize(width: containerWidth*0.25, height: containerHeight / 2)
        } else {
            flowLayout.itemSize = CGSize(width: containerWidth*0.33, height: containerHeight / 3)
        }
        
        flowLayout.invalidateLayout()
    }
    
    //Images count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(images.count)
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "class", for: indexPath) as! ClassesCollectionCell
        // Set categories
        if(images.count > 0) {
            cell.ClassImageView.image = UIImage(named: images[indexPath.row] as! String)
            cell.VakNaam.text = names[indexPath.row] as? String
        }
        return cell
    }
    
    @IBAction func clickingCateogry(_ sender: UIButton) {
        print("you pressed")
        print(sender)
        // https://stackoverflow.com/questions/45717235/get-index-of-clicked-uicollectionviewcell-in-uicollectionview-swift
        let hitPoint = sender.convert(CGPoint.zero, to: self.ClassesCollectionView)
        if let indexPath = self.ClassesCollectionView.indexPathForItem(at: hitPoint) {
            print(indexPath)
            let defaults = UserDefaults.standard
            defaults.set(self.slugs[indexPath.row], forKey: "category_slug")
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }
    
//    override var shouldAutorotate: Bool {
//        return true;
//    }
    
    
}


import ObjectMapper

class CategoriesResponse: Mappable {
    var name: String?
    var slug: String?
    var icon: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        slug <- map["slug"]
        icon <- map["icon.name"]
    }
}

class Category: Mappable {
    var name: String?
    var slug: String?
    var icon: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        slug <- map["slug"]
        icon <- map["icon.name"]
    }
}




