//
//  RecorderVC.swift
//  PitchPerfect
//
//  Created by Andre Rosa on 07/12/2017.
//  Copyright © 2017 Andre Rosa. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class RecorderVC: UIViewController,VideoVCDelegate {
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var stopRecordingBtn: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    var filePathMP3: String? = nil
    var filePath : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingBtn.isEnabled = false
    }
    
    func customAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isRecording(recording: Bool){
        recordingLabel.text = recording ? "Aan het opnemen..." : "Klik om op te nemen"
        recordBtn.isEnabled = !recording
        stopRecordingBtn.isEnabled = recording
    }
    
    @IBAction func closePopupAudio(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension RecorderVC: AVAudioRecorderDelegate{
    @IBAction func recordAudio(_ sender: Any) {
        isRecording(recording: true)
        self.filePath = nil
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        self.filePath = "\(dirPath)/\(recordingName)"
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
        try! session.setActive(true)
        
        try! audioRecorder = AVAudioRecorder(url: URL.init(fileURLWithPath: filePath!), settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    @IBAction func stopRecording(_ sender: Any) {
        isRecording(recording: false)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            
            let mp3path = self.filePath!.replacingOccurrences(of: "wav", with: "mp3")
            
            let converter = ExtAudioConverter()
            converter.inputFile = self.filePath
            converter.outputFile = mp3path
            converter.outputSampleRate = 44100
            converter.outputFormatID = kAudioFormatMPEGLayer3
            converter.outputFileType = kAudioFileMP3Type
            let isSuccess = converter.convert()
            
            if isSuccess{
                let newVC = VideoViewController(videoURL: URL.init(fileURLWithPath: mp3path))
                newVC.delegate = self
                newVC.isFromAudio = true
                self.present(newVC, animated: true, completion: nil)
            }
            
        } else {
            customAlert(title: "Oops...", message: "Er waren problemen tijdens het opnemen.")
            print("ANDRE: Problem Recording")
            
        }
    }
    
    func completeUploadVideo(_ isSuccess: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil, userInfo: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
}







