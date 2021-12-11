//
//  DocumentScannerVC.swift
//  MijnBewijsstukken
//
//  Created by admin on 9/4/17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
protocol DocumentScannerVCDelegate: class {
    func completeUploadScanedDocument(_ isSuccess: Bool)
}
class DocumentScannerVC: UIViewController, DocumentScanResultVCDelegate {

    @IBOutlet var scannerView: SobrCameraView!
    private var capturedImage : UIImage?
    
    @IBOutlet weak var rotateImg: UIImageView!
    @IBOutlet var rotateDevice: [UIImageView]!
    
    weak var delegate: DocumentScannerVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scannerView.setupCameraView()
        self.scannerView.borderDetectionEnabled = true
        self.scannerView.borderDetectionFrameColor = UIColor(red:0.2, green:0.6, blue:0.86, alpha:0.5)
        
        if UIDevice.current.orientation.isLandscape {
            self.rotateImg.isHidden = false
        } else {
            self.rotateImg.isHidden = true
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scannerView.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.scannerView.stop()
    }
    
//    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        print("willRotate!")
        self.rotateImg.isHidden = true
        if(true) {
            switch UIDevice.current.orientation{
                case .portrait:
                    print("portrait")
                    self.rotateImg.isHidden = true
                case .portraitUpsideDown:
                    print("portraitUpsideDown")
                    self.rotateImg.isHidden = true
                case .landscapeLeft:
                    print("landscapeLeft")
                    self.rotateImg.isHidden = false
                case .landscapeRight:
                    print("landscapeRight")
                    self.rotateImg.isHidden = false
                default:
                    self.rotateImg.isHidden = false
                    print("DEFAULT")
            }
        }
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.portrait
//    }
    
//    override var shouldAutorotate: Bool {
//        return false;
//    }
//
    @IBAction func captureImage(_ sender: Any) {
        self.scannerView.captureImage { (image, feature) -> Void in
            
            self.capturedImage = image
            self.performSegue(withIdentifier: "segueDocScanResult", sender: nil)
        
        }
    }

    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
     MARK: - Navigation

     In a storyboard-based application, you will often want to do a little preparation before navigation
    */
//    DocumentScannerResultVC Delegate
    func completeUploadScanResult(_ isSuccess: Bool) {
        self.dismiss(animated: true, completion: {
            self.delegate?.completeUploadScanedDocument(true);
        })

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDocScanResult" {
            
            let vc : DocumentScanResultVC = segue.destination as! DocumentScanResultVC
            vc.delegate = self
            vc.capturedImage = self.capturedImage;
            
        }
    }
 

}
