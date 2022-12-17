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
        let isCreated = DBManager.shared.createDB()
        print(isCreated)
        let openDB = DBManager.shared.openDB()
        print(openDB)
    }


    @IBAction func navegateToWebsite(_ sender: Any) {
        if let url	= URL(string: "https://www.youtube.com/?hl=zh-tw") {
            UIApplication.shared.open(url)
        }
        
        
        
    }
    @IBAction func addNewWeb(_ sender: Any) {
        
        let alertController = UIAlertController(title: "新增常用網站", message: "輸入資訊", preferredStyle: .alert)
        // cancel button
        let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: {(action: UIAlertAction!) -> Void in print("Cancel button pressed!")})
        alertController.addAction(cancelAct)
        
        // text input
        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入網址"
        })
        
        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入名稱"
        })
        
        // confirm button
        let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
            let webUrl = (alertController.textFields?.first)! as UITextField
            
            let webName = (alertController.textFields?.last)! as UITextField
            
            print("網站網址是：\(webUrl.text!)")
            print("網站名稱是：\(webName.text!)")
            
        })
        alertController.addAction(confirmAct)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
