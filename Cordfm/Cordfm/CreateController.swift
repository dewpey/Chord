//
//  FirstViewController.swift
//  Cordfm
//
//  Created by Drew Patel on 11/16/19.
//  Copyright © 2019 Drew Patel. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet var swipeLabel: UILabel!
    let indexMin = 0;
    let indexMax = 5;
    var currentFilterIndex = 0;
    var currentFilterName = "";
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
        // Do any additional setup after loading the view.
    }

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            currentFilterIndex -= 1;
            if(currentFilterIndex <= indexMin){
                currentFilterIndex = indexMax;
            }
            print("Swipe Left")
            let labelPosition = CGPoint(x: swipeLabel.frame.origin.x - 50.0, y: swipeLabel.frame.origin.y)
            swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: swipeLabel.frame.size.width, height: swipeLabel.frame.size.height)
        }
        
        if (sender.direction == .right) {
            currentFilterIndex += 1;
            if(currentFilterIndex >= indexMax){
                currentFilterIndex = indexMin;
            }
            print("Swipe Right")
            let labelPosition = CGPoint(x: self.swipeLabel.frame.origin.x + 50.0, y: self.swipeLabel.frame.origin.y)
            swipeLabel.frame = CGRect(x: labelPosition.x, y: labelPosition.y, width: self.swipeLabel.frame.size.width, height: self.swipeLabel.frame.size.height)
        }
    }
    
}

