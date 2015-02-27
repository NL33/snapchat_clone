//
//  ViewController.swift
//  SnapchatClone
//
//  Created by NL33 on 2/25/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    
    
    @IBAction func signIn(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(username.text, password:"mypass") { //tries to log user in automatically when they hit sign up. We are not requiring a password, so just here enter "mypass" as password
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                
                println("logged in")
                
                self.performSegueWithIdentifier("showUsers", sender: self) //segue to userviewcontroller on signin
                
            } else { //if it does not work to log them in, they we will try and sign them up:
                
                var user = PFUser()
                user.username = self.username.text
                user.password = "mypass"
                
                
                user.signUpInBackgroundWithBlock {
                    (succeeded: Bool!, error: NSError!) -> Void in
                    if error == nil {
                        
                        println("signed up")
                        
                        self.performSegueWithIdentifier("showUsers", sender: self) //segue to userviewcontroller on signin
                        
                    } else { //if that is not successful, then we have an error:
                        
                        println(error)
                    }
                }
                
                
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil { //if there is a current user, then perform segue to user screen:
            
            self.performSegueWithIdentifier("showUsers", sender: self)
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

