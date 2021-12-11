//
//  ReviewsVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 19-10-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class ReviewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var goals_list: [String] = []
    var goals_list_message: [String] = []
    var persons: [String] = []
    var messages: [String] = []
    var mainobjects_list: [String] = []
    var icon_list: [String] = []
    var completed_list: [Bool] = []
    var pending_list: [Bool] = []
    var niveau_list: [String] = []
    var goals_slugs: [Int] = []
    
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 10
    @IBOutlet weak var noNotifications: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.stopAnimating()
        //Add toolbar
        addGeneralToolbarItems()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 56.0
        tableView.rowHeight = UITableView.automaticDimension
        
        //Shake gesture
        self.becomeFirstResponder()
        self.getNotifications()
        
    }
    func resetArrayStates()
    {
        self.mainobjects_list = []
        self.goals_list = []
        self.goals_list_message = []
        self.icon_list = []
        self.completed_list = []
        self.pending_list = []
        self.niveau_list = []
        self.goals_slugs = []
        self.messages = []
        self.persons = []
        self.tableView.isHidden = true
        self.activity.stopAnimating()
    }
    
    func getNotifications()
    {
        print("getNotifications")
        self.resetArrayStates()
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.resetArrayStates()
            self.activity.startAnimating()
            
            let parameters: Parameters = ["api_token": token]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/notifications"
            
            Alamofire.request(URL, parameters: parameters).responseArray { (response: DataResponse<[NotificationsResponse]>) in
            let searchResultsArray = response.result.value
                if let searchResultsArray = searchResultsArray {
                    for searchResult in searchResultsArray {
                        var message = searchResult.goal_description!
                        if(searchResult.is_completed!) {
                            message = "Leerdoel ''"+message+"'' is goedgekeurd!"
                        } else {
                            message = "Leerdoel ''"+message+"'' is afgekeurd"
                        }
                        self.goals_list.append(searchResult.goal_description!)
                        self.goals_list_message.append(message)
                        self.mainobjects_list.append(searchResult.objective!)
                        self.completed_list.append(searchResult.is_completed!)
                        self.niveau_list.append(searchResult.niveau!)
                        self.icon_list.append(searchResult.icon!)
                        self.goals_slugs.append(searchResult.goal_id!)
                        if((searchResult.message != nil) && (searchResult.message?.count)! > 0) {
                            self.messages.append(searchResult.message ?? "")
                            self.persons.append(searchResult.person!+":")
                        } else {
                            self.messages.append(searchResult.message ?? "")
                            self.persons.append("Door "+searchResult.person!)
                        }
                        
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "has_notification")
                    }
                }
                if(response.response?.statusCode == 412) {
                    self.resetArrayStates()
                }
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    if(self.goals_list.count <= 0) {
                        self.noNotifications.isHidden = false
                    }
                    self.tableView.reloadData()
                    self.activity.stopAnimating()
                }
            }
        }
    }
    
    // MARK: - Table View delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.goals_list.count
    }
    
    @IBAction func selectSearchResult(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        print("SELECTSEARCHRESULT")
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            defaults.set(self.goals_list[indexPath.section], forKey: "goal_description")
            defaults.set(self.goals_slugs[indexPath.section], forKey: "goal_id")
            defaults.set(self.icon_list[indexPath.section], forKey: "category_icon")
            
            defaults.set("hide_back_btn", forKey: "hide_back_btn")
            defaults.set("hide_back_btn_all", forKey: "hide_back_btn_all")
            print(self.goals_slugs[indexPath.section])
        }
    }
    
  
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:ReviewCell = self.tableView.dequeueReusableCell(withIdentifier:cellReuseIdentifier) as! ReviewCell
        
        cell.borderUncompleted.isHidden = false
        cell.borderCompleted.isHidden = true
        
        cell.personName.adjustsFontSizeToFitWidth = false
        cell.personName.numberOfLines = 0
        
        
        
        
        //        if(!self.goals_list[indexPath.section].isEmpty) {
        cell.objectName.text = self.goals_list_message[indexPath.section]
        cell.objectMain.text = self.mainobjects_list[indexPath.section]
        cell.objectLevel.text = self.niveau_list[indexPath.section]
        cell.classImage.image = UIImage(named: self.icon_list[indexPath.section])
        //        }
        
        if(self.completed_list[indexPath.section]) {
            cell.completedStar.select()
            cell.borderUncompleted.isHidden = true
            cell.borderCompleted.isHidden = false
        } else {
            cell.completedStar.deselect()
        }
        
        cell.personName.text = self.persons[indexPath.section]
        cell.objectMain.text = self.messages[indexPath.section]
        
//        cell.pendingStar.isHidden = true
//        if(self.pending_list[indexPath.section]) {
//            cell.completedStar.isHidden = true
//            cell.borderUncompleted.isHidden = false
//            cell.borderCompleted.isHidden = true
//            cell.pendingStar.isHidden = false
//        } else {
//            cell.pendingStar.isHidden = true
//        }
//
        
        
        //        @IBOutlet weak var objectName: UILabel!
        //        @IBOutlet weak var borderUncompleted: UIView!
        //        @IBOutlet weak var borderCompleted: UIView!
        //        @IBOutlet weak var classImage: UIImageView!
        //        @IBOutlet weak var objectLevel: UILabel!
        //        @IBOutlet weak var objectMain: UILabel!
        //        @IBOutlet weak var completedStar: DOFavoriteButton!
        
        // Cell styling
        cell.personName.sizeToFit()
        cell.personName.layoutIfNeeded()
        cell.objectMain.sizeToFit()
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 3
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        cell.completedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        
        cell.completedStar.isUserInteractionEnabled = false
        
        cell.objectLevel.layer.masksToBounds = true
        cell.objectLevel.layer.cornerRadius = cell.objectLevel.frame.width / 2
        
        
        
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
    
}

import ObjectMapper

class NotificationsResponse: Mappable {
    var goal_id: Int?
    var goal_description: String?
    var is_completed: Bool?
    var icon: String?
    var niveau: String?
    var objective: String?
    var message: String?
    var person: String?

    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        goal_id <- map["goal.id"]
        goal_description <- map["goal.description"]
        is_completed <- map["is_approved"]
        icon <- map["goal.objective.category.icon.name"]
        niveau <- map["goal.niveau.name"]
        objective <- map["goal.objective.name"]
        message <- map["message"]
        person <- map["teacher.name"]
    }
}
