//
//  DocumentScanResultVC.swift
//  MijnBewijsstukken
//
//  Created by admin on 9/4/17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import Alamofire

protocol DocumentScanResultVCDelegate: class {
    func completeUploadScanResult(_ isSuccess: Bool)
}

class DocumentScanResultVC: UIViewController {

    @IBOutlet var resultImageView: UIImageView!
    
    var capturedImage : UIImage?
    private var progressBarView : MBCircularProgressBarView!;
    
    weak var delegate: DocumentScanResultVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.resultImageView.image = self.capturedImage;
        
        progressBarView = MBCircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 150, height: 150));
        progressBarView.backgroundColor = UIColor.clear
        progressBarView.progressColor = UIColor(red: 248.0/255.0, green: 208.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        progressBarView.emptyLineColor = UIColor(red: 102/255, green: 194/255, blue: 216/255, alpha: 1)
        progressBarView.progressStrokeColor = UIColor.clear
        progressBarView.fontColor = UIColor.white
        progressBarView.progressLineWidth = 10
        progressBarView.progressAngle = 100
        progressBarView.maxValue = 100
        progressBarView.unitString = "%"
        progressBarView.unitFontSize = 20
        progressBarView.valueFontSize = 25
        progressBarView.progressCapType = 2
        progressBarView.emptyLineWidth = 9
        progressBarView.center = self.view.center
        self.view.addSubview(progressBarView)
        self.progressBarView.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.portrait
//    }
    
//    override var shouldAutorotate: Bool {
//        return false;
//    }
//    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func onSubmit(_ sender: Any) {
        
        self.progressBarView.isHidden = false
        
        let imageData = self.capturedImage!.jpegData(compressionQuality: 0.8)
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completion/"+defaults.string(forKey: "goal_id")!+"?api_token="+token
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData!, withName: "photo", fileName: "photo.jpg",mimeType: "image/jpeg")
            }, usingThreshold: UInt64.init(),
               to: URL,
               method: .post, headers: nil) { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        self.progressBarView.isHidden = true
                        
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: "completed")
//                        self.dismiss(animated: true, completion: nil)

//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let controller = storyboard.instantiateViewController(withIdentifier: "learningObjectStoryBoardId")
//                        self.present(controller, animated: false, completion: nil)
                        
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let _: LearningObjectVC = mainStoryboard.instantiateViewController(withIdentifier: "learningObjectStoryBoardId") as! LearningObjectVC
                        if defaults.string(forKey: "user_token") != nil
                        {
//                            innerPage.getCompletions(token: token)
                        }
                        self.dismiss(animated: true, completion: {
                            self.delegate?.completeUploadScanResult(true);
                        })
                    }
                    upload.uploadProgress { progress in
                        self.progressBarView.value = CGFloat(progress.fractionCompleted*100);
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    self.progressBarView.isHidden = false
                }
            }
        }
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
