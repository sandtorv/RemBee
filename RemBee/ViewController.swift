//
//  ViewController.swift
//  RemBee
//
//  Created by Sebastian Sandtorv  on 05/09/15.
//  Copyright (c) 2015 Sebastian Sandtorv . All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    
    let textCellIdentifier = "Cell"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(PFUser.currentUser() == nil){
            // transport user to login/signup
        }
        tableView.delegate = self
        title = "RemBee"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadList:", name:"refreshTable", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (PFUser.currentUser() == nil) {
            var logInViewController = PFLogInViewController()
            logInViewController.delegate = self
            var signUpViewController = PFSignUpViewController()
            signUpViewController.delegate = self
            logInViewController.signUpController = signUpViewController
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }

        reloadTableView()
    }
    
    @IBAction func addItem(sender: AnyObject) {
        var alert = UIAlertController(title: "Add new RemBee", message: "What do you need to RemBee?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "RemBee"
            textField.autocapitalizationType = .Sentences
            textField.autocorrectionType = .Default
            textField.delegate = self
            textField.returnKeyType = .Next
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (action) -> Void in
        }))
        
        alert.addAction(UIAlertAction(title: "Add another", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){
                self.saveItem("\(textField.text)")
                storeData()
            }
            self.reloadTableView()
            self.addItem(self)
        }))
        
        alert.addAction(UIAlertAction(title: "Save & close", style: .Cancel, handler: { (action) -> Void in
            let textField = alert.textFields![0] as! UITextField
            if(count(textField.text) > 0){
                self.saveItem("\(textField.text)")
                storeData()
            }
            self.reloadTableView()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func editList(sender: AnyObject) {
        if tableView.editing{
            tableView.setEditing(false, animated: false)
            editButton.style = UIBarButtonItemStyle.Plain
            editButton.title = "Edit"
        }
        else{
            tableView.setEditing(true, animated: false)
            editButton.style = UIBarButtonItemStyle.Done
            editButton.title = "Done"
        }
    }
    
    func saveItem(input: String){
        itemsName.append(input)
        itemsStatus.append(false)
    }
    
    // MARK: TableView
    func reloadList(notification: NSNotification){
        //load data here
        self.tableView.reloadData()
    }
    
    func reloadTableView(){
        self.tableView.reloadData()
    }
    
    // Determine whether a given row is eligible for reordering or not.
    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool{
        return true
    }
    
    // Process the row move. This means updating the data model to correct the item details.
    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!)
    {

        var fromRow: Int = sourceIndexPath.row
        var toRow: Int = destinationIndexPath.row
        let itemNameToMove = itemsName[fromRow]
        let itemsStatusToMove = itemsStatus[fromRow]
        //Remove items
        itemsName.removeAtIndex(fromRow)
        itemsStatus.removeAtIndex(fromRow)
        // Insert itemsName and status
        itemsName.insert(itemNameToMove, atIndex: toRow)
        itemsStatus.insert(itemsStatusToMove, atIndex: toRow)
        storeData()
        reloadTableView()
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
        
        if(row % 2 == 0){
            cell.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1)
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
        storeData()
        reloadTableView()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            var row:Int = indexPath.row
            itemsName.removeAtIndex(row)
            itemsStatus.removeAtIndex(row)
            storeData()
            reloadTableView()
        }
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
        fetchList()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        println("Failed to log in...")
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [NSObject : AnyObject]) -> Bool {
        
        if let password = info["password"] as? String {
            return count(password) >= 1
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
    
}

