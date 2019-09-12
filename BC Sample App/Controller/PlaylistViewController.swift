//
//  PlaylistViewController.swift
//  BC Sample App
//
//  Created by Antonio Orozco on 9/12/19.
//  Copyright © 2019 Antonio Orozco. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController {
    var selectedDemo: Demo?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let path = Bundle.main.path(forResource: "BC", ofType: "plist")
        let  API_Keys = NSDictionary(contentsOfFile: path!)
        let CLIENT_ID = API_Keys!["ClientID"] ?? "nil"
        let SECRET_ID = API_Keys!["SecretID"] ?? "nil"
        
        print(CLIENT_ID)
        print(SECRET_ID)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
