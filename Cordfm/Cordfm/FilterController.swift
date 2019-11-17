//
//  FirstViewController.swift
//  Cordfm
//
//  Created by Drew Patel on 11/16/19.
//  Copyright © 2019 Drew Patel. All rights reserved.
//

import UIKit

class FilterController: UIViewController {

    @IBOutlet var pagination: UIPageControl!
    let indexMin = 0;
    let indexMax = 3;
    var currentFilterIndex = 0;
    var currentFilterName = "";
    var videoURL: String?
    
    var player: AVPlayer?;
    var playerLayer: AVPlayerLayer?;
    var video: hypno_Video?;
    
    var shareURL: String!
    
    @IBOutlet var previewView: UIView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        pagination.numberOfPages = indexMax
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let press = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        view.addGestureRecognizer(press)

        print(videoURL)
        
        /*
        encodeVideo(videoUrl: videoURL!, resultClosure: { response in
            debugPrint(response)
        })
        */
        
        hypno_Platform.setOnSystemLog  { (message: String) in
                    print (message);
                };
                
        hypno_Platform.setOnConsoleLog  { (message: String) in
            print (message);
        };
        
        playerLayer = AVPlayerLayer();
        playerLayer!.backgroundColor = UIColor.black.cgColor;
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspect;
        previewView.layer.addSublayer(playerLayer!)
                
        
        doEverything(scriptName: "template1")
        
    }
    
    func doEverything(scriptName: String!){
        // Do any additional setup after loading the view.
         
        
          let scriptFilePath = Bundle.main.path (forResource: scriptName, ofType: "js");
         //let cameraAssetFile = Bundle.main.path(forResource: videoURL?.baseURL?.absoluteString, ofType: "MOV")
         //=print(cameraAssetFile)
         
         let configuration = hypno_Configuration();
         configuration.script = URL.init (fileURLWithPath: scriptFilePath!);
         configuration.cameraAssets = [URL.init (fileURLWithPath: videoURL!)];
         video = hypno_Video.create (configuration);
        //videoCompositionInstruction(video?.composition)
         if video == nil || !video!.error.isEmpty {
             print ("Error")
             print (video!.error);
         }
         else {
            print(video!.composition)
            
            let compositionPlayerItem = AVPlayerItem(asset: video!.composition);
    
             compositionPlayerItem.videoComposition = video!.videoComposition;
             compositionPlayerItem.audioMix = video!.audioMix;
             let defaultCenter = NotificationCenter.default;
             if player != nil {
                 defaultCenter.removeObserver (self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem);
             }
             
             player = AVPlayer(playerItem: compositionPlayerItem);
             player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none;
             defaultCenter.addObserver (self, selector: #selector (self.playerItemDidPlayToEndTime(note:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
             
            playerLayer!.player = player;
            player?.play();
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let videoPath = documentsPath+"/Chord.mov"


            let fileManager = FileManager.default

            if fileManager.fileExists(atPath: videoPath)
            {
                try! fileManager.removeItem(atPath: videoPath)
            }

            print("video path \(videoPath)")

            var exportSession = AVAssetExportSession.init(asset: video!.composition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.videoComposition = video!.videoComposition
            exportSession?.outputFileType = AVFileType.mov
            exportSession?.outputURL = URL.init(fileURLWithPath: videoPath)
            var exportProgress: Float = 0
            let queue = DispatchQueue(label: "Export Progress Queue")
            queue.async(execute: {() -> Void in
                while exportSession != nil {
                    //                int prevProgress = exportProgress;
                    exportProgress = (exportSession?.progress)!
                    print("current progress == \(exportProgress)")
                    sleep(1)
                }
            })

            exportSession?.exportAsynchronously(completionHandler: {


                if exportSession?.status == AVAssetExportSession.Status.failed
                {
                    print("Failed \(exportSession?.error)")
                }else if exportSession?.status == AVAssetExportSession.Status.completed
                {
                    UISaveVideoAtPathToSavedPhotosAlbum((exportSession?.outputURL?.path)!, self, nil, nil)
                    self.shareURL = (exportSession?.outputURL?.path)!
                        
                }
            })
            
         }
        
    }
    
    @IBAction func handleShare(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [NSURL(fileURLWithPath: shareURL)], applicationActivities: nil)
                activityVC.excludedActivityTypes = [.addToReadingList, .assignToContact]
            DispatchQueue.main.async { [weak self] in
              // 3
                self!.present(activityVC, animated: true, completion: nil)
            }
    }
    

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            currentFilterIndex += 1;
            if(currentFilterIndex >= indexMax){
                currentFilterIndex = indexMin;
            }
            print("Swipe Left")
        }
        
        if (sender.direction == .right) {
            currentFilterIndex -= 1;
            if(currentFilterIndex <= indexMin){
                currentFilterIndex = indexMax;
            }
        
            print("Swipe Right")
        }
        
        switch(currentFilterIndex){
            case 0:
                doEverything(scriptName: "template1");
                break;
            case 1:
                doEverything(scriptName: "template1");
                break;
            case 2:
                doEverything(scriptName: "template2");
                break;
            case 3:
                doEverything(scriptName: "template3");
                break;
                
        default:
            break;
        }
        
        pagination.currentPage = currentFilterIndex
    }
    
    @objc func handlePress(_ sender:UILongPressGestureRecognizer) {
        print("Press")
    }
    
    override func viewDidLayoutSubviews() {
           playerLayer?.frame = self.view.bounds;
       }
       
   @objc func playerItemDidPlayToEndTime (note: NSNotification) {
       let p = note.object as! AVPlayerItem;
       p.seek (to: CMTime.zero, completionHandler: nil);
   }
    
}

