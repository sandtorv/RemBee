//
//  Helper.swift
//  RemBee
//
//  Created by Sebastian Sandtorv  on 06/09/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import Foundation
import UIKit
import Parse

var itemsName: [String] = [String]()
var itemsStatus: [Bool] = [Bool]()
var listID: String = String()

func storeData(){
    println(listID)
    updateList(listID)
}

func saveList(){
    var object = PFObject(className:"TodoList")
    object["User"] = PFUser.currentUser()
    object["itemsName"] = itemsName
    object["itemsStatus"] = itemsStatus
    object.saveInBackgroundWithBlock {
        (success: Bool, error: NSError?) -> Void in
        if (success) {
            // The object has been saved.
        } else {
            // There was a problem, check error.description
        }
    }
}

func fetchList(){
    var query = PFQuery(className:"TodoList")
    query.whereKey("User", equalTo:PFUser.currentUser()!)
    query.findObjectsInBackgroundWithBlock {
        (objects: [AnyObject]?, error: NSError?) -> Void in
        
        if error == nil {
            // Do something with the found objects
            if let objects = objects as? [PFObject] {
                for object in objects {
                    itemsName = object["itemsName"] as! [String]
                    itemsStatus = object["itemsStatus"] as! [Bool]
                    listID = object.objectId!
                }
            }
        } else {
            // Log details of the failure
            println("Error: \(error!) \(error!.userInfo!)")
        }
    }
}

func updateList(objectID: String){
    var query = PFQuery(className:"TodoList")
    query.getObjectInBackgroundWithId(listID) {
        (gameScore: PFObject?, error: NSError?) -> Void in
        if error != nil {
            println(error)
        } else if let gameScore = gameScore {
            gameScore["itemsName"] = itemsName
            gameScore["itemsStatus"] = itemsStatus
            gameScore.saveInBackground()
        }
    }
}