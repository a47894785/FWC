//
//  ViewController.swift
//  FWC
//
//  Created by user on 2022/12/7.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var	 hello:String
    }


    @IBAction func navegateToWebsite(_ sender: Any) {
        if let url	= URL(string: "https://www.youtube.com/?hl=zh-tw") {
            UIApplication.shared.open(url)
        }
        
        
        
    }
    @IBAction func addNewWeb(_ sender: Any) {
        
    
        
    }
}
