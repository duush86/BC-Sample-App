//
//  ViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit

let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM32nL1Ic9gyo3bITy-1QWVkCxdmpEw9LLw3BrW7TwxPPCaWEq5OoIRzx9E3ydeeS2uir3OOi2ziy2Dh5NjlAqavWfSjyFXkTtHB69KQkyc0-FAXel3bqWzTFdMuFXy0RjhXsecd"
let kViewControllerAccountID = "6030890615001"

let imaPublishID = ""
let imaLanguage = "en"
let imaAdTagURL = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&correlator="

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var arrayOfDemos =  Array<Demo>()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setValuesForDemos()
    }

    
    
    //MARK - Table view delegate methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfDemos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = arrayOfDemos[indexPath.row].name        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch arrayOfDemos[indexPath.row].loadWithActivity {
        case "VideoViewController":
            performSegue(withIdentifier: "toBasicVideo", sender: self)
        case "BCIMAViewController":
            performSegue(withIdentifier: "toIMAVideo", sender: self)
        case "PlaylistViewController":
            performSegue(withIdentifier: "toPlaylist", sender: self)
        default:
            print("default")
        }
    }

    func setValuesForDemos() {
        arrayOfDemos = [Demo(withName: "Simple Demo", withContent_id: "6054855884001", withActivity: "VideoViewController"),
                        Demo(withName: "IMA Integration Demo", withContent_id: "6056595896001", withActivity: "BCIMAViewController"),
                        Demo(withName: "Yet another Simple Demo", withContent_id: "6054851890001", withActivity: "VideoViewController"),
                        Demo(withName: "Playlist Demo", withContent_id: "6054762298001", withActivity: "PlaylistViewController")  ]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toBasicVideo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! VideoViewController
                destinationVC.selectedDemo = arrayOfDemos[indexPath.row]
            }
        } else if segue.identifier == "toIMAVideo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! BCIMAViewController
                destinationVC.selectedDemo = arrayOfDemos[indexPath.row]
            }
            
        } else if segue.identifier == "toPlaylist" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! PlaylistViewController
                destinationVC.selectedDemo = arrayOfDemos[indexPath.row]
            }

            
        }
    }
}

