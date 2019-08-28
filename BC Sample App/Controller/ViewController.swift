//
//  ViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 8/28/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit

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
        //cell.textLabel?.text = "This is row \(indexPath.row)"
        cell.textLabel?.text = arrayOfDemos[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch arrayOfDemos[indexPath.row].loadWithActivity {
        case "VideoViewController":
            performSegue(withIdentifier: "toBasicVideo", sender: self)
        case "AdvertisingViewController":
            performSegue(withIdentifier: "toAdvertisingVideo", sender: self)
        default:
            print("default")
        }
    }

    func setValuesForDemos() {
        arrayOfDemos = [Demo(withName: "Simple Demo", withContent_id: "6054855884001", withActivity: "VideoViewController"),
                        Demo(withName: "Another Simple Demo", withContent_id: "6056595896001", withActivity: "AdvertisingViewController"),
                        Demo(withName: "Yet another Simple Demo", withContent_id: "6054851890001", withActivity: "VideoViewController") ]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toBasicVideo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! VideoViewController
                destinationVC.selectedDemo = arrayOfDemos[indexPath.row]
            }
        } else if segue.identifier == "toAdvertisingVideo" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationVC = segue.destination as! AdvertisingViewController
                destinationVC.selectedDemo = arrayOfDemos[indexPath.row]
            }
        }
    }
}

