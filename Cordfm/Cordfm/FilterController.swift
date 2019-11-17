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
    let indexMax = 5;
    var currentFilterIndex = 0;
    var currentFilterName = "";
    var videoURL: URL?
    
    var player: AVPlayer?;
    var playerLayer: AVPlayerLayer?;
    var video: hypno_Video?;
    
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
        
        encodeVideo(videoUrl: videoURL!, resultClosure: { response in
            debugPrint(response)
        })
        
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
                
        
        doEverything(scriptName: "air-demo")
        
    }
    
    func doEverything(scriptName: String!){
        // Do any additional setup after loading the view.
         
        
          let scriptFilePath = Bundle.main.path (forResource: scriptName, ofType: "js");
         //let cameraAssetFile = Bundle.main.path(forResource: videoURL?.baseURL?.absoluteString, ofType: "MOV")
         //=print(cameraAssetFile)
         
         let cameraAssetFile = Bundle.main.path(forResource: "video", ofType: "mp4")
              let configuration = hypno_Configuration();
              configuration.script = URL.init (fileURLWithPath: scriptFilePath!);
         configuration.cameraAssets = [URL.init (fileURLWithPath: cameraAssetFile!)];
         video = hypno_Video.create (configuration);
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
         }
        
    }
    
    func encodeVideo(videoUrl: URL, outputUrl: URL? = nil, resultClosure: @escaping (URL?) -> Void ) {

        var finalOutputUrl: URL? = outputUrl

        if finalOutputUrl == nil {
            var url = videoUrl
            url.deletePathExtension()
            url.appendPathExtension(".mp4")
            finalOutputUrl = url
        }

        if FileManager.default.fileExists(atPath: finalOutputUrl!.path) {
            print("Converted file already exists \(finalOutputUrl!.path)")
            resultClosure(finalOutputUrl)
            return
        }

        let asset = AVURLAsset(url: videoUrl)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) {
            exportSession.outputURL = finalOutputUrl!
            exportSession.outputFileType = AVFileType.mp4
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously() {

                switch exportSession.status {
                case .failed:
                    print("Export failed: \(exportSession.error != nil ? exportSession.error!.localizedDescription : "No Error Info")")
                case .cancelled:
                    print("Export canceled")
                case .completed:
                    resultClosure(finalOutputUrl!)
                default:
                    break
                }
            }
        } else {
            resultClosure(nil)
        }
    }


    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            currentFilterIndex += 1;
            if(currentFilterIndex >= indexMax){
                currentFilterIndex = indexMin;
            }
            print("Swipe Left")
            doEverything(scriptName: "basic")
        }
        
        if (sender.direction == .right) {
            currentFilterIndex -= 1;
            if(currentFilterIndex <= indexMin){
                currentFilterIndex = indexMax;
            }
        
            print("Swipe Right")
            doEverything(scriptName: "air-demo")
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

