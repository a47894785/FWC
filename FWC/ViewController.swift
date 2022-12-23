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
    
    @IBOutlet weak var addNewTypeBtn: UIButton!
    
    // drop down menu outlets
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    let dropDown = DropDown()
    var dataTypeList: [String] = []
    var dropDownSelected: Int = 0
    
    // picker view
    var pickerViewMenu: [String] = []
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
        
        
        // --- gesture recognizer ---
        // long press
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
        longPress.minimumPressDuration = 0.5
        self.webTableView.addGestureRecognizer(longPress)
        // one tap
        let oneTap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        oneTap.numberOfTapsRequired = 1
        self.webTableView.addGestureRecognizer(oneTap)
        // swipe left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftHandler))
        swipeLeft.direction = .left
        self.webTableView.addGestureRecognizer(swipeLeft)
        
        addNewTypeBtn.layer.cornerRadius = 15
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        webTableView.addSubview(refreshControl)
        
        typeLabel.text = "全部"

        webTableView.separatorStyle = .none
        webTableView.showsVerticalScrollIndicator = false
        
        view.addSubview(addBtn)
        addBtn.addTarget(self, action: #selector(addNewWeb), for: .touchUpInside	)
        
        let isCreated = DBManager.shared.createDB()
//        print(isCreated)
        let openDB = DBManager.shared.openDB()
//        print(openDB)
        
        webTableView.tableFooterView = UIView(frame: .zero)
        webTableView.delegate = self
        webTableView.dataSource = self
        
        /* --------- need to reload --------- */
        
        dataTypeList = DBManager.shared.getWebTypeInfo()
        dataTypeList.insert("全部", at: 0)
        pickerViewMenu = Array(dataTypeList[1 ... dataTypeList.count - 1])
        
        webDataList = DBManager.shared.showWebInfoTable()
        if webDataList.count != 0 {
            countVal = webDataList.count
        }
    }	

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webTableView.separatorStyle = .none
        webTableView.showsVerticalScrollIndicator = false
        
        dataTypeList = DBManager.shared.getWebTypeInfo()
        dataTypeList.insert("全部", at: 0)
        webDataList = DBManager.shared.showWebInfoTable()
        if webDataList.count != 0 {
            countVal = webDataList.count
        }
        
        countVal = countWebByType(typeLabel: dataTypeList[dropDownSelected])
        
        pickerViewMenu = Array(dataTypeList[1 ... dataTypeList.count - 1])
        
        webDataList = DBManager.shared.showWebInfoTable()
        
        
        dropDownView.layer.cornerRadius = 15
        dropDown.anchorView = dropDownView
        dropDown.dataSource = dataTypeList
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.topOffset = CGPoint(x: 0, y: -(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.typeLabel.text = dataTypeList[index]
            dropDownSelected = index
            self.typeLabel.text = dataTypeList[index]
            countVal = countWebByType(typeLabel: dataTypeList[index])
            self.autoFresh()
        }
        
        webType = dataTypeList[1]
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
    
    func autoFresh() {
        DispatchQueue.main.async {
            self.webTableView.reloadData()
        }
    }
    
    // handle swipe left gesture
    @objc func swipeLeftHandler(swipeLeft: UISwipeGestureRecognizer) {
        let p = swipeLeft.location(in: self.webTableView)
        let indexPath = self.webTableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("swipe left on table view, not row")
        } else if swipeLeft.direction == .left {
            print("swipe left on row, at \(indexPath!.row)")
            
            // alert controller
            let alertController = UIAlertController(title: "確定要刪除網站嗎", message: "點選確認以刪除網站", preferredStyle: .alert)
            
            // cancel button
            let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            })


            // confirm button
            let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
                let isDeleted = DBManager.shared.deleteWeb(webID: self.tableViewList[indexPath!.row].id)
                
                if isDeleted {
                    self.view.showToast(text: "成功刪除\(self.tableViewList[indexPath!.row].name)")
                }
                self.viewDidAppear(true)
                self.autoFresh()
            })
            alertController.addAction(confirmAct)
            alertController.addAction(cancelAct)
            
            self.present(alertController, animated: true, completion: nil)
        }
        self.viewDidAppear(true)
    }
    
    // handle tap gesture
    @objc func tapHandler(oneTap: UITapGestureRecognizer) {
        
        let p = oneTap.location(in: self.webTableView)
        let indexPath = self.webTableView.indexPathForRow(at: p)
//        print("one tap !! \(indexPath!.row)")
        if indexPath == nil {
            print("tap on table view, not row")
        } else {
            print("tap on row, at \(tableViewList[indexPath!.row].name)")
            let url = URL(string: tableViewList[indexPath!.row].url)!
            UIApplication.shared.open(url)
        }
    }
    
    // handle long press gesture
    @objc func longPressHandler(longPress: UILongPressGestureRecognizer) {
        let p = longPress.location(in: self.webTableView)
        let indexPath = self.webTableView.indexPathForRow(at: p)
//        print("one tap !! \(indexPath!.row)")
        if indexPath == nil {
            print("long press on table view, not row")
        } else if longPress.state == UIGestureRecognizer.State.began {
            
            
            print("long press on row, at \(tableViewList[indexPath!.row].name)")
            
            let alertController = UIAlertController(title: "更新網站資訊", message: "請輸入要更新的網址及名稱", preferredStyle: .alert)
            
            
            // text input
            alertController.addTextField(configurationHandler: {
                (textField: UITextField) -> Void in
                textField.text = self.tableViewList[indexPath!.row].name
                textField.font = UIFont(name: "", size: 24)
            })

            alertController.addTextField(configurationHandler: {
                (textField: UITextField) -> Void in
                textField.text = self.tableViewList[indexPath!.row].url
                textField.font = UIFont(name: "", size: 24)
            })
            
            
            // cancel button
            let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
            })


            // confirm button
            let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
                
                var errorFlag: Bool = false
                var urlError: Bool = false
                var isUpdated: Bool
                
                let newWebName = (alertController.textFields?.first)! as UITextField
                
                let newWebUrl = (alertController.textFields?.last)! as UITextField
                
                if newWebName.text! == "" || newWebUrl.text! == "" {
                    errorFlag = true
                } else {
                    // call verify url
                    urlError = self.verifyUrl(urlString: newWebUrl.text!)
                    
                }
                
                if !errorFlag && urlError {
                    isUpdated = DBManager.shared.updateWebData(webID: self.tableViewList[indexPath!.row].id, newWebName: newWebName.text!, newWebUrl: newWebUrl.text!)
                    
                } else if errorFlag {
                    self.view.showToast(text: "名稱或網址不可為空！")
                    isUpdated = false
                } else {
                    self.view.showToast(text: "無效的網址！")
                    isUpdated = false
                }
                
                if isUpdated {
                    self.view.showToast(text: "網站更新成功，若無更新畫面，請下拉刷新！")
                    
                    self.countVal = self.countWebByType(typeLabel: "全部")
                    self.viewDidAppear(true)
                    self.autoFresh()
                } else {
                    print("insert failed")
                }
                self.viewDidAppear(true)
            })
            
            
            alertController.addAction(confirmAct)
            alertController.addAction(cancelAct)
            
            self.present(alertController, animated: true, completion: nil)
        }
        self.viewDidAppear(true)
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
               if let url = NSURL(string: urlString) {
                   return UIApplication.shared.canOpenURL(url as URL)
               }
           }
       return false
    }
    
    
    @IBAction func showDropMenu(_ sender: Any) {
        dropDown.show()
    }
    
    
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
            self.viewDidAppear(true)
        })
        
        
        // confirm button
        let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
            
            var errorFlag: Bool = false
            var urlError: Bool = false
            var isInserted: Bool
            
            let webName = (alertController.textFields?.first)! as UITextField
            
            let webUrl = (alertController.textFields?.last)! as UITextField
            
            if webName.text! == "" || webUrl.text! == "" {
                errorFlag = true
            } else {
                // call verify url
                urlError = self.verifyUrl(urlString: webUrl.text!)
                
            }
            
            if !errorFlag && urlError {
//                print("網站網址是：\(webUrl.text!)")
//                print("網站名稱是：\(webName.text!)")
//                print("網站類型是：\(self.webType)")
            
                isInserted = DBManager.shared.insertWebInfo(webName: webName.text!, webUrl: webUrl.text!, webType: self.webType)
//                print("--網站類型是：\(self.webType)")
            } else if errorFlag {
                self.view.showToast(text: "名稱或網址不可為空！")
                isInserted = false
            } else {
                self.view.showToast(text: "無效的網址！")
                isInserted = false
            }
            
            if isInserted {
                self.view.showToast(text: "網站新增成功，若無更新畫面，請下拉刷新！")
                
                self.countVal = self.countWebByType(typeLabel: "全部")
                self.viewDidAppear(true)
                self.autoFresh()
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
    
    
    @IBAction func addNewType(_ sender: Any) {
        let alertController = UIAlertController(title: "新增類別", message: "", preferredStyle: .alert)
        
        // text input
        alertController.addTextField(configurationHandler: {
            (textField: UITextField) -> Void in
            textField.placeholder = "輸入類別"
            textField.font = UIFont(name: "", size: 24)
        })
        
        // cancel button
        let cancelAct = UIAlertAction(title: "取消", style: .cancel, handler: {(action: UIAlertAction!) -> Void in
//            self.view.showToast(text: "Cancel button pressed!")
//            print("Cancel button pressed!")
            self.viewDidAppear(true)
        })
        
        // confirm button
        let confirmAct = UIAlertAction(title: "確認", style: .default, handler: {(UIAlertAction) -> Void in
            
            var errorFlag: Bool = false
            var isInserted: Bool
            
            let newType = alertController.textFields![0] as UITextField
            
            if newType.text  == "" {
                errorFlag = true
            }
            
            if !errorFlag {
//                print("newType: \(newType.text!)")
                isInserted = DBManager.shared.insertWebType(type: newType.text!)
            } else {
                self.view.showToast(text: "類別不可為空！")
                isInserted = false
            }
            
            if isInserted {
                self.view.showToast(text: "類別新增成功")
                self.viewDidAppear(true)
//                print(self.dataTypeList)
            } else {
                print("insert failed")
            }
            
            self.viewDidAppear(true)
        })
        
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
//        print("selected row: \(row)")
        webType = pickerViewMenu[row]
    }
    
    func countWebByType(typeLabel: String) -> Int {
        var count: Int = 0
        tableViewList.removeAll()
        for data in webDataList {
            if data.type == typeLabel {
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
//        print(countVal)
        return countVal
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = webTableView.dequeueReusableCell(withIdentifier: "WebCell", for: indexPath) as! WebInfoTableViewCell
        
        cell.bgView.layer.cornerRadius = 15
        cell.bgView.layer.shadowRadius = 5
        cell.bgView.layer.shadowOpacity = 0.3
        cell.bgView.layer.shadowOffset = CGSize(width: 4, height: 5)
        cell.selectionStyle = .none
        
        if typeLabel.text == "全部" {
            cell.webName.text = webDataList[indexPath.row].name
            cell.webType.text = "#" + webDataList[indexPath.row].type
        } else {
            for data in tableViewList {
                print(data.type)
            }
            cell.webName.text = tableViewList[indexPath.row].name
            cell.webType.text = "#" + tableViewList[indexPath.row].type
//            print("webName: \(cell.webName.text!)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

extension UIView {
    func showToast(text: String){
            
            self.hideToast()
            let toastLb = UILabel()
            toastLb.numberOfLines = 0
            toastLb.lineBreakMode = .byWordWrapping
            toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toastLb.textColor = UIColor.white
            toastLb.layer.cornerRadius = 10.0
            toastLb.textAlignment = .center
            toastLb.font = UIFont.systemFont(ofSize: 15.0)
            toastLb.text = text
            toastLb.layer.masksToBounds = true
            toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
            
            let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
            var expectedSize = toastLb.sizeThatFits(maxSize)
            var lbWidth = maxSize.width
            var lbHeight = maxSize.height
            if maxSize.width >= expectedSize.width{
                lbWidth = expectedSize.width
            }
            if maxSize.height >= expectedSize.height{
                lbHeight = expectedSize.height
            }
            expectedSize = CGSize(width: lbWidth, height: lbHeight)
            toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 40 - 20, width: expectedSize.width + 20, height: expectedSize.height + 20)
            self.addSubview(toastLb)
            
            UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
                toastLb.alpha = 0.0
            }) { (complete) in
                toastLb.removeFromSuperview()
            }
        }
        
        func hideToast(){
            for view in self.subviews{
                if view is UILabel , view.tag == 9999{
                    view.removeFromSuperview()
                }
            }
        }
}
