/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit
import Alamofire
import MBCircularProgressBar

protocol PhotoVCDelegate: class {
    func completeUploadPhoto(_ isSuccess: Bool)
    func completeUploadPhotoReport(_ isSuccess: Bool)
}

class PhotoViewController: UIViewController {
    weak var delegate: PhotoVCDelegate?

	override var prefersStatusBarHidden: Bool {
		return true
	}
    

	private var backgroundImage: UIImage

    private var progressBarView : MBCircularProgressBarView!;
    
	init(image: UIImage) {
		self.backgroundImage = image
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
    
    let events = EventManager();
    
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.black
        
		let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFit
		backgroundImageView.image = backgroundImage
		view.addSubview(backgroundImageView)
        
		let cancelButton = UIButton()
        cancelButton.frame = CGRect(x: self.view.frame.size.width / 2 - 76, y: self.view.frame.size.height - 86, width: 66.0, height: 66.0)
        cancelButton.setImage(UIImage(named:"Cancel-Upload")?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
		cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		view.addSubview(cancelButton)
        
        let uploadButton = UIButton()
        uploadButton.frame = CGRect(x: self.view.frame.size.width / 2 + 10, y: self.view.frame.size.height - 86, width: 66.0, height: 66.0)
        uploadButton.semanticContentAttribute = .forceRightToLeft
        uploadButton.setImage(UIImage(named:"Accept-Upload")?.withRenderingMode(.alwaysOriginal), for: UIControl.State())
        uploadButton.addTarget(self, action: #selector(uploading), for: .touchUpInside)
        view.addSubview(uploadButton)

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

    @objc func cancel() {
		dismiss(animated: true, completion: nil)
	}
    
    @objc func uploading() {
        
        self.progressBarView.isHidden = false

        let imageData = self.backgroundImage.jpegData(compressionQuality: 0.8)
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            var goal = "none"
            var URL : String?
            URL = nil
            var type : String?
            type = nil
            
            if defaults.string(forKey: "settings_action") != nil {
                print("settings_action!!!!")
                defaults.removeObject(forKey: "settings_action")
                
                URL = "https://beheer.mijnbewijsstukken.nl/api/swift/profilephoto?api_token="+token
                type = "photo"
            }
            
            if defaults.string(forKey: "goal_id") != nil {
                goal = defaults.string(forKey: "goal_id")!
                URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completion/"+goal+"?api_token="+token
                type = "goal"
            }
            
            
            if defaults.string(forKey: "report_slug") != nil {
                print("report_slug!!!!")
                let report_id = defaults.string(forKey: "report_slug")!
                URL = "https://beheer.mijnbewijsstukken.nl/api/swift/report-completion/"+report_id+"?api_token="+token
                type = "report"
            }
            
            print(URL)
            print(type)
            
            if(URL != nil) {
                
                print(URL!)
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData!, withName: "photo", fileName: "photo.jpg",mimeType: "image/jpeg")
                }, usingThreshold: UInt64.init(),
                   to: URL!,
                      method: .post, headers: nil) { encodingResult in
                        switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
//                                    debugPrint(response)
                                    self.progressBarView.isHidden = true
                                    
                                    let defaults = UserDefaults.standard
                                    
                                    if(type == "goal") {
                                        defaults.set(true, forKey: "completed")
                                        
                                        self.events.trigger(eventName: "newCompletions", information: "New Photo is added!");
                                        // HERE
                                        
        //                                self.dismiss(animated: true, completion: nil)
                                        self.dismiss(animated: true, completion: {
                                            self.delegate?.completeUploadPhoto(true)
                                        })
                                    }
                                    if(type == "report") {
                                        print("TYPE REPORT OCMPLETE")
                                        // HERE
                                        
                                        // self.dismiss(animated: true, completion: nil)
                                        self.dismiss(animated: true, completion: {
                                            self.delegate?.completeUploadPhotoReport(true)
                                        })
                                    }
                                    if(type == "photo") {
                                        print("PHOTOTOEVOEGED")
//                                        print(response.result)
                                        
                                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        let innerPage: MainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "mainBoardId") as! MainNavigationVC
                                        self.present(innerPage, animated: true, completion: nil)
    //                                    defaults.set(response.data, forKey: "user_photo")
    //                                    self.dismiss(animated: true, completion: nil)
                                    }
                                }
                                upload.uploadProgress { progress in
                                    self.progressBarView.value = CGFloat(progress.fractionCompleted*100);
                                }
                            case .failure(let encodingError):
                                print("FAILURE")
                                print(encodingError)
                                self.progressBarView.isHidden = false
                        }
                }
            } else {
                print("NOTHING PHOTO")
            }
        }
    }
}

