//
//  FormFilesVC.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 23-03-18.
//  Copyright © 2018 Wndworks. All rights reserved.
//

import UIKit
import Floaty
import AVFoundation
import AlamofireObjectMapper
import Alamofire
import AlamofireImage
import Agrume
import MobileCoreServices
import AVKit
import AVFoundation

class FormFilesVC:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, mySwiftyCamDelegate,DocumentScannerVCDelegate,PhotoVCDelegate,VideoVCDelegate{
    
    //Hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var FormFilesCollectionView: UICollectionView!
    
    @IBOutlet weak var reportTitle: UILabel!
    let uploadedImages: [Any] = ["1", "2", "3"]
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var completes_list: [Any] = []
    var completes_list_types: [Any] = []
    var completes_list_files: [Any] = []
    var completes_list_ids: [Int] = []
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add toolbar
        addGeneralToolbarItems()
        
        self.FormFilesCollectionView.delegate = self
        self.FormFilesCollectionView.dataSource = self
        
        //Set collection sizes
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let containerHeight = screenHeight - 250 // Toptitle 130 + Toolbar 60 + inset below
        let containerWidth = screenWidth // Inset below
        let itemWidth = containerWidth * 0.2
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: itemWidth, height: containerHeight / 2)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .vertical
        FormFilesCollectionView.collectionViewLayout = layout
        
        self.addFloaty(_completes: 0)
        
        //Back button
        cancelButton.addTarget(self, action: #selector(self.goBack), for: UIControl.Event.touchUpInside)
        
        //Swipe gestures
        
        /*let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
         swipeRight.direction = .right
         self.view.addGestureRecognizer(swipeRight)*/
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        let defaults = UserDefaults.standard
        self.reportTitle.text = defaults.string(forKey: "report_title")
        
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name(rawValue: "reload"), object: nil)
    }
    
    @objc func reloadData()
    {
        self.reloadCompletions()
    }
    
    func addFloaty(_completes :Int) {
        //Main styling Floaty button
        let floaty = Floaty()
        floaty.buttonImage = UIImage(named: "Add-File")
        floaty.size = 80
        floaty.hasShadow = false
        floaty.buttonColor = UIColor(white: 1, alpha: 0)
        floaty.itemSize = 66
        floaty.itemSpace = 20
        floaty.paddingX = 40 //center > self.view.frame.width/2 - floaty.frame.width/2
        floaty.paddingY = 40
        floaty.hasShadow = true
        floaty.overlayColor = UIColor(red: 18/255, green: 88/255, blue: 105/255, alpha: 0.6)
        
        
        //        floaty.addItem("Document", icon: UIImage(named: "Add-Scan")!, handler: { item in
        //            self.performSegue(withIdentifier: "segueDocScanner", sender: nil)
        //        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.addItem("Foto/Video", icon: UIImage(named: "Add-Cam")!, handler: { item in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller : mySwiftyCam  = storyboard.instantiateViewController(withIdentifier: "mySwiftCamStoryboardId") as! mySwiftyCam
            controller.delegate = self
            self.present(controller, animated: false, completion: nil)
        }).imageSize = CGSize(width: 66, height: 66)
        
