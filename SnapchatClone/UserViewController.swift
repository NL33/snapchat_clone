//
//  UserViewController.swift
//  Tinder
//
//  Created by NL33 on 2/27/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit

class UserViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate { //the latter two delegates are required for this controller to controll the image picker and pickimage actions below
    
    var userArray: [String] = [] //a user array to save the users based on the code below
    
    var activeRecipient = 0  //this is a global variable. It is set with the didSelectRowAtUserPath function below (when the user taps on someone in the table), and then added in to the image to send uploading to parse activity
    
    // Update - ! removed after UIImagePickerController
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: //called when the user has already picked their image
        [NSObject : AnyObject]!) {
        println("Image selected")
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // UPLOAD TO PARSE (from saving objects code at parse.com/docs/ios_guide:
        
        var imageToSend = PFObject(className:"image")
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.5))  //this gets the image intself. Compression quality is the extent of image quality--it will be between 0 and 1. The smaller the number the easier to download.  NOTE: we use PFFile, with the data coming from our image. This provides a much bigger limit in terms of photo size than the normal, possibility, which is UIImageJPEGRepresentation...
        imageToSend["senderUsername"] = PFUser.currentUser().username
        imageToSend["recipientUsername"] = userArray[activeRecipient]  //activeRecipient is who has been tapped on, set below in the didSelectRowAtUserPath function below
        imageToSend.save()  //note--this would not tell the user that it actually has been sent.  saveInBackgroundWithBlock, could do that if in the block you put in some kind of alert
        
    }
    
    @IBAction func pickImage(sender: AnyObject) { //creates a new view controller, sets some values for that, and displays the controller for the user to pick their image
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary  //this could have said "camera" instead of "PhotoLibrary", but we use PhotLibrary to be able to view with the simulator
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GET THE USERS:
        var query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)  //we add this so that the current user (specified by the current user's user name) is NOT included
        var users = query.findObjects()
        
        //LOOP THROUGH THE USERS, adding them to the USER ARRAY:
        for user in users {
            
            userArray.append(user.username)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userArray.count  //the number of rows in the section is the length of the user array
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //this is where we define each individual cell
        // Update - replace as with as!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell  //be sure the cell in the main storyboard is set to "cell"
        
        cell.textLabel?.text = userArray[indexPath.row] //sets the cell text to be the username of the user
        
        return cell
    }
    
    
    //This is so that when a user taps on another image in the table, thie pickImage function is called
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        activeRecipient = indexPath.row //this sets the activeRecipient variable when user taps on them--telling us who the user wants to send to.
        
        pickImage(self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
