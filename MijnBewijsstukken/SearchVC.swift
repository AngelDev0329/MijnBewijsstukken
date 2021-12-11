//
//  SearchVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 28-06-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class SearchVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var goals_list: [String] = []
    var mainobjects_list: [String] = []
    var icon_list: [String] = []
    var completed_list: [Bool] = []
    var pending_list: [Bool] = []
    var niveau_list: [String] = []
    var goals_slugs: [Int] = []

    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 10
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
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
        
        searchField.becomeFirstResponder()
        
        //Searchfield styling
        searchField.layer.masksToBounds = true
        searchField.layer.cornerRadius = 30.0
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor(red: 102/255, green: 194/255, blue: 216/255, alpha: 1).cgColor
        searchField.backgroundColor = UIColor(red: 102/255, green: 194/255, blue: 216/255, alpha: 1)
        searchField.textColor = UIColor.white
        searchField.font = .systemFont(ofSize: 30)        
        let centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = .center
        let attributedPlaceholder = NSAttributedString(string: "Zoek een leerdoel...", attributes: [NSAttributedString.Key.paragraphStyle: centeredParagraphStyle, NSAttributedString.Key.foregroundColor: UIColor.white])
        searchField.attributedPlaceholder = attributedPlaceholder
    }
    
    @IBAction func touchUpOutsideSearch(_ sender: Any) {
        print("touchUpOutsideSearch")
    }
    @IBAction func didEndOnExitSearch(_ sender: Any) {
        print("didEndOnExitSearch")
    }
    @IBAction func touchUpInsideSearch(_ sender: Any) {
        print("touchUpInsideSearch")
    }
    @IBAction func EditingDidBeginSearch(_ sender: Any) {
        print("EditingDidBeginSearch")
    }
    @IBAction func primaryActionTriggereSearchField(_ sender: Any) {
        print("primaryActionTriggereSearchField")
        DispatchQueue.main.async(execute: {
            self.doSearch()
        })
    }
    @IBAction func touchSearchBtn(_ sender: Any) {
        print(self.goals_list)
        print(self.goals_slugs)
        self.tableView.reloadData()
//        doSearch()
    }
    @IBAction func searchInputChanged(_ sender: Any) {
        print("searchInputChanged")
        doSearch()
        if(self.searchField!.text?.isEmpty)! {
            self.resetArrayStates()
        }
        if((self.searchField.text?.count)! <= 1) {
            self.resetArrayStates()
        }
    }
    @IBAction func searchingEnded(_ sender: Any) {
        print("searchingEnded")
        print("Toetsenbord sluiten zorgt hier voor")
//        doSearch()
    }
    
    weak var timer: Timer?
    
    
    @IBAction func searchingChanged(_ sender: Any) {
        print("searchingChanged")
        if #available(iOS 10, *) {
            timer?.invalidate()
            timer = .scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
                self?.doSearch()
            }
        } else {
            doSearch()
        }
    }
    
    func resetArrayStates()
    {
        self.mainobjects_list = []
        self.goals_list = []
        self.icon_list = []
        self.completed_list = []
        self.pending_list = []
        self.niveau_list = []
        self.goals_slugs = []
        self.tableView.isHidden = true
        if(self.searchField!.text?.isEmpty)! {
            // self.resetArrayStates()
        }
        self.activity.stopAnimating()
    }
    
    func doSearch()
    {
        print("doSearch")
        if(self.searchField!.text?.isEmpty)! {
            self.resetArrayStates()
        } else {
            let defaults = UserDefaults.standard
            if let token = defaults.string(forKey: "user_token")
            {
                self.resetArrayStates()
                self.activity.startAnimating()
                let search = self.searchField.text
                print(search)
                
                let parameters: Parameters = ["api_token": token, "input": search!+" "]
                let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/search/in-goals"
            
                Alamofire.request(URL, parameters: parameters).responseArray { (response: DataResponse<[SearchResponse]>) in
                    let searchResultsArray = response.result.value
                    if search == self.searchField.text {
                        if let searchResultsArray = searchResultsArray {
                            for searchResult in searchResultsArray {
                                self.goals_list.append(searchResult.goal_description!)
                                self.mainobjects_list.append(searchResult.objective!)
                                self.completed_list.append(searchResult.is_completed!)
                                self.pending_list.append(searchResult.is_pending!)
                                self.niveau_list.append(searchResult.niveau!)
                                self.icon_list.append(searchResult.icon!)
                                self.goals_slugs.append(searchResult.goal_id!)
                            }
                        }
                        if(response.response?.statusCode == 412) {
                            self.resetArrayStates()
                        }
                        DispatchQueue.main.async {
                            self.tableView.isHidden = false
                            self.tableView.reloadData()
                            self.activity.stopAnimating()
                        }
                    }
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
            print(self.goals_slugs[indexPath.section])
        }
    }
    
    @IBAction func touchEventSearch(_ sender: Any) {
        print("touchEventSearch")
        print("openen toetsenbord")
        self.resetArrayStates()
//        if(self.searchField!.text?.isEmpty)! {
//            self.resetArrayStates()
//        }
//        if((self.searchField.text?.count)! <= 1) {
//            self.resetArrayStates()
//        }
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
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchCell = self.tableView.dequeueReusableCell(withIdentifier:cellReuseIdentifier) as! SearchCell
        
        cell.borderUncompleted.isHidden = false
        cell.borderCompleted.isHidden = true
        
//        if(!self.goals_list[indexPath.section].isEmpty) {
            cell.objectName.text = self.goals_list[indexPath.section]
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
        
        cell.pendingStar.isHidden = true
        if(self.pending_list[indexPath.section]) {
            cell.completedStar.isHidden = true
            cell.borderUncompleted.isHidden = false
            cell.borderCompleted.isHidden = true
            cell.pendingStar.isHidden = false
        } else {
            cell.pendingStar.isHidden = true
        }
        
        
        
//        @IBOutlet weak var objectName: UILabel!
//        @IBOutlet weak var borderUncompleted: UIView!
//        @IBOutlet weak var borderCompleted: UIView!
//        @IBOutlet weak var classImage: UIImageView!
//        @IBOutlet weak var objectLevel: UILabel!
//        @IBOutlet weak var objectMain: UILabel!
//        @IBOutlet weak var completedStar: DOFavoriteButton!
        
        // Cell styling
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

class SearchResponse: Mappable {
    var goal_id: Int?
    var goal_description: String?
    var is_completed: Bool?
    var is_pending: Bool?
    var icon: String?
    var niveau: String?
    var objective: String?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        goal_id <- map["goal_id"]
        goal_description <- map["goal_description"]
        is_completed <- map["is_completed"]
        is_pending <- map["is_pending"]
        icon <- map["icon"]
        niveau <- map["niveau"]
        objective <- map["objective"]
    }
}

struct APIResponse: Decodable {
    let data: [String]
}
