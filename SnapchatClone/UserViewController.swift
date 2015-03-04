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
    
    var timer = NSTimer() //relates to app checking for new messages after a set amount of time
    
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
            
            tableView.reloadData()  //be sure to refresh the table after the user array is updated each time
            
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true)  //this says every 5 seconds run the function checkForMessage below
        
    }
    func checkForMessage() {//function to check for message after a period of time per the timer methods above
        
        println("checking for message...")
        
        var query = PFQuery(className: "image") //checking the image
        query.whereKey("recipientUsername", equalTo: PFUser.currentUser().username) //find where the recipient user name in parse is equal to the current user name (just checking if there is a new image for that user)
        var images = query.findObjects()
        
        var done = false //
        
        for image in images {
            
            if done == false {
                
                var imageView:PFImageView = PFImageView()  //download the image.
                
                // Update - replaced as with as!
                
                imageView.file = image["photo"] as PFFile  //set the image to the photo that we have downloaded
                imageView.loadInBackground({ (photo, error) -> Void in //this is the instruction to download the image..
              
                if error == nil {
                
                    
                //CREATE SENDERUSER NAME VARIABLE FOR PURPOSES OF SHOWING THE NAME OF THE PERSON WHO SENT THE MESSAGE WHEN WE GIVE THE USER AN ALERT THEY HAVE A NEW MESSAGE
                var senderUsername = ""
                
                if image["senderUsername"] != nil { //if there is an image, then run the below. We set as conditiional to avoid printing "Optional" with the username.
                
                // Update - replaced as NSString with as! String
                
                senderUsername = image["senderUsername"]! as String  //if there is a user, set to who has sent the message
                
                } else {
                
                senderUsername = "unknown user" //else, set to unknown user
                
                }
                    
            //GIVE USER ALERT IF THERE IS A MESSAGE FOR THEM
                var alert = UIAlertController(title: "You have a message", message: "Message from \(senderUsername)", preferredStyle: UIAlertControllerStyle.Alert)  //create alert, give title, and style. This also tells them who the message is from (senderUsername is the column in Parse)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                (action) -> Void in
             //
                    
              //The image will be printed on the table view. But we do not want the user to be able to see the table in the background when the image appears. So we change the background to a dark background with a small amount of transparancy
                var backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                backgroundView.backgroundColor = UIColor.blackColor()  //changes the background to black
                backgroundView.alpha = 0.8 //adds a bit of transparancy--so background looks more so grayed out
                backgroundView.tag = 3  //this sets a tag for the image. 3 is just a random name for the tag. With this, we can below in the hideMessage() function select all images with tag of 3, and delete them.
                self.view.addSubview(backgroundView)
                
                    //SET THE APPEARANCE OF THE IMAGE:
                    var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)) //We create a UIimage and put it on top of our table:
                  displayedImage.image = photo //set the image to be our image, which is our photo variable
                  displayedImage.tag = 3 //this sets a tag for the image. 3 is just a random name for the tag. With this, we can below in the hideMessage() function select all images with tag of 3, and delete them.
                  displayedImage.contentMode = UIViewContentMode.ScaleAspectFit  //changes the content mode to aspect fit so it fits the image on the screen in the correct ratio
                   self.view.addSubview(displayedImage)  //put the image in the view
               
                    
                    //Hide the message after 5 seconds:
                image.delete()  //this ensures that the image is displayed and then deleted from Parse so not to be shown again.
                
                self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)  //hides message after 5 seconds, based on the hidemessage function below
                
                }))
                
                self.presentViewController(alert, animated: true, completion: nil) //this is to show the alert created above
                
                
                }
                
                
                })
                
                done = true
            }
            
        }
        
    }
    
    func hideMessage() { //remove the image views that we have created
        
        for subview in self.view.subviews {//loops through the subviews
            
            if subview.tag == 3 {//this is the tag set above
                
                subview.removeFromSuperview() //remove from Superview--Superview is the whole view
                
            }
            
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {  //this is if the user taps the logout button that is on the view controller, identified as "logout"--and then, per the segue we have set up, takes the user to the signin page
        
        if segue.identifier == "logout" {
            
            PFUser.logOut()
            
        }
        
    }
 
   }
