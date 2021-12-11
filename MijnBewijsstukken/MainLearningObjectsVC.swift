//
//  MainLearningObjectsVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 08-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class MainLearningObjectsVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,MainLearningObjectCellDelegate  {

    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // These strings will be the data for the table view cells
    var objectives_list: [Any] = []
    var objectives_list_niveaus: [Any] = []
    var objectives_slugs: [Any] = []
    var objectives_total_goals: [AnyObject] = []
    var objectives_percentage_total: [Any] = []
    var objectives_percentage_niveau: [Any] = []
    var objectives_thermometer: [Any] = []
    var objectives_accomplished: [Any] = []

    var category_title = String();
    var category_icon = String();

    var niveaus = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]

    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 10

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var currentLevel: UILabel!

    @IBOutlet weak var CategoryName: UILabel!
    @IBOutlet weak var CategoryIcon: UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var hasContent = true

//    let page = TKRubberIndicator(frame: CGRectMake(100, 100, 200, 100), count: 6)

    override func viewWillAppear(_ animated: Bool)
    {
        print("VieWillAppear") 
        super.viewWillAppear(animated)

        self.objectives_list.removeAll()
        self.objectives_list_niveaus.removeAll()
        self.objectives_slugs.removeAll()
        self.objectives_total_goals.removeAll()
        self.objectives_percentage_total.removeAll()
        self.objectives_percentage_niveau.removeAll()
        self.objectives_thermometer.removeAll()
        self.objectives_accomplished.removeAll()
        
        let defaults = UserDefaults.standard
        if let category_slug = defaults.string(forKey: "category_slug")
        {
            if Reachability.isConnectedToNetwork(){
                self.loadObjectives(slug: category_slug)
            }
        }
        self.hasContent = true
        self.tableView.isHidden = true
        self.activity.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewDiDLoad")
        
        //Add toolbar
        addGeneralToolbarItems()
        
        //Tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false

        self.tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 56.0
        tableView.rowHeight = UITableView.automaticDimension

        // UIActivityIndicatorView
        self.activity.isHidden = false
        
        self.activity.startAnimating()

        //Make the label of the current level a circle (top right in title)
        currentLevel.layer.masksToBounds = true
        currentLevel.layer.cornerRadius = currentLevel.frame.width / 2

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
        
        currentLevel.text = ""
        
    }

    public func loadObjectives(slug: String)
    {
        // Data ophalen
        print("loadObjectives")
        let defaults = UserDefaults.standard

        if let token = defaults.string(forKey: "user_token")
        {
            self.activity.startAnimating()
            let parameters: Parameters = ["api_token": token]

            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/objectives/"+slug+"?api_token="+token+"&thermometer=true"
            print(URL)
            Alamofire.request(URL, parameters:parameters).responseObject { (response: DataResponse<CategoryResponse>) in

                let categoryResponse = response.result.value
                self.category_title = (categoryResponse?.name)!
                self.category_icon = (categoryResponse?.icon)!

                self.CategoryName.text = self.category_title
                self.CategoryIcon.image = UIImage(named: self.category_icon);

                let defaults = UserDefaults.standard
                defaults.set(self.category_icon, forKey: "category_icon")

                if let objectives = categoryResponse?.objectives {
                    for objective in objectives {
                        self.objectives_list.append(objective.name!)
                        self.objectives_list_niveaus.append(objective.filled!)
                        self.objectives_accomplished.append(objective.accomplished!)
                        self.objectives_slugs.append(objective.slug!)
                        if(objective.completed != nil) {
                            self.objectives_percentage_total.append(objective.completed!)
                            self.objectives_percentage_niveau.append(objective.completed_niveau!)
                            self.objectives_thermometer.append(objective.thermometer!)
                        
                            self.currentLevel.text = (objective.niveau)!
                            defaults.set((objective.niveau)!, forKey: "current_niveau")
                        }
//                        self.objectives_total_goals.append(objective.total_goals! as AnyObject)
                    }
                }
                self.tableView.isHidden = false

//                self.tableView.reloadData()
                self.activity.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }


    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {

            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is ClassesOverviewVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }

        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LearningObjectsVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }

        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {

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

    // MARK: - Table View delegate methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.objectives_list.count
    }

    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }

    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    @IBAction func niveauA(_ sender: UIButton) {
        print("NIVEAU A")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        print(hitPoint)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("A")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("A", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }

    @IBAction func niveauB(_ sender: UIButton) {
        print("NIVEAU B")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("B")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("B", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauC(_ sender: UIButton) {
        print("NIVEAU C")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("C")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("C", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }

    @IBAction func niveauD(_ sender: UIButton) {
        print("NIVEAU D")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("D")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("D", forKey: "objective_niveau")
                self.hasContent = true
            }
            else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauE(_ sender: UIButton) {
        print("NIVEAU E")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("E")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("E", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauF(_ sender: UIButton) {
        print("NIVEAU F")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("F")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("F", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauG(_ sender: UIButton) {
        print("NIVEAU G")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("G")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("G", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauH(_ sender: UIButton) {
       
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        print(hitPoint)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("H")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("H", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    @IBAction func niveauI(_ sender: UIButton) {
        print("NIVEAU I")
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            if(self.objectives_list_niveaus.count <= 0) {
                self.hasContent = false
            }
            else if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("I")) {
                defaults.set(self.objectives_slugs[indexPath.section], forKey: "objective_slug")
                defaults.set(self.objectives_list_niveaus[indexPath.section], forKey: "objective_niveaus")
                defaults.set("I", forKey: "objective_niveau")
                self.hasContent = true
            } else {
                self.hasContent = false
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ["segA", "segB", "segC", "segD", "segE", "segF", "segG", "segH", "segI"].contains(ident) {
                if hasContent != true {
                    self.hasContent = false
                    return false
                }
            }
        }
        return true
    }
    

    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:MainLearningObjectCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MainLearningObjectCell

        cell.objectName.text = self.objectives_list[indexPath.section] as? String

        // Cell styling
        cell.backgroundColor = UIColor(red: 54/255, green: 169/255, blue: 197/255, alpha: 1)
        cell.layer.cornerRadius = 3
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.completedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        cell.completedStar.isUserInteractionEnabled = false

        cell.indexPath = indexPath
        cell.totalPercent.text = ""
        cell.levelPercent.text = ""

        let defaults = UserDefaults.standard
        var theNiveau = ""

        if let current_niveau = defaults.string(forKey: "current_niveau")
        {
            if(self.objectives_percentage_total.count > 0) {
                cell.currentNiveau.text = "Niveau "+current_niveau
                if(self.objectives_percentage_total.indices.contains(indexPath.section)) {
                    cell.totalPercent.text = self.objectives_percentage_total[indexPath.section] as? String
                    cell.levelPercent.text = self.objectives_percentage_niveau[indexPath.section] as? String
                    if(cell.levelPercent.text == "101%") {
                        cell.levelPercent.text = "0%"
                        cell.revealedStarCurrentLevelStats.isHidden = true
                        cell.statsLevelStarDisabled.isHidden = false
                        cell.levelPercent.textColor = UIColor(red: 163/255, green: 218/255, blue: 232/255, alpha: 1.0)
                        cell.currentNiveau.textColor = UIColor(red: 163/255, green: 218/255, blue: 232/255, alpha: 1.0)
                        cell.statsLevelBackground.backgroundColor = UIColor(red: 82/255, green: 186/255, blue: 211/255, alpha: 1.0)
                    }
                    if(cell.totalPercent.text == "100%") {
                        cell.completedStar.isSelected = true
                    }
                }
                theNiveau = current_niveau
            }
        }
        
        if(self.objectives_list_niveaus.count > 0) {
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("A")) {
                cell.levelA.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "A") {
                    cell.levelA.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "A" && cell.levelPercent.text == "100%") {
                    cell.levelA.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if((self.objectives_accomplished[indexPath.section] as! Array).contains("A")) && theNiveau != "A" {
                    cell.levelA.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelA.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelA.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("B")) {
                cell.levelB.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "B") {
                    cell.levelB.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "B" && cell.levelPercent.text == "100%") {
                    cell.levelB.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("B")  && theNiveau != "B" {
                    cell.levelB.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelB.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelB.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("C")) {
                cell.levelC.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "C") {
                    cell.levelC.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "C" && cell.levelPercent.text == "100%") {
                    cell.levelC.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("C")  && theNiveau != "C" {
                    cell.levelC.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelC.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelC.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("D")) {
                cell.levelD.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "D") {
                    cell.levelD.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "D" && cell.levelPercent.text == "100%") {
                    cell.levelD.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("D")  && theNiveau != "D" {
                    cell.levelD.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelD.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelD.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("E")) {
                cell.levelE.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "E") {
                    cell.levelE.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "E" && cell.levelPercent.text == "100%") {
                    cell.levelE.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("E")  && theNiveau != "E" {
                    cell.levelE.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelE.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelE.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("F")) {
                cell.levelF.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "F") {
                    cell.levelF.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "F" && cell.levelPercent.text == "100%") {
                    cell.levelF.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("F")  && theNiveau != "F" {
                    cell.levelF.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelF.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelF.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("G")) {
                cell.levelG.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "G") {
                    cell.levelG.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "G" && cell.levelPercent.text == "100%") {
                    cell.levelG.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("G")  && theNiveau != "G"{
                    cell.levelG.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelG.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelG.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("H")) {
                cell.levelH.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "H") {
                    cell.levelH.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "H" && cell.levelPercent.text == "100%") {
                    cell.levelH.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("H") && theNiveau != "H" {
                    cell.levelH.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelH.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelH.isUserInteractionEnabled = false
            }
            if((self.objectives_list_niveaus[indexPath.section] as! Array).contains("I")) {
                cell.levelI.backgroundColor = UIColor(red: 89/255, green: 184/255, blue: 207/255, alpha: 1)
                if(theNiveau == "I") {
                    cell.levelI.backgroundColor = UIColor(red: 102/255, green: 210/255, blue: 236/255, alpha: 1)
                }
                if(theNiveau == "I" && cell.levelPercent.text == "100%") {
                    cell.levelI.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
                else if(self.objectives_accomplished[indexPath.section] as! Array).contains("I") && theNiveau != "I" {
                    cell.levelI.backgroundColor = UIColor(red: 140/255, green: 236/255, blue: 135/255, alpha: 1)
                }
            } else {
                cell.levelI.backgroundColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1)
    //            cell.levelI.isUserInteractionEnabled = false
            }
        }

        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! MainLearningObjectCell
        tableView.closeAllCells(exceptThisOne: cell)
    }
    func didClickedTotalPercentButton(_ indexPath: IndexPath, percentStr: String) {
        let defaults = UserDefaults.standard
        defaults.set((self.objectives_thermometer[indexPath.section] as? Int)!, forKey: "thermometer_id")
    }
    func didClickedLevelPercentButton(_ indexPath: IndexPath, percentStr: String) {
        let defaults = UserDefaults.standard
        defaults.set((self.objectives_thermometer[indexPath.section] as? Int)!, forKey: "thermometer_id")
    }
    func didStartPanGesture(cell: MainLearningObjectCell) {
        self.tableView.closeAllCells(exceptThisOne: cell)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }
//
//    override var shouldAutorotate: Bool {
//        return true;
//    }


    func myButtonPressed(foo : String, bar : String) {
        print(foo)
        print(bar)
        print(#function)
    }

    //Completed star button animation function

    @objc func tappedButton(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }

    //Fade in table
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        cell.alpha = 0
//        UIView.animate(withDuration: 0.33) {
//            cell.alpha = 1
//        }
//    }
}


import ObjectMapper

class CategoryResponse: Mappable {
    var name: String?
    var icon: String?
    var objectives: [Objective]?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        name <- map["name"]
        icon <- map["icon.name"]
        objectives <- map["objectives"]
    }
}

class Objective: Mappable {
    var niveau: String?
    var name: String?
    var slug: String?
    var filled: Array<Any>?
    var accomplished: Array<Any>?
    var total_goals: Array<Any>?
    var completed: String?
    var completed_niveau: String?
    var thermometer: Int?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        thermometer <- map["thermometer.id"]
        completed <- map["thermometer.percentage_total"]
        completed_niveau <- map["thermometer.percentage_niveau"]
        niveau <- map["thermometer.niveau"]
        name <- map["name"]
        slug <- map["slug"]
        filled <- map["filled"]
        accomplished <- map["accomplished"]
        total_goals <- map["total_goals"]
    }
}
