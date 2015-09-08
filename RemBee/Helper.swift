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
var listID: String = ""

func textFieldShouldReturn(textField: UITextField) -> Bool {
    return false
}

func storeData(){
    println(listID)
    println("Count: \(count(listID))")
    if(count(listID) > 5){
        updateList(listID)
    } else {
        saveList()
    }
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
                    println("listID: \(listID), itemsName: \(itemsName), itemsStatus: \(itemsStatus)")
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshTable", object: nil)
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
        (object: PFObject?, error: NSError?) -> Void in
        if error != nil {
            println(error)
        } else if let object = object {
            object["itemsName"] = itemsName
            object["itemsStatus"] = itemsStatus
            object.saveInBackground()
        }
    }
}

// Delay Helper
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}