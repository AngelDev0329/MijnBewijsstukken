//
//  mySwiftyCam.swift
//  MijnBewijsstukken
//
//  Created by Admin on 8/26/17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol mySwiftyCamDelegate: class {
    func completeUploadFile(_ isSuccess: Bool)
    func completeUploadFileReport(_ isSuccess: Bool)
}


class mySwiftyCam: SwiftyCamViewController, SwiftyCamViewControllerDelegate, PhotoVCDelegate, VideoVCDelegate {
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: mySwiftyCamDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraDelegate = self
        maximumVideoDuration = 120.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        
        //        captureButton.drawButton()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
        
    }
    
    @objc func cancel() {
        // MBS-284
        print("CANCELLING MYSWIFTYCAM")
        //          self.dismiss(animated: false, completion: nil)
        let defaults = UserDefaults.standard
        if let opened_settings = defaults.string(forKey: "opened_settings")
        {
            defaults.removeObject(forKey: "opened_settings")
            let innerPage = self.storyboard?.instantiateViewController(withIdentifier: "mainBoardId")
            UIApplication.shared.keyWindow?.rootViewController = innerPage
        } else {
            print("Niet settings")
        }
        //
        self.dismiss(animated: true, completion: {
            print("VERDWENEN")
            //            if let foo : LearningObjectVC {
            //                foo.getCompletions()
            //            }
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = PhotoViewController(image: photo)
        newVC.delegate = self
        self.present(newVC, animated: true, completion: nil)
    }
    //    PhotoViewController Delegate
    func completeUploadPhoto(_ isSuccess: Bool) {
        if(isSuccess){
            dismiss(animated: true, completion: {
                self.delegate?.completeUploadFile(isSuccess)
            })
        }
    }
    
    func completeUploadPhotoReport(_ isSuccess: Bool) {
        print("MYSWIFT completeUploadPhotoReport")
        if(isSuccess){
            dismiss(animated: true, completion: {
                self.delegate?.completeUploadFileReport(isSuccess)
            })
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //        captureButton.drawButton()
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            //       captureButton.doOrientationLandscape()
            
        } else {
            print("Portrait")
            //            captureButton.doOrientationPortrait()
        }
        //captureButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        //captureButton.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
    }
    
    // VideoViewController Delegate
    func completeUploadVideo(_ isSuccess: Bool) {
        if(isSuccess){
            dismiss(animated: true, completion: {
                self.delegate?.completeUploadFile(isSuccess)
            })
        }
        
    }
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        captureButton.growButton()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        captureButton.shrinkButton()
        UIView.animate(withDuration: 0.25, animations: {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        
        self.convertToMP4(url)
        
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }, completion: { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }, completion: { (success) in
                focusView.removeFromSuperview()
            })
        })
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        flashEnabled = !flashEnabled
        
        if flashEnabled == true {
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        } else {
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        }
    }
    
    func convertToMP4(_ videoURL: URL)  {
        
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        
        let startDate = Foundation.Date()
        
        //Create Export session
        var exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough)
        
        // exportSession = AVAssetExportSession(asset: composition, presetName: mp4Quality)
        //Creating temp path to save the converted video
        
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.mp4").absoluteString
        
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        
        let filePath = documentsDirectory2.appendingPathComponent("rendered-Video.mp4")
        deleteFile(filePath)
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: myDocumentPath) {
            do {
                try FileManager.default.removeItem(atPath: myDocumentPath)
            }
            catch let error {
                print(error)
            }
        }
        
        exportSession!.outputURL = filePath
        exportSession!.outputFileType = AVFileType.mp4
        exportSession!.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession!.timeRange = range
        
        exportSession!.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession!.status {
            case .failed:
                print("%@",exportSession?.error as Any)
            case .cancelled:
                print("Export canceled")
            case .completed:
                //Video conversion finished
                let endDate = Foundation.Date()
                
                let time = endDate.timeIntervalSince(startDate)
                print(time)
                print("Successful!")
                print(exportSession!.outputURL as Any)
                
                let newVC = VideoViewController(videoURL: exportSession!.outputURL!)
                newVC.delegate = self
                self.present(newVC, animated: true, completion: nil)
                
            default:
                break
            }
            
        })
        
        
    }
    
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return
        }
        
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
}


