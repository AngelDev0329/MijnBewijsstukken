//
//  LearningObjectsVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 08-02-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import Floaty
import AlamofireObjectMapper
import Alamofire

class LearningObjectsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    var goals_list: [Any] = []
    var goals_slugs: [Any] = []
    var goals_completes: [Int] = []
    var goals_pendings: [Int] = []
    var goals_sheets: [Any] = []

    var objective_title = String();
    var category_icon = String();


    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "cell"
    let cellSpacingHeight: CGFloat = 10

    @IBOutlet weak var imageAllLinked: UIView!
    @IBOutlet weak var imageNoneLinked: UIView!
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }

//    override var shouldAutorotate: Bool {
//        return true;
//    }
//

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentLevel: UILabel!
    @IBOutlet weak var CategoryIcon: UIImageView!
    @IBOutlet weak var objectName: UILabel!
    @IBOutlet weak var unlinkedButton: UIButton!
    @IBOutlet weak var linkedButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var activity: UIActivityIndicatorView!

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.goals_list.removeAll()
        self.goals_slugs.removeAll()
        self.goals_completes.removeAll()
        self.goals_pendings.removeAll()
        self.goals_sheets.removeAll()
        

        let defaults = UserDefaults.standard
        if let objective_slug = defaults.string(forKey: "objective_slug")
        {
            if let objective_niveau = defaults.string(forKey: "objective_niveau")
            {
                self.loadGoals(slug: objective_slug, niveau: objective_niveau, what: "all")
            }
        }
        
        defaults.set(nil, forKey: "sheet_document")

        tableView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Add toolbar
        addGeneralToolbarItems()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 56.0

        tableView.rowHeight = UITableView.automaticDimension

        // UIActivityIndicatorView
        self.activity.isHidden = false
        self.activity.startAnimating()
        
        self.tableView.isHidden = true
        

        print("viewDidLoad LearningObjectsVc")
        imageAllLinked.isHidden = true
        imageNoneLinked.isHidden = true

        //Make the label of the current level a circle (top right in title)
        currentLevel.layer.masksToBounds = true
        currentLevel.layer.cornerRadius = currentLevel.frame.width / 2

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

    //Back button
    @objc func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is MainLearningObjectsVC {
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
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }

        }
        else if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is LearningObjectVC {
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

    @IBAction func clickGoalLabel(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            defaults.set(self.goals_list[indexPath.section], forKey: "goal_description")
//            print(self.goals_sheets[indexPath.section])
            defaults.set(self.goals_sheets[indexPath.section], forKey: "sheet_document")
            defaults.set(self.goals_slugs[indexPath.section], forKey: "goal_id")
        }
    }

    @IBAction func clickGoal(_ sender: UIButton) {
        let hitPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let indexPath = self.tableView.indexPathForRow(at: hitPoint){
            let defaults = UserDefaults.standard
            defaults.set(self.goals_list[indexPath.section], forKey: "goal_description")
            defaults.set(self.goals_sheets[indexPath.section], forKey: "sheet_document")
            defaults.set(self.goals_slugs[indexPath.section], forKey: "goal_id")
        }
    }

    public func loadGoals(slug: String, niveau: String, what: String)
    {
        let defaults = UserDefaults.standard
        //Main styling Floaty button
        let floaty = Floaty(frame: CGRect(x: 58, y: 154, width: 44, height: 44))
        floaty.buttonImage = UIImage(named: "Level"+defaults.string(forKey: "objective_niveau")!)
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

        let availableNiveaus = defaults.stringArray(forKey: "objective_niveaus") ?? [String]()

        ["A", "B", "C", "D", "E", "F", "G", "H", "I"].forEach { niveau in

            if (availableNiveaus).contains(niveau) {
                var width = 10 // B, E, F
                if niveau == "A"  {
                    width = 13
                }
                if niveau == "C" || niveau == "G" {
                    width = 12
                }
                if niveau == "I" {
                    width = 3
                }
                let item = FloatyItem()
                if(niveau == defaults.string(forKey: "objective_niveau")) {
                    item.buttonColor = UIColor(red: 118/255, green: 206/255, blue: 227/255, alpha: 1)
                    //item.title = "Huidige niveau"
                } else {
                    item.buttonColor = UIColor(red: 48/255, green: 148/255, blue: 172/255, alpha: 1)
                }
                item.icon = UIImage(named: "Level"+niveau)!
                item.handler = { item in
                    defaults.set(niveau, forKey: "objective_niveau")
                    self.loadGoals(slug: defaults.string(forKey: "objective_slug")!, niveau: defaults.string(forKey: "objective_niveau")!, what: "all")
                }
                item.imageSize = CGSize(width: width, height: 15)
                floaty.addItem(item: item)
            }
        }


        self.view.addSubview(floaty)


        print("loadGoals: "+niveau+" van "+slug)
        self.goals_list = []
        self.goals_slugs = []
        self.goals_completes = []
        self.goals_pendings = []

        // Data ophalen
//        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.currentLevel.text = niveau
            print("Current: "+niveau)
            self.activity.startAnimating()
            let parameters: Parameters = ["api_token": token]

            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/goals/"+slug+"/"+niveau+"/"+what
            print(URL)
            Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<ObjectiveResponse>) in

                let objectiveResponse = response.result.value
                self.objective_title = (objectiveResponse?.name)!
                self.category_icon = (objectiveResponse?.icon)!
                self.goals_completes = (objectiveResponse?.completes)!
                self.goals_pendings = (objectiveResponse?.pendings)!
                

                self.objectName.text = "Leerdoelen "+self.objective_title
                self.objectName.text = self.objective_title
                self.CategoryIcon.image = UIImage(named: self.category_icon);

                let defaults = UserDefaults.standard
                defaults.set(self.category_icon, forKey: "category_icon")

                if let goals = objectiveResponse?.goals {
                    for goal in goals {
                        self.goals_list.append(goal.description!)
                        self.goals_sheets.append(goal.sheet!)
                        self.goals_slugs.append(goal.id!)
                    }
                }
                if(what == "linked") {
                    if(self.goals_list.count <= 0) {
                        self.imageNoneLinked.isHidden = false
                    }
                }
                if(what == "open") {
                    if(self.goals_list.count <= 0) {
                        self.imageAllLinked.isHidden = false
                    }
                }
                self.tableView.isHidden = false
                self.tableView.reloadData()
                self.activity.stopAnimating()
            }

        }
    }

    @IBAction func allGoals(_ sender: UIButton) {
        resetStates()
        listButton.isSelected = true
        let defaults = UserDefaults.standard
        if let objective_slug = defaults.string(forKey: "objective_slug")
        {
            if let objective_niveau = defaults.string(forKey: "objective_niveau")
            {
                self.loadGoals(slug: objective_slug, niveau: objective_niveau, what: "all")
            }
        }
    }

    @IBAction func notLinkedGoals(_ sender: UIButton) {
        resetStates()
        unlinkedButton.isSelected = true
        let defaults = UserDefaults.standard
        if let objective_slug = defaults.string(forKey: "objective_slug")
        {
            if let objective_niveau = defaults.string(forKey: "objective_niveau")
            {
                self.loadGoals(slug: objective_slug, niveau: objective_niveau, what: "open")
            }
        }
    }

    @IBAction func linkedGoals(_ sender: UIButton) {
        resetStates()
        linkedButton.isSelected = true
        let defaults = UserDefaults.standard
        if let objective_slug = defaults.string(forKey: "objective_slug")
        {
            if let objective_niveau = defaults.string(forKey: "objective_niveau")
            {
                self.loadGoals(slug: objective_slug, niveau: objective_niveau, what: "linked")
            }
        }
    }

    func resetStates ()
    {
        self.goals_list = []
        self.goals_slugs = []
        self.goals_completes = []
        self.goals_pendings = []
        imageAllLinked.isHidden = true
        imageNoneLinked.isHidden = true
        unlinkedButton.isSelected = false
        linkedButton.isSelected = false
        listButton.isSelected = false
    }


    // MARK: - Table View delegate methods

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.goals_list.count
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

        let cell:LearningObjectCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! LearningObjectCell

        cell.objectName.text = self.goals_list[indexPath.section] as? String

        // Cell styling
        cell.backgroundColor = UIColor.white
        cell.layer.cornerRadius = 3
        cell.clipsToBounds = true
        cell.selectionStyle = .none
        cell.completedStar.addTarget(self, action: #selector(self.tappedButton), for: .touchUpInside)
        cell.completedStar.deselect()
        cell.completedStar.isUserInteractionEnabled = false
        
        cell.pendingStar.isHidden = true
        cell.pendingStar.setImage(UIImage(named: "Star-Pending-Grey"), for: .normal)

        cell.borderUncompleted.isHidden = false
        cell.borderCompleted.isHidden = true
        
        
        let elements = self.goals_completes
        if(elements.count > 0){
            let id = self.goals_slugs[indexPath.section] as? Int
            if(id != nil){
                if elements.contains(id!) {
                    cell.completedStar.sendActions(for: .touchUpInside)
                    cell.borderUncompleted.isHidden = true
                    cell.borderCompleted.isHidden = false
                }
            }
        }
        
        let elementsPending = self.goals_pendings
        if(elementsPending.count > 0){
            let id = self.goals_slugs[indexPath.section] as? Int
            
            if(id != nil){
                if elementsPending.contains(id!) {
                    cell.borderUncompleted.isHidden = true
                    cell.borderCompleted.isHidden = false
                    cell.completedStar.isHidden = true
                    cell.pendingStar.isHidden = false
                    cell.borderUncompleted.isHidden = false
                    cell.borderCompleted.isHidden = true
                }
            }
        }
        

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
    
    func tappedButtonPending(sender: DOFavoriteButton) {
        if sender.isSelected {
            sender.deselect()
        } else {
            sender.select()
        }
    }

    //Fade in table

    /*func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        cell.alpha = 0
        UIView.animate(withDuration: 0.33) {
            cell.alpha = 1
        }
    }*/
}




import ObjectMapper

class ObjectiveResponse: Mappable {
    var name: String?
    var niveau: String?
    var icon: String?
    var goals: [Goal]?
    var completes: Array<Int>?
    var pendings: Array<Int>?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        name <- map["objective"]
        icon <- map["icon"]
        niveau <- map["niveau"]
        goals <- map["goals"]
        completes <- map["completes"]
        pendings <- map["pendings"]
    }
}

class Goal: Mappable {
    var id: Int?
    var description: String?
    var sheet: String?

    required init?(map: Map){

    }

    func mapping(map: Map) {
        id <- map["id"]
        description <- map["description"]
        sheet <- map["sheet_url"]
    }
}
