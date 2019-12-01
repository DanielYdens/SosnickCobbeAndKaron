//
//  Request.swift
//  Sosnick App
//
//  Created by Daniel Ydens on 6/26/19.
//  Copyright © 2019 Daniel Ydens. All rights reserved.
//

import Foundation


class Request {
    var category: String
    var description: String
    var date: String
    var isProcessed: Bool
    var haveData: Bool
    var dateNum: Int
    var docID: String
    var user : String
    var message : Bool
    var name : String
    var status : String
    
    
    init(){
        self.category = ""
        self.description = ""
        self.date = ""
        self.isProcessed = false
        self.haveData = false
        self.dateNum = 0
        self.docID = ""
        self.user = ""
        self.message = false
        self.name = ""
        self.status = ""
    }
    
    init(category: Any?, description: Any?, date: Any?, isProcessed: Any?, dateNum: Any?, docID: Any?, user: Any?, message: Any?){
        self.category = category as! String
        self.description = description as! String
        self.date = date as! String
        self.isProcessed = isProcessed as! Bool
        self.haveData = true
        self.dateNum = dateNum as! Int
        self.docID = docID as! String
        self.user = user as! String
        self.message = message as! Bool
        self.name = ""
        self.status = ""
    }
    
    init(category: Any?, description: Any?, date: Any?, isProcessed: Any?, dateNum: Any?, docID: Any?, user: Any?, message: Any?, name: Any?){
        self.category = category as! String
        self.description = description as! String
        self.date = date as! String
        self.isProcessed = isProcessed as! Bool
        self.haveData = true
        self.dateNum = dateNum as! Int
        self.docID = docID as! String
        self.user = user as! String
        self.message = message as! Bool
        self.name = name as! String
        self.status = ""
    }
    
    
   
    }

