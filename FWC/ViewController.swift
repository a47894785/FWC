//
//  ViewController.swift
//  FWC
//
//  Created by user on 2022/12/7.
//

import UIKit
import WebKit
import DropDown

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    // drop down menu outlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    let dropDown = DropDown()
    let dropDownMenu = ["一般", "實習", "研究所", "政府", "學校"]
    var dropDownSelected: Int = 0
    
    // picker view
    var pickerView = UIPickerView()
    var webType = String()
    
    // floating Button
    private let addBtn: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.backgroundColor =  #colorLiteral(red: 0.2320531011, green: 0.2503858805, blue: 0.3496725261, alpha: 1)
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        button.layer.cornerRadius = 30
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(addNewWeb), for: .touchUpInside	)
        let isCreated = DBManager.shared.createDB()
        print(isCreated)
        let openDB = DBManager.shared.openDB()
        print(openDB)
    }	

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("-\n|===========| - viewDidAppear - |===========|")
        typeLabel.text = dropDownMenu[dropDownSelected]
        dropDown.anchorView = dropDownView
        dropDown.dataSource = dropDownMenu
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y: -(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            self.typeLabel.text = dropDownMenu[index]
            dropDownSelected = index
        }
        DBManager.shared.showWebInfoTable()
        print("\n-")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBtn.frame = CGRect(x: view.frame.size.width - 90, y: view.frame.size.height - 120, width: 60, height: 60)
    }
    
    
    @IBAction func showDropMenu(_ sender: Any) {
        dropDown.show()
    }
    
//    @IBAction func navegateToWebsite(_ sender: Any) {
//        DBManager.shared.showWebInfoTable()
//        self.viewDidAppear(true)
//    }
    
    
    @objc private func addNewWeb(_ sender: Any) {
        
        let alertController = UIAlertController(title: "新增常用網站", message: "輸入資訊\n\n\n\n", preferredStyle: .alert)
        
        // text input
        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入網址"
            textField.font = UIFont(name: "S", size: 24)
        })

        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入名稱"
            textField.font = UIFont(name: "", size: 24)
        })
        
        // picker view
        let pickerFrame = UIPickerView(frame: CGRect(x: 10, y: 60, width: 250, height: 80))
        pickerFrame.setValue(UIColor.orange, forKey: "textColor")
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        // cancel button
        let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            print("Cancel button pressed!")
            self.viewDidAppear(true)
        })
        
        
        // confirm button
        let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
            let webUrl = (alertController.textFields?.first)! as UITextField
            
            let webName = (alertController.textFields?.last)! as UITextField
            
            print("網站網址是：\(webUrl.text!)")
            print("網站名稱是：\(webName.text!)")
            print("網站類型是：\(self.webType)")
            
            let isInserted = DBManager.shared.insertWebInfo(webName: webName.text!, webUrl: webUrl.text!, webType: self.webType)
            
            if isInserted {
                print("insert successfully")
            } else {
                print("insert failed")
            }
            self.viewDidAppear(true)
        })
        
        alertController.view.addSubview(pickerFrame)
        alertController.addAction(confirmAct)
        alertController.addAction(cancelAct)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dropDownMenu.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dropDownMenu[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        webType = dropDownMenu[row]
    }
    
}