//        floaty.addItem("Audio", icon: UIImage(named: "Add-Audio")!, handler: { item in
//            // let alert = UIAlertController(title: "Audio opnemen?", message: "Dit kan binnenkort!", preferredStyle: UIAlertControllerStyle.alert)
//            // alert.addAction(UIAlertAction(title: "Jammer, maar helaas", style: UIAlertActionStyle.default, handler: nil))
//            
//            let alert = UIAlertController(title: "Audio opnemen?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
//            
//            let actionYes = UIAlertAction.init(title: "Ja", style: .default, handler: { (action) in
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let controller : RecorderVC  = storyboard.instantiateViewController(withIdentifier: "RecorderVC") as! RecorderVC
//                self.present(controller, animated: false, completion: nil)
//            })
//            
//            alert.addAction(actionYes)
//            
//            let actionNo = UIAlertAction.init(title: "Nee", style: .default, handler: { (action) in
//                alert.dismiss(animated: true, completion: nil)
//            })
//            
//            alert.addAction(actionNo)
//            
//            
//            self.present(alert, animated: true, completion: nil)
//        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.addItem("Galerij", icon: UIImage(named: "Add-Gallery")!, handler: { item in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary;
                imagePicker.mediaTypes = [ (kUTTypeImage as String),(kUTTypeMovie as String)]
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }).imageSize = CGSize(width: 66, height: 66)
        
        floaty.tag = 1234
        
        
        // https://stackoverflow.com/questions/28197079/swift-addsubview-and-remove-it
        if let viewWithFloaty = self.view.viewWithTag(1234) {
            if _completes >= 3 {
                viewWithFloaty.removeFromSuperview()
            }
        } else {
            self.view.addSubview(floaty)
        }
    }
    
    func purchaseSuccessful() {
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
    }
    
    //    mySwiftyCam Delegate
    func completeUploadFile(_ isSuccess: Bool) {
        print("Form completeUploadFile")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    func completeUploadFileReport(_ isSuccess: Bool) {
        print("Form completeUploadFileReport")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // Document Scanner Delegate
    func completeUploadScanedDocument(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // PhotoVC Delegate
    func completeUploadPhoto(_ isSuccess: Bool) {
        print("Form completeUploadPhoto")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    func completeUploadPhotoReport(_ isSuccess: Bool) {
        print("completeUploadPhotoReport")
        if isSuccess {
            self.reloadCompletions();
        }
    }
    // VideoVC Delegate
    func completeUploadVideo(_ isSuccess: Bool) {
        if isSuccess {
            self.reloadCompletions();
        }
    }
    func reloadCompletions () {
        print("reloadCompletions")
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            self.getCompletions(token: token)
        }
    }
    
    
    func getCompletions(token: String)
    {
        self.completes_list_ids = []
        self.completes_list = []
        self.completes_list_types = []
        self.completes_list_files = []
        
        let defaults = UserDefaults.standard
        let parameters: Parameters = ["api_token": token]
        let report_slug = defaults.string(forKey: "report_slug")
        
        print("GETCOMPLETES")
        let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/report-completes/"+report_slug!
        Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<CompletesResponse>) in
            
            let completeResponse = response.result.value
            if let completes = completeResponse?.completes {
                for complete in completes {
                    self.completes_list_ids.append(complete.id!)
                    self.completes_list.append(complete.path!)
                    self.completes_list_types.append(complete._type!)
                    self.completes_list_files.append(complete.document!)
                }
                
            }
            self.FormFilesCollectionView.reloadData()
            self.activity.stopAnimating()
            print("self.completes_list.count")
            print(self.completes_list.count)
            
            self.addFloaty(_completes: self.completes_list.count)
            
        }
    }
    
    
    @IBAction func deleteCompletion(_ sender: UIButton) {
        print("deleteCompletion")
        let alert = UIAlertController(title: "Verwijderen", message: "Zeker weten dat je dit bewijs wilt verwijderen?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Verwijderen", style: .destructive) { (alert: UIAlertAction!) -> Void in
            let hitPoint = sender.convert(CGPoint.zero, to: self.FormFilesCollectionView)
            if let indexPath = self.FormFilesCollectionView.indexPathForItem(at: hitPoint) {
                print(self.completes_list_ids[indexPath.row])
                print(indexPath)
                let defaults = UserDefaults.standard
                if let token = defaults.string(forKey: "user_token")
                {
                    let id : String = String(self.completes_list_ids[indexPath.row])
                    let parameters: Parameters = ["api_token": token, id: id]
                    
                    let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/completion/"+id
                    Alamofire.request(URL, method: .delete, parameters: parameters)
                        .responseJSON { response in
                            
                            self.completes_list = []
                            self.completes_list_types = []
                            self.completes_list_files = []
                            self.completes_list_ids = []
                            
                            self.getCompletions(token: token)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Annuleren", style: .default) { (alert: UIAlertAction!) -> Void in
            //print("You pressed Cancel")
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion:nil)
    }
    
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    @IBAction func popup(_ sender: UIButton) {
        let hitPoint = sender.convert(sender.center, to: self.FormFilesCollectionView)
        print(hitPoint)
        if let indexPath = self.FormFilesCollectionView.indexPathForItem(at: hitPoint) {
            print(self.completes_list[indexPath.row])
            
            let url = URL(string: self.completes_list_files[indexPath.row] as! String)!
            let data = try? Data(contentsOf: url)
            let typeComplete = self.completes_list_types[indexPath.row] as! String
            if(typeComplete == "photo") {
                if let image: UIImage = UIImage(data: data!) {
                    let agrume = Agrume(image: image, background: .blurred(.light))
                    agrume.show(from: self)
                }
            }
            if(typeComplete == "video") {
                print("VIDEOPRINTER")
                print(url)
                let videoURL = URL(string: self.completes_list_files[indexPath.row] as! String)!
                //                let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!
                let player = AVPlayer(url: videoURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
                
            }
        }
    }
    
    
    
    //    ImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType.rawValue] as! String
        picker.dismiss(animated: false, completion:{
            if (mediaType == (kUTTypeImage as String) ){
                let photo = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
                let photoVC = PhotoViewController(image: photo)
                photoVC.delegate = self
                self.present(photoVC, animated: true, completion: nil)
            }else if(mediaType == (kUTTypeMovie as String) ){
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as! URL
                let videoVC = VideoViewController(videoURL: videoURL)
                videoVC.delegate = self
                self.present(videoVC, animated: true, completion: nil)
            }
        })
        
    }
    
    //Images count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.completes_list.count
    }
    
    //Center cells
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let cellCount = CGFloat(collectionView.numberOfItems(inSection: section))
        
        if cellCount > 0 {
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            
            let totalCellWidth = cellWidth * cellCount
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - flowLayout.headerReferenceSize.width - flowLayout.footerReferenceSize.width
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth + flowLayout.minimumInteritemSpacing) / 2.0
                return UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            }
        }
        
        print("items:", cellCount)
        
        return .zero
    }
    
    /*END CENTER CELLS*/
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FormFilesCell
        
        let typeComplete = self.completes_list_types[indexPath.row] as! String
        
        if(typeComplete == "video") {
            
            print("Video")
            let url = URL(string: self.completes_list_files[indexPath.row] as! String + "&thumb=true")
            if let thumbnailImage = getThumbnailImage(forUrl: url!) {
                cell.fileImage.image = thumbnailImage
            }
        } else {
            let url = URL(string: self.completes_list_files[indexPath.row] as! String)!
            let data = try? Data(contentsOf: url)
            let image: UIImage = UIImage(data: data!)!
            
            cell.fileImage.image = image
        }
        
        cell.fileImage.layer.cornerRadius = cell.fileImage.frame.width/2
        cell.fileImage.layer.masksToBounds = true
        cell.fileImage.clipsToBounds = true
        
        return cell
    }
    
    //Back button
    func popBack(sender:UIBarButtonItem){
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is FormVC {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    //GoBack
    
    @objc func goBack(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Swipe functions
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizer.Direction.right {
            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers
            for aViewController in viewControllers {
                if aViewController is FormVC {
                    self.navigationController!.popToViewController(aViewController, animated: true)
                }
            }
            
        }
            
        else if gesture.direction == UISwipeGestureRecognizer.Direction.down {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension UIImagePickerController
{
    //
}

