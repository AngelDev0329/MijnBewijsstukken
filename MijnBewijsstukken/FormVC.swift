//
//  FormVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 23-02-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire


class FormVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, PhotoVCDelegate, VideoVCDelegate{
    func completeUploadPhoto(_ isSuccess: Bool) {
        self.loadQuestions()
    }
    
    func completeUploadPhotoReport(_ isSuccess: Bool) {
        self.loadQuestions()
    }
    
    func completeUploadVideo(_ isSuccess: Bool) {
        self.loadQuestions()
    }
    

    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
        
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reportTitle: UILabel!
    var questionData: [Any] = []
    // "Waarom zijn bananen krom?", "Hoe weet je dat?", "Welke kleur heeft een banaan?"]
    
    var questions: [Question] = []
    var answersData: [String:String] = [:]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var uploadBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        //Add toolbar
        addGeneralToolbarItems()
        
        self.loadQuestions()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        tableView.backgroundColor = UIColor.clear
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        
        // Along with auto layout, these are the keys for enabling variable cell height
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableView.automaticDimension
        
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
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
    }
    
    /** https://blog.apoorvmote.com/move-uitextfield-up-when-keyboard-appears/ **/
    func adjustingHeight(show:Bool, notification:NSNotification) {
        self.bottomConstraint.constant = 0
        // 1
        var userInfo = notification.userInfo!
        // 2
        let keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        // 3
        let animationDurarion = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        // 4
        let changeInHeight = (keyboardFrame.height - 60) * (show ? 1 : -1)
        //5
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
            print("changeInHeight")
            print(changeInHeight)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    func loadQuestions()
    {
        print("loadQuestions")
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.activity.startAnimating()
            let parameters: Parameters = ["api_token": token]
            let URL = defaults.string(forKey: "questions_link")
            print(URL!)
            self.reportTitle.text = defaults.string(forKey: "report_title")
            
            Alamofire.request(URL!, parameters: parameters).responseArray { (response: DataResponse<[Question]>) in
                let questionsArray = response.result.value
                if let questionsArray = questionsArray {
                    for question in questionsArray {
                        self.answersData["\(question.id!)"] = question.answer
                        self.questionData.append(question.question!)
                        self.questions.append(question)
                        
                        defaults.set(question.report_slug!, forKey: "report_slug")
                        defaults.set(question.report_id!, forKey: "report_id")
                        defaults.set(nil, forKey: "goal_id")
                        defaults.set(true, forKey: "showed_questions")

                        if(!question.has_uploads!) {
                            self.uploadBtn.isHidden = true
                        }
                    }
                }
                self.tableView.reloadData()
                                self.activity.stopAnimating()
            }
        }
    }
    
    
    @IBAction func printAnswers() {
        print("***Printing Answers***")
        for answer in answersData {
            print("---------------------------")
            print(answer.key," : ",answer.value)
            print("---------------------------")
        }
        print("***End of Answers***")
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            let parameters: Parameters = answersData
            let requestURL = "https://beheer.mijnbewijsstukken.nl/api/swift/themes/answers?api_token="+token
            print(requestURL)
            let request = Alamofire.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            
            request.responseString { (response) in
                print(response)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.text)
        self.tableView.scrollToRow(at:  NSIndexPath(row: 0, section: 3) as IndexPath, at: .top, animated: true)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("Text Did Change")
        
    }
    
    // MARK: - Table View delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.questionData.count
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    let cellSpacingHeight: CGFloat = 1
    
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
        let cell:FormCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! FormCell
        cell.formQuestion.text = (self.questionData[indexPath.section] as! String)
        let question = questions[indexPath.section]
        cell.formAnswer.text = answersData["\(question.id!)"]
        cell.delegate = self
        
        // Cell styling
        cell.backgroundColor = UIColor.clear
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.selectionStyle = .none

        cell.formAnswer.layer.cornerRadius = 3
        cell.formAnswer.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //Back button
    @objc func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is FormsVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
                break
            }
        }
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is FormsVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                    break
                }
            }
            
        }

    }

}



// MARK: - FormCell delegate
extension FormVC: FormCellDelegate {
    
    func formCell(_ cell: FormCell, textViewDidChange textView: UITextView) {
        

        let indexPath = tableView.indexPath(for: cell)!

        let lines = Int((textView.contentSize.height/textView.font!.lineHeight))
        if lines > 10 {
            if !textView.isScrollEnabled {
                cell.textViewHeighConstraint.constant = textView.contentSize.height
            }
            cell.textViewHeighConstraint.isActive = true
            textView.isScrollEnabled = true
        } else {
            if textView.isScrollEnabled {
                cell.textViewHeighConstraint.isActive = false
                textView.isScrollEnabled = false
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        let question = questions[indexPath.section]
        answersData["\(question.id!)"] = textView.text
        tableView.beginUpdates()
        tableView.endUpdates()
        
    }
}

import ObjectMapper
class Question: Mappable {
    var question: String?
    var answer: String?
    var id: Int?
    var report_slug: String?
    var report_id: Int?
    var has_uploads: Bool?
    
    required init?(map: Map){
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        question <- map["question"]
        answer <- map["answer"]
        report_id <- map["report.id"]
        report_slug <- map["report.slug"]
        has_uploads <- map["report.has_uploads"]
    }
}
