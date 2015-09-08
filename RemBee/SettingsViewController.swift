//
//  SettingsViewController.swift
//  RemBee
//
//  Created by Sebastian Sandtorv  on 07/09/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var sectionsArray: [String] = ["Username", "Email", "Logout"]
    var userDataArray: [String] = [String]()
    var user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "User Settings"
        tableView.delegate = self
        userDataArray = ["\(user!.username!)", "\(user!.email!)", "Please verify your email", "Logout from app"]
        if PFUser.currentUser()?.objectForKey("emailVerified")?.boolValue == true {
            userDataArray[2] = "Email verified"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        if PFUser.currentUser()?.objectForKey("emailVerified")?.boolValue == true {
            userDataArray[2] = "Email verified"
        } else{
            // User needs to verify email address before continuing
            var alert = UIAlertController(title: "Add new RemBee", message: "What do you need to RemBee?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: { (action) -> Void in
                println("OK, got it!")
            }))
            alert.addAction(UIAlertAction(title: "Resend email!", style: .Default, handler: { (action) -> Void in
                println("Please resend email!")
                self.updateUsersEmail()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }

    }
    
    func updateEmail(email: String){
        var object = PFUser.currentUser()
        object!.setValue(email, forKey: "Email")
        object!.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                println("Email update saved")
            } else {
                // There was a problem, check error.description
                println("Something fishy happend")
            }
        }
    }
    
    func updateUsersEmail(){
        var alert = UIAlertController(title: "Update your email", message: "Please double check that the email is correct. You will get a verification email on your email within a few seconds.", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = self.user!.email!
            textField.autocapitalizationType = .None
            textField.keyboardType = .EmailAddress
            textField.autocorrectionType = .Default
            textField.delegate = self
            textField.returnKeyType = .Done
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Update Email", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            self.updateEmail(textField.text)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return userDataArray.count - 2
        } else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    // print the date as the section header title
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsArray[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var row: Int = indexPath.row + indexPath.section
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.accessoryType = .None
        cell.textLabel?.textColor = .darkGrayColor()
        
        if(userDataArray[2] == "Email verified" && indexPath.section != 0 && row == 1){
            cell.accessoryType = .Checkmark
        }
        
        if(indexPath.section == 2){
            row++
            cell.textLabel?.textColor = .redColor()
        }
        
        cell.textLabel!.text = userDataArray[row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0 && indexPath.section == 1){
            updateUsersEmail()
            println("Clicking as crazy!")
        } else if(indexPath.section == 2){
            PFUser.logOut()
            itemsName.removeAll()
            itemsStatus.removeAll()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshTable", object: nil)
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
}