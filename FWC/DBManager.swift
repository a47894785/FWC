//
//  DBManager.swift
//  FWC
//
//  Created by USER on 2022/12/15.
//

import UIKit

class DBManager: NSObject {
    static let shared: DBManager = DBManager()
    
    let databaseFileName = "fwcDb.sqlite"
    var pathToDatabase: String!
    var database: FMDatabase!
    
    override init() {
        super.init()
        
        let documentsDirectory = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString) as String
            pathToDatabase = documentsDirectory.appending("/\(databaseFileName)")
        print(pathToDatabase!)
    }
    
    func createDB() -> Bool {
        var created = false
        if !FileManager.default.fileExists(atPath: pathToDatabase) {
            database = FMDatabase(path: pathToDatabase)
            if database != nil {
                // open database
                if database.open() {
                    let createWebInfoTable = "create table webInfo (webID integer primary key autoincrement not null, name text not null, url text unique not null, type text not null)"
                    
                    let createWebTypeTable = "create table webTypeTb (type text primary key not null)"
                    
                    do {
                        try database.executeUpdate(createWebInfoTable, values: nil)
                        try database.executeUpdate(createWebTypeTable, values: nil)
                        if self.typeTableInit() && self.webInfoTableInit() {
                            print("create webType & webInfo table successfully")
                            created = true
                        }
                    } catch {
                        print("Could not open the database")
                        print(error.localizedDescription)
                    }
                    
                    database.close()
                    
                } else {
                    print("Could not open the database")
                }
            }
            
        }
        
        return created
    }
    
    func openDB() -> Bool {
        if database == nil {
            if FileManager.default.fileExists(atPath: pathToDatabase) {
                database = FMDatabase(path: pathToDatabase)
            }
        }
        
        if database != nil {
            if database.open() {
//                print("open database")
                return true
            }
        }
//        print("open database failed")
        return false
    }
    
    func webInfoTableInit() -> Bool {
        if openDB() {
            let query = "insert into webInfo (webID, name, url, type) values (null, 'FCU','https://www.fcu.edu.tw/', '一般');"
            if !database.executeStatements(query) {
//                print("failed to insert")
                print(database.lastError(), database.lastErrorMessage())
                return false
            }
            
            database.close()
            return true
        }
        return false
    }
    
    func typeTableInit() -> Bool {
        if openDB() {
            let query = "insert into webTypeTb (type) values ('一般');"
            if !database.executeStatements(query) {
                print("failed to initialize webType table")
                return false
            }
            
            database.close()
            return true
        }
        return false
    }
    
    func getWebTypeInfo() -> [String] {
        var typeList: [String] = []
        if openDB() {
            let query = "select * from webTypeTb"
            
            do {
                let results = try database.executeQuery(query, values: nil)
                while results.next() {
                    let type = results.string(forColumn: "type")
                    typeList.append(type!)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        database.close()
        return typeList
    }
    
    func insertWebType(type: String) -> Bool  {
        if openDB() {
            let query = "insert into webTypeTb (type) values ('\(type)');"
            
            if !database.executeStatements(query) {
                print("failed to insert")
                print(database.lastError(), database.lastErrorMessage())
                return false
            }
        }
        
        database.close()
        return true
    }
    
    func insertWebInfo(webName:String, webUrl:String, webType:String) ->  Bool {
        if openDB() {
            print("ready to insert")
            let query = "insert into webInfo (webID, name, url, type) values (null, '\(webName)','\(webUrl)', '\(webType)');"
            if !database.executeStatements(query) {
                print("failed to insert")
                print(database.lastError(), database.lastErrorMessage())
                return false
            }
            
            database.close()
            return true
        }
        return false
    }
    
    func showWebInfoTable() -> [WebInformation] {
        var webDataList :[WebInformation] = []
        if openDB() {
            let query = "select * from webInfo"
            
            do {
//                print("---webInfo---")
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let webID = results.int(forColumn: "webID")
                    let webName = results.string(forColumn: "name")
                    let webUrl = results.string(forColumn: "url")
                    let webType = results.string(forColumn: "type")
                    
                    
                    let webData = WebInformation(id: Int(webID), name: webName!, url: webUrl!, type: webType!)
                    webDataList.append(webData)
                    
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        database.close()
        return webDataList
    }
    
    func deleteWeb(webID: Int) -> Bool {
        if openDB() {
            let query = "delete from webInfo where webID='\(webID)'"
            
            if !database.executeStatements(query) {
//                print("failed to insert")
                print(database.lastError(), database.lastErrorMessage())
                return false
            }
            database.close()
            return true
        }
        return false
    }
    
    func updateWebData(webID: Int, newWebName: String, newWebUrl: String) -> Bool {
        if openDB() {
            let query = "update webInfo set name='\(newWebName)', url='\(newWebUrl)' where webID='\(webID)';"
            
            if !database.executeStatements(query) {
                print(database.lastError(), database.lastErrorMessage())
                return false
            }
            database.close()
            return true
        }
        return false
    }
    
}
	
