//
//  ViewController.swift
//  FWC
//
//  Created by user on 2022/12/7.
//

import UIKit
import WebKit
import DropDown

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // table view outlets
    
    @IBOutlet weak var webTableView: UITableView!
    
    // drop down menu outlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    let dropDown = DropDown()
    let dropDownMenu = ["全部", "一般", "實習", "研究所", "政府", "學校"]
    var dropDownSelected: Int = 0
    
    // picker view
    var pickerViewMenu = ["一般", "實習", "研究所", "政府", "學校"]
    var pickerView = UIPickerView()
    var webType:String = "一般"
    
    var webDataList: [WebInformation] = []
    var tableViewList: [WebInformation] = []
    
    var refreshControl = UIRefreshControl()
    
    var countVal = Int()
    
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
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        webTableView.addSubview(refreshControl)
        typeLabel.text = "全部"
        view.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(addNewWeb), for: .touchUpInside	)
        let isCreated = DBManager.shared.createDB()
//        print(isCreated)
        let openDB = DBManager.shared.openDB()
//        print(openDB)
        
        webTableView.tableFooterView = UIView(frame: .zero)
        webTableView.delegate = self
        webTableView.dataSource = self
        
        webDataList = DBManager.shared.showWebInfoTable()
        if webDataList.count != 0 {
            countVal = webDataList.count
        }
    }	

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dropDown.anchorView = dropDownView
        dropDown.dataSource = dropDownMenu
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y: -(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//          print("Selected item: \(item) at index: \(index)")
            self.typeLabel.text = dropDownMenu[index]
            dropDownSelected = index
            webType = dropDownMenu[index]
            countVal = countWebByType(typeLabel: dropDownMenu[index])
        }
        webDataList = DBManager.shared.showWebInfoTable()
        if webDataList.count != 0 {
//            print(webDataList[0].name)
        }
//        print("-")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBtn.frame = CGRect(x: view.frame.size.width - 90, y: view.frame.size.height - 120, width: 60, height: 60)
    }
    
    @objc func refresh (send: UIRefreshControl) {
        DispatchQueue.main.async {
            self.webTableView.reloadData()
            self.refreshControl.endRefreshing() 
        }
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
            textField.placeholder = "輸入名稱"
            textField.font = UIFont(name: "", size: 24)
        })

        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入網址"
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
            let webName = (alertController.textFields?.first)! as UITextField
            
            let webUrl = (alertController.textFields?.last)! as UITextField
            
            print("網站網址是：\(webUrl.text!)")
            print("網站名稱是：\(webName.text!)")
            print("網站類型是：\(self.webType)")
            
            let isInserted = DBManager.shared.insertWebInfo(webName: webName.text!, webUrl: webUrl.text!, webType: self.webType)
            
            if isInserted {
                print("insert successfully")
                print(self.webDataList)
//                self.webTableView.reloadData()
                self.viewDidAppear(true)
                self.countVal = self.countWebByType(typeLabel: "全部")
                print(self.webDataList)
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
        return pickerViewMenu.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewMenu[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("selected row: \(row)")
        webType = pickerViewMenu[row]
    }
    
    func countWebByType(typeLabel: String) -> Int {
        var count: Int = 0
        tableViewList.removeAll()
        print("tableViewList: \(tableViewList.count)")
        for data in webDataList {
            if data.type == typeLabel {
                print("for loop data: \(data.type)")
                tableViewList.append(data)
                count += 1
            } else if typeLabel == "全部" {
                count += 1
                tableViewList.append(data)
            }
        }
        return count
    }
    
    // table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(countVal)
        return countVal
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = webTableView.dequeueReusableCell(withIdentifier: "WebCell", for: indexPath) as! WebInfoTableViewCell
        print(" cellForRowAt -> typeLabel: \(typeLabel.text!), index: \(indexPath)")
        
        // updata webDataList while counting
        if typeLabel.text == "全部" {
            cell.webName.text = webDataList[indexPath.row].name
            cell.webType.text = webDataList[indexPath.row].type
        } else {
            cell.webName.text = tableViewList[indexPath.row].name
            cell.webType.text = tableViewList[indexPath.row].type
            print("webName: \(cell.webName.text!)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}
