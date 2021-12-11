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
import AVFoundation
import AVKit
import MBCircularProgressBar
import Alamofire

protocol VideoVCDelegate: class {
    func completeUploadVideo(_ isSuccess: Bool)
}

class VideoViewController: UIViewController {
    weak var delegate: VideoVCDelegate?

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var videoURL: URL
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var isFromAudio : Bool = false
    private var progressBarView : MBCircularProgressBarView!;
    
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        player = AVPlayer(url: videoURL)
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        
        playerController!.player = player!
        self.addChild(playerController!)
        self.view.addSubview(playerController!.view)
        playerController!.view.frame = view.frame
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    
    @objc func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploading() {
        self.progressBarView.isHidden = false
        self.player?.pause()
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            
            var URL : String?
            URL = nil
            
            if defaults.string(forKey: "goal_id") != nil {
                URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completion/"+defaults.string(forKey: "goal_id")!+"?api_token="+token
            }
            
            if defaults.string(forKey: "report_slug") != nil {
                print("report_slug!!!!")
                let report_id = defaults.string(forKey: "report_slug")!
                URL = "https://beheer.mijnbewijsstukken.nl/api/swift/report-completion/"+report_id+"?api_token="+token
            }
            
            if(URL != nil) {
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(self.videoURL, withName: self.isFromAudio ? "audio":"video")
                }, usingThreshold: UInt64.init(),
                   to: URL!,
                   method: .post, headers: nil) { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            self.progressBarView.isHidden = true
                            
                            let defaults = UserDefaults.standard
                            defaults.set(true, forKey: "completed")
                            
                            self.dismiss(animated: true, completion: {
                                self.delegate?.completeUploadVideo(true)
                            })
                        }
                        upload.uploadProgress { progress in
                            self.progressBarView.value = CGFloat(progress.fractionCompleted*100);
                        }
                    case .failure(let encodingError):
                        print(encodingError)
                        self.progressBarView.isHidden = true
                    }
                }
            }
        }
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
    }
}
