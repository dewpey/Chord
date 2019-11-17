//
//  HomeViewController.swift
//  Cordfm
//
//  Created by Drew Patel on 11/17/19.
//  Copyright © 2019 Drew Patel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class customCell: UITableViewCell {
    
    @IBOutlet var cellView: UIView!
    @IBOutlet var artistImage: UIImageView!
    @IBOutlet var mainText: UILabel!
    @IBOutlet var secondaryText: UILabel!
}

class HomeViewController: UITableViewController {

    var allEvents: [Event] = []
    var allArtists: [Artist] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        self.tableView.dataSource = self
        
        let headers: HTTPHeaders = [
          "x-api-key": "nTG4tbSXpIaniCHlJ62q06GzIpROk6qh56EiK7N1"
        ]
       
        
        let url = "https://search.bandsintown.com/search?query=%7B%22term%22%3A%22Los%20Angeles%22%2C%22entities%22%3A%5B%7B%22type%22%3A%22event%22%7D%5D%2C%22scopes%22%3A%5B%22event%22%5D%7D"
        Alamofire.request(url,method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                print("JSON: \(json["events"])")
                
                let embeddables = json["_embedded"]
                
                for event in json["events"].arrayValue {
                    let tempEvent = Event(json: event, embeddables: embeddables)
                    self.allEvents.append(tempEvent)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    //Called, when long press occurred
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {

        if sender.state == UIGestureRecognizer.State.began {

            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                print(indexPath)
                
                // your code here, get the row for the indexPath or do whatever you want
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allEvents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Event = self.allEvents[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! customCell

        cell.mainText.text = item.artistName + "-" + item.title
        cell.secondaryText.text = item.getDateString()
        
        cell.layer.cornerRadius = 20
         cell.clipsToBounds = true
        
        let url = URL(string: item.imageUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Failed fetching image:", error)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                return
            }
            

            DispatchQueue.main.async {
                cell.artistImage.image = UIImage(data: data!)
                let tempColor = cell.artistImage.image?.averageColor(alpha: 1.0)
                cell.cellView.backgroundColor = tempColor
            }
        }.resume()

        return cell
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
          let vc = segue.destination as! RecordVideoViewController
        vc.event = allEvents[selectedIndex!.row]
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


}

extension UIImage {

 func averageColor(alpha : CGFloat) -> UIColor {

    let rawImageRef : CGImage = self.cgImage!
    let  data : CFData = rawImageRef.dataProvider!.data!
    let rawPixelData  =  CFDataGetBytePtr(data);

    let imageHeight = rawImageRef.height
    let imageWidth  = rawImageRef.width
    let bytesPerRow = rawImageRef.bytesPerRow
    let stride = rawImageRef.bitsPerPixel / 8

    var red = 0
    var green = 0
    var blue  = 0




    for row in 0...imageHeight {
        var rowPtr = rawPixelData! + bytesPerRow * row
        for _ in 0...imageWidth {
            red    += Int(rowPtr[0])
            green  += Int(rowPtr[1])
            blue   += Int(rowPtr[2])
            rowPtr += Int(stride)
        }
    }

    let  f : CGFloat = 1.0 / (255.0 * CGFloat(imageWidth) * CGFloat(imageHeight))
    return UIColor(red: f * CGFloat(red), green: f * CGFloat(green), blue: f * CGFloat(blue) , alpha: alpha)
 }
}
