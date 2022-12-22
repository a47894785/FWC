//
//  WebInfomation.swift
//  FWC
//
//  Created by user on 2022/12/21.
//

import UIKit

class WebInformation: NSObject {
    
    var id: Int
    var name: String
    var url: String
    var type: String
    
    init(id: Int, name: String, url: String, type: String) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
    }

}
