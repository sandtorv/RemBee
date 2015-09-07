//
//  ViewController.swift
//  RemBee
//
//  Created by Sebastian Sandtorv  on 05/09/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    
    let textCellIdentifier = "Cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        if (PFUser.currentUser() == nil) {
            
            var logInViewController = PFLogInViewController()
            
            logInViewController.delegate = self
            
            var signUpViewController = PFSignUpViewController()
            
            signUpViewController.delegate = self
            
            logInViewController.signUpController = signUpViewController
        
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
        
        fetchList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addItem(sender: AnyObject) {
        var alert = UIAlertController(title: "Add RemBee item", message: "Type in what you need to RemBee!", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "RemBee"
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Default
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){
                self.saveItem("\(textField.text)")
            }
            self.reloadTableView()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func refreshButton(sender: AnyObject) {
        reloadTableView()
    }
    
    @IBAction func saveData(sender: AnyObject) {
        storeData()
    }
    
    func saveItem(input: String){
        itemsName.append(input)
        itemsStatus.append(false)
    }
    
    // MARK: Parse Login
    func logInViewController(logInController: PFLogInViewController, shouldBeginLogInWithUsername username: String, password: String) -> Bool {
        
        if (!username.isEmpty || !password.isEmpty) {
            return true
        }else {
            return false
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to log in...")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        
        if let password = info["password"] as? String {
            return count(password) >= 8
        }
        return false
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        println("Failed to sign up...")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        println("User dismissed sign up.")
    }
    
    
    // MARK: TableView
    func reloadTableView(){
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsName.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var attributes = [NSStrikethroughStyleAttributeName : 0]
        var row:Int = indexPath.row
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        if(itemsStatus[row]){
            attributes = [NSStrikethroughStyleAttributeName : 1]
            cell.textLabel!.textColor = UIColor.lightGrayColor()
        } else{
            cell.textLabel!.textColor = UIColor.blackColor()
        }
        cell.textLabel!.attributedText = NSAttributedString(string:itemsName[row], attributes: attributes)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var row:Int = indexPath.row
        if itemsStatus[row]{
            itemsStatus[row] = false
        } else {
            itemsStatus[row] = true
        }
        reloadTableView()
    }
    
}

