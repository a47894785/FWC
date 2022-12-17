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
                    let createTypeTable = "create table webInfo (webID integer primary key autoincrement not null, name text not null, url text not null)"
                    
                    do {
                        try database.executeUpdate(createTypeTable, values: nil)
                        created = true
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
                print("open database")
                return true
            }
        }
        print("open database failed")
        return false
    }
    
    func insertWebInfo(webName:String, webUrl:String) ->  Bool {
        if openDB() {
            print("ready to insert")
            let query = "insert into webInfo (webID, name, url) values (null, '\(webName)','\(webUrl)');"
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
    
    func showWebInfoTable()  {
        if openDB() {
            let query = "select * from webInfo"
            
            do {
                print("---webInfo---")
                let results = try database.executeQuery(query, values: nil)
                
                while results.next() {
                    let webID = results.int(forColumn: "webID")
                    let webName = results.string(forColumn: "name")
                    let webUrl = results.string(forColumn: "url")
                    
                    print("---------------\nwebID: \(webID) \nwebName: \(webName!) \nwebUrl: \(webUrl!)")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        database.close()
    }
    
}
	
