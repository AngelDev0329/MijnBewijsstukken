//
//  FormsVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 19-03-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import SwiftyCam
import AlamofireObjectMapper
import Alamofire

class FormsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var FormsCollectionView: UICollectionView!
    
    var forms: [Any] = []
    var formTitles: [Any] = []
    var formSlugs: [Any] = []
    var formFinished: [Bool] = []
    var reportLinks: [Any] = []
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var backBtn: UIButton!
    var isReport = false
    
    @IBOutlet weak var starUncompletedForms: UIButton!
    @IBOutlet weak var starCompletedForms: UIButton!
    @IBOutlet var mainTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Add toolbar
        addGeneralToolbarItems()
        
        self.FormsCollectionView.delegate = self
        self.FormsCollectionView.dataSource = self
        
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
        FormsCollectionView.collectionViewLayout = layout
//        self.loadThemes()
        self.backBtn.isHidden = true
        
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
    
    
    @IBAction func goBack(_ sender: Any) {
        self.isReport = false
        self.loadThemes()
    }
    
    func resetStates() {
        self.starUncompletedForms.isHidden = false
        self.starCompletedForms.isHidden = false
    }
    
    @IBAction func uncompletedForms(_ sender: Any) {
        resetStates()
        self.starCompletedForms.isSelected = false
        if(self.starUncompletedForms.isSelected) {
            self.starUncompletedForms.isSelected = false
            
        } else {
            self.starUncompletedForms.isSelected = true
            self.starCompletedForms.isSelected = false
        }
        let defaults = UserDefaults.standard
        if let slug = defaults.string(forKey: "theme_slug")
        {
            self.loadReport(slug: slug, what: "uncompleted")
        }
    }
    
    @IBAction func completedForms(_ sender: Any) {
        resetStates()
        self.starUncompletedForms.isSelected = false
        if(self.starCompletedForms.isSelected) {
            self.starCompletedForms.isSelected = false
        } else {
            self.starCompletedForms.isSelected = true
        }
        let defaults = UserDefaults.standard
        if let slug = defaults.string(forKey: "theme_slug")
        {
            self.loadReport(slug: slug, what: "completed")
        }
    }
    
    @IBAction func clickThemeBtn(_ sender: UIButton) {
        print("you pressed")
        let hitPoint = sender.convert(CGPoint.zero, to: self.FormsCollectionView)
        if let indexPath = self.FormsCollectionView.indexPathForItem(at: hitPoint) {
            print(indexPath)
//            let defaults = UserDefaults.standard
//            defaults.set(self.formSlugs[indexPath.row], forKey: "theme_slug")
            if(self.isReport == false) {
                self.mainTitle.text = self.formTitles[indexPath.row] as? String
                self.loadReport(slug: (self.formSlugs[indexPath.row] as? String)!, what: "all")
            } else {
                let defaults = UserDefaults.standard
                defaults.set(self.reportLinks[indexPath.row] as? String, forKey: "questions_link")
                defaults.set(self.formTitles[indexPath.row] as? String, forKey: "report_title")
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("VIEWWILLAPEAR")
        let defaults = UserDefaults.standard
        if((defaults.string(forKey: "showed_questions")) != nil) {
            self.starUncompletedForms.isSelected = false
            self.starCompletedForms.isSelected = false
            defaults.set(nil, forKey: "showed_questions")
        }
        if(!self.isReport) {
            self.loadThemes();
        }
        else if let slug = defaults.string(forKey: "theme_slug") {
            self.loadReport(slug: slug, what: "all")
        } else {
            self.loadThemes();
        }
    }
    
    
    func loadThemes()
    {
        print("loadThemes")
        self.forms = []
        self.formTitles = []
        self.formSlugs = []
        self.reportLinks = []
        self.formFinished = []
        self.mainTitle.text = "Formulieren"
        self.isReport = false
        self.backBtn.isHidden = true
        resetStates()
        self.starUncompletedForms.isHidden = true
        self.starCompletedForms.isHidden = true
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.activity.startAnimating()
            let parameters: Parameters = ["api_token": token]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/themes"
            Alamofire.request(URL, parameters: parameters).responseArray { (response: DataResponse<[Theme]>) in
                let themesArray = response.result.value
                if let themesArray = themesArray {
                    for theme in themesArray {
                        self.forms.append(theme.icon!)
                        self.formFinished.append(false)
                        self.formTitles.append(theme.name!)
                        self.formSlugs.append(theme.slug!)
                    }
                    self.isReport = false
                    self.backBtn.isHidden = !self.isReport
                }
                self.FormsCollectionView.reloadData()
                self.activity.stopAnimating()
            }
        }
        
        
    }
    
    func loadReport(slug: String, what: String)
    {
        print("loadReport:"+what)
//        self.starUncompletedForms.isHidden = true
//        self.starCompletedForms.isHidden = true
        self.forms = []
        self.formTitles = []
        self.formFinished = []
        self.formSlugs = []
        self.reportLinks = []
        self.backBtn.isHidden = false
//        self.isReport = true
        
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.activity.startAnimating()
            let parameters: Parameters = ["api_token": token]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/themes/"+slug
            print(URL)
            self.isReport = true
            
            Alamofire.request(URL, parameters: parameters).responseArray { (response: DataResponse<[Report]>) in
                let reportsArray = response.result.value
                debugPrint(response.result.value as Any)
                if let reportsArray = reportsArray {
                    for report in reportsArray {
                        if(self.starUncompletedForms.isSelected) {
                            print("starUncompletedForms isSelected")
                            if(report.finished != true) {
                                self.setContentReport(report: report)
                            }
                        }
                        else if(self.starCompletedForms.isSelected) {
                            print("starCompletedForms isSelected")
                            if(report.finished!) {
                                self.setContentReport(report: report)
                            }
                        } else {
                            print("Normal Report Shower")
                            self.setContentReport(report: report)
                        }
                        if(report.finished!) {
                            self.starUncompletedForms.isHidden = false
                            self.starCompletedForms.isHidden = false
                        }
                        defaults.set(report.slug!, forKey: "report_slug")
                        defaults.set(report.theme_slug!, forKey: "theme_slug")
                        defaults.set(report.id!, forKey: "report_id")
                        defaults.set(nil, forKey: "goal_id")
                    }
                }
                self.FormsCollectionView.reloadData()
                self.activity.stopAnimating()
                
            }
        }
    }
    
    func setContentReport(report: Report) {
        self.forms.append(report.icon!)
        self.formTitles.append(report.name!)
        self.formFinished.append(report.finished!)
        self.formSlugs.append(report.slug!)
        self.reportLinks.append(report.questions_link!)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "questionsSegue" {
                if(self.reportLinks.count <= 0) {
                    return false
                }
            }
        }
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = FormsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
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
    
    

    //Forms count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Forms count:")
        print(forms.count)
        return forms.count
    }
    
    //Create cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "class", for: indexPath) as! FormsCell
 
        cell.formImage.image = UIImage(named: forms[indexPath.row] as! String)
        cell.formLabel.text = formTitles[indexPath.row] as? String
        if(formFinished.count > 0) {
            cell.formFinished.isHidden = !formFinished[indexPath.row] as! Bool
        }
    
        return cell
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            self.isReport = false
            self.loadThemes()
            
            
            /*Transition*/
            
            /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "FormsStoryBoard") as! FormsVC
            navigationController?.pushViewController(vc, animated: true)*/
            
        }
    }
}

import ObjectMapper

class ThemesResponse: Mappable {
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

class Theme: Mappable {
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

class Report: Mappable {
    var id: Int?
    var name: String?
    var slug: String?
    var icon: String?
    var theme_slug: String?
    var questions_link: String?
    var finished: Bool?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        slug <- map["slug"]
        icon <- map["icon.name"]
        theme_slug <- map["theme.slug"]
        questions_link <- map["link.questions"]
        finished <- map["finished"]
    }
}



