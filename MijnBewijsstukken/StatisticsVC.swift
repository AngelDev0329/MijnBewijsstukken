//
//  StatisticsVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 16-10-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import Floaty
import MBCircularProgressBar
import AlamofireObjectMapper
import Alamofire

class StatisticsVC: UIViewController{
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var progressBarView: MBCircularProgressBarView!
    @IBOutlet weak var completedStar: DOFavoriteButton!
    @IBOutlet weak var unCompletedStar: DOFavoriteButton!
    @IBOutlet weak var totalStar: DOFavoriteButton!
    @IBOutlet weak var timelineBar: UIProgressView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var currentLevel: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var totalGoals: UILabel!
    @IBOutlet weak var completedGoals: UILabel!
    @IBOutlet weak var uncompletedGoals: UILabel!
//    @IBOutlet weak var progressBarView: MBCircularProgressBarView!
    @IBOutlet weak var schoolMonths: UILabel!
    @IBOutlet weak var currentNiveau: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add toolbar
        addGeneralToolbarItems()
        
        //Make the label of the current level a circle (top right in title)
        currentLevel.layer.masksToBounds = true
        currentLevel.layer.cornerRadius = currentLevel.frame.width / 2
        
        let defaults = UserDefaults.standard
        if let thermometer_id = defaults.string(forKey: "thermometer_id")
        {
            if let token = defaults.string(forKey: "user_token")
            {
                self.getThermometer(token: token, thermometer_id: thermometer_id)
            }
        }
        
        if let current_niveau = defaults.string(forKey: "current_niveau")
        {
            self.currentLevel.text = current_niveau
        }
        if let category_icon = defaults.string(forKey: "category_icon")
        {
            self.categoryIcon.image = UIImage(named: category_icon);
        }
        
        
        totalStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        unCompletedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        completedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        //Floaty
        
        //Main styling Floaty button
        let floaty = Floaty(frame: CGRect(x: 58, y: 154, width: 44, height: 44))
        floaty.buttonImage = UIImage(named: "LevelA")
        floaty.openAnimationType = .slideDown
        floaty.hasShadow = false
        floaty.buttonColor = UIColor(red: 48/255, green: 148/255, blue: 172/255, alpha: 1)
        floaty.itemButtonColor = UIColor(red: 48/255, green: 148/255, blue: 172/255, alpha: 1)
        floaty.size = 44
        floaty.itemSize = 44
        floaty.itemSpace = 6
        floaty.itemShadowColor = .clear
        floaty.rotationDegrees = 0.0
        floaty.hasShadow = false
        floaty.overlayColor = UIColor(red: 18/255, green: 88/255, blue: 105/255, alpha: 0)
        
        //@Jasper - Hier kan je vast de code van de buttons van LearningObjectsVC gebruiken
        let item = FloatyItem()
        item.icon = UIImage(named: "LevelB")
        item.imageSize = CGSize(width: 10, height: 15)
        item.buttonColor = UIColor(red: 118/255, green: 206/255, blue: 227/255, alpha: 1)
        floaty.addItem(item: item)
        
        let item2 = FloatyItem()
        item2.icon = UIImage(named: "LevelC")
        item2.imageSize = CGSize(width: 12, height: 15)
        item2.buttonColor = UIColor(red: 118/255, green: 206/255, blue: 227/255, alpha: 1)
        floaty.addItem(item: item2)
        
//        self.view.addSubview(floaty)
        
        progressBarView.backgroundColor = UIColor.clear
        progressBarView.progressColor = UIColor(red: 248.0/255.0, green: 208.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        progressBarView.emptyLineColor = UIColor(red: 84/255, green: 177/255, blue: 199/255, alpha: 1)
        progressBarView.progressStrokeColor = UIColor.clear
        progressBarView.fontColor = UIColor.white
        progressBarView.progressLineWidth = 6
        progressBarView.progressAngle = 100
        progressBarView.progressRotationAngle = 50
        progressBarView.maxValue = 100
        progressBarView.unitString = "%"
        progressBarView.unitFontSize = 44
        progressBarView.unitFontName = "Roboto"
        progressBarView.valueFontSize = 44
        progressBarView.progressCapType = 2
        progressBarView.emptyLineWidth = 4
        progressBarView.valueFontName = "Roboto"
        progressBarView.value = 0
        
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
        
    }
    
    //Completed star button animation function
    @objc func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }
    
    //Back button
    @objc func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is MainLearningObjectsVC {
                //self.performSegue(withIdentifier: "SegueBackToHoofdleerdoelen", sender: nil)
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is MainLearningObjectsVC {
                    //self.performSegue(withIdentifier: "SegueBackToHoofdleerdoelen", sender: nil)
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
            
        }
    }
    
    func getThermometer(token: String, thermometer_id: String)
    {
        let parameters: Parameters = ["api_token": token]
        print("getThermometer")
        let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/thermometer/"+thermometer_id+"?api_token="+token
        print(URL)
        Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<ThermometerResponse>) in
            
//            var count_to_complete: Int?
//            var months: Int?
//            var monthsPercentage: Int?
//            var schoolyear_text: String?
//            var percentage_total: String?
//            var percentage_niveau: String?
//            var niveau: String?
//
            let thermometerResponse = response.result.value
            
            self.completedGoals.text = thermometerResponse?.completed_niveau
            self.uncompletedGoals.text = thermometerResponse?.count_to_complete
            self.totalGoals.text = thermometerResponse?.count_niveau
            self.currentNiveau.text = "Niveau "+(thermometerResponse?.niveau)!
            self.schoolMonths.text = thermometerResponse?.schoolyear_text
            
            //Stars
            self.totalStar.isUserInteractionEnabled = false
            self.unCompletedStar.isUserInteractionEnabled = false
            self.completedStar.isUserInteractionEnabled = false
            
            self.totalStar.sendActions(for: .touchUpInside)
            self.unCompletedStar.sendActions(for: .touchUpInside)
            self.completedStar.sendActions(for: .touchUpInside)
            
            //Time line bar
            self.timelineBar.layer.cornerRadius = 3.0
            self.timelineBar.clipsToBounds = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                if(thermometerResponse?.percentage_niveau != 101) {
//                    self.progressBarView.setValue((thermometerResponse?.percentage_niveau)!, animateWithDuration: 1)
                    
                    UIView.animate(withDuration: 1.0){ [self] in progressBarView.value = (thermometerResponse?.percentage_niveau)! }
                }
                self.timelineBar.setProgress((thermometerResponse!.monthsPercentage! / 100), animated: true)
            })
        }
    }
}

import ObjectMapper

class ThermometerResponse: Mappable {
    var id: Int?
    var count_to_complete: String?
    var count_niveau: String?
    var completed_niveau: String?
    var months: Int?
    var monthsPercentage: Float?
    var schoolyear_text: String?
    var percentage_total: String?
    var percentage_niveau: CGFloat?
    var niveau: String?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        count_to_complete <- map["count_to_complete"]
        count_niveau <- map["count_niveau"]
        completed_niveau <- map["completed_niveau"]
        months <- map["months"]
        monthsPercentage <- map["monthsPercentage"]
        schoolyear_text <- map["schoolyear_text"]
        percentage_total <- map["percentage_total"]
        percentage_niveau <- map["percentage_niveau"]
        niveau <- map["niveau"]
    }
}
