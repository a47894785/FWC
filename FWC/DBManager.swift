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
                    let createTypeTable = "create table webType(category text not null)"
                    
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
    
}
