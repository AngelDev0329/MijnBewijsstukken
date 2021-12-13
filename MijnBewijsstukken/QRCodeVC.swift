//
//  QRCodeVC.swift
//  MijnBewijsstukken
//
//  Created by KpStar on 7/19/18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import Alamofire
protocol QRCodeVCDelegate: class {
    func didScanResult(_ result: QRCodeReaderResult)
}

class QRCodeVC: UIViewController, QRCodeReaderViewControllerDelegate {
    weak var delegate: QRCodeVCDelegate?

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        
        reader.stopScanning()
        self.delegate?.didScanResult(result)
        dismiss(animated: true, completion: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr], captureDevicePosition: .back)
            
//            $0.cancelButtonTitle = "Annuleren"
//            let readerView = QRCodeReaderContainer(displayable: MyReaderView())
//
//            $0.readerView = readerView
            
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = true
            $0.showCancelButton       = true
            $0.cancelButtonTitle        = "Annuleren"
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readerVC.delegate = self
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in

        }
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: false, completion: nil)
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        let cameraName = newCaptureDevice.device.localizedName
        print("Switching capturing to: \(cameraName)")
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        self.dismiss(animated: false, completion: nil)
        
    }
}
