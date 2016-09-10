//
//  RegisterViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 25/05/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var email_errorLabel: UILabel!
    @IBOutlet weak var username_errorLabel: UILabel!
    @IBOutlet weak var password_errorLabel: UILabel!
    @IBOutlet weak var confrimPassword_errorLabel: UILabel!
    @IBOutlet weak var verificationCode_errorLabel: UILabel!
    
    @IBAction func sendVerificationCode(sender: AnyObject) {
        
        let email:String = emailTextField.text!
        
        if email != "" {
            
            if !isValidEmail(email){
                self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.email_errorLabel.hidden = false
                self.email_errorLabel.text = "Please enter a NJIT email"
            }
            else{
                
            }
            
            //verification process
            let verificationUrlString = "http://52.87.233.57:80/verification"
            let verificationUrl: NSURL = NSURL(string: verificationUrlString)!
            
            let verificationRequest: NSMutableURLRequest = NSMutableURLRequest(URL: verificationUrl)
            verificationRequest.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            // passing string in post request
            /*
            let requestParams = "email="+email
            verificationRequest.HTTPBody = requestParams.dataUsingEncoding(NSUTF8StringEncoding)
            verificationRequest.setValue("application/json", forHTTPHeaderField: "Accept");
            */
            
            let verificationParams = ["email":email] as Dictionary<String, String>
            verificationRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(verificationParams, options: [])
            
            let task = session.dataTaskWithRequest(verificationRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    print("error=\(error)")
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 90, self.view.frame.size.height-320, 90+90, 24))
                        toastLabel.backgroundColor = UIColor.blackColor()
                        toastLabel.textColor = UIColor.whiteColor()
                        toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 14.5)
                        toastLabel.textAlignment = NSTextAlignment.Center;
                        toastLabel.text = "No internet connection."
                        toastLabel.alpha = 1.0
                        toastLabel.layer.cornerRadius = 4;
                        toastLabel.layer.borderColor = UIColor.whiteColor().CGColor
                        toastLabel.layer.borderWidth = CGFloat(Float (2.0))
                        toastLabel.clipsToBounds = true
                        
                        self.view.addSubview(toastLabel)
                        
                        UIView.animateWithDuration(2.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                            
                            toastLabel.alpha = 0.0
                            
                            }, completion: nil)
                    })
                    return
                }
                
                print("Response: \(response)")
                let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("Body: \(strData)")
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                    if let dict = json as? NSDictionary {
                        // ... process the data
                        print(dict)
                        //var msg = "No message"
                        
                        // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                        if(error != nil) {
                            print(error!.localizedDescription)
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: '\(jsonStr)'")
                            //postCompleted(succeeded: false, msg: "Error")
                        }
                        else {
                            
                            // The JSONObjectWithData constructor didn't return an error. But, we should still
                            // check and make sure that json has a value using optional binding.
                            if let dict = json as? NSDictionary {
                                // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                                if let response_code = dict["response_code"] as? Int {
                                    print("response_code: \(response_code)")
                                    //postCompleted(succeeded: success, msg: "Logged in.")
                                    dispatch_async(dispatch_get_main_queue(),{
                                        if response_code == 2 {
                                            self.email_errorLabel.hidden = false
                                            self.email_errorLabel.text = "This email is in use"
                                            
                                            self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                                            self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                                        }
                                        if response_code == 3 {
                                            self.email_errorLabel.hidden = false
                                            self.email_errorLabel.text = "Email not valid. Please use NJIT email."
                                            
                                            self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                                            self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                                        }
                                            
                                        else if response_code == 101 {
                                            //MAIL_SENDING_TOO_FREQUENT
                                            let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height-320, 200, 24))
                                            toastLabel.backgroundColor = UIColor.blackColor()
                                            toastLabel.textColor = UIColor.whiteColor()
                                            toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 15)
                                            toastLabel.textAlignment = NSTextAlignment.Center;
                                            self.view.addSubview(toastLabel)
                                            //change
                                            toastLabel.text = "Mail sent too frequently."
                                            toastLabel.alpha = 1.0
                                            toastLabel.layer.cornerRadius = 5;
                                            toastLabel.clipsToBounds  =  true
                                            
                                            UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                                                
                                                toastLabel.alpha = 0.0
                                                
                                                }, completion: nil)
                                        }
                                    })
                                }
                                return
                                
                            }
                            else {
                                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                                print("Error could not parse JSON: \(jsonStr)")
                                //postCompleted(succeeded: false, msg: "Error")
                            }
                        }
                    }
                } catch let error as NSError {
                    print("An error occurred: \(error)")
                }
            })
            task.resume()
        }
        else{
            
        }
    }

    @IBAction func registerButtonClicked(sender: AnyObject) {
        
        let email = emailTextField.text!
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let confirm_password = confirmPasswordTextField.text!
        let verification = self.verificationCodeTextField.text!
        
        let red_color : UIColor = .redColor()
        if email == "" && username == "" && password == "" && confirm_password == "" && verification == "" {
            self.email_errorLabel.hidden = false
            self.email_errorLabel.text = "All fields are required"
            
            self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
            self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            self.usernameTextField.layer.borderColor = red_color.CGColor
            self.usernameTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            self.passwordTextField.layer.borderColor = red_color.CGColor
            self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            self.confirmPasswordTextField.layer.borderColor = red_color.CGColor
            self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            self.verificationCodeTextField.layer.borderColor = red_color.CGColor
            self.verificationCodeTextField.layer.borderWidth = CGFloat(Float (1.0))
           
            /*
            let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 130, self.view.frame.size.height-80, 260, 24))
            toastLabel.backgroundColor = UIColor.blackColor()
            toastLabel.textColor = UIColor.whiteColor()
            toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 15)
            toastLabel.textAlignment = NSTextAlignment.Center;
            self.view.addSubview(toastLabel)
            toastLabel.text = "You have been successfully registered."
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 5;
            toastLabel.clipsToBounds  =  true
            
            UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                
                toastLabel.alpha = 0.0
                
                }, completion: {(completed) in
                    
                    let viewController: UIViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = viewController
                    self.navigationController?.popToRootViewControllerAnimated(true)
            })
*/
            return
        }
        
        else if email == "" || username == "" || password == "" || verification == ""{
            
            if !isValidEmail(email){
                self.emailTextField.layer.borderColor = red_color.CGColor
                self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.email_errorLabel.hidden = false
                self.email_errorLabel.text = "Please enter a NJIT email"
            }
            
            if username == ""{
                self.usernameTextField.layer.borderColor = red_color.CGColor
                self.usernameTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.username_errorLabel.hidden = false
                self.username_errorLabel.text = "Username cannot be empty"
            }
            
            if password == ""{
                self.passwordTextField.layer.borderColor = red_color.CGColor
                self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.password_errorLabel.hidden = false
                self.password_errorLabel.text = "Password cannot be empty"
            }
            else{
                self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                self.password_errorLabel.hidden = true
            }
            
            if confirm_password == ""{
                self.confirmPasswordTextField.layer.borderColor = red_color.CGColor
                self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.self.confrimPassword_errorLabel.hidden = false
                self.confrimPassword_errorLabel.text = "Confirm password cannot be empty"
            }
            else{
                self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
                self.confrimPassword_errorLabel.hidden = true
            }
            
            if verification == "" {
                self.verificationCodeTextField.layer.borderColor = red_color.CGColor
                self.verificationCodeTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.verificationCode_errorLabel.hidden = false
                self.verificationCode_errorLabel.text = "Enter Verification Code"
            }
            
            if password != confirm_password{
                if password != "" && confirm_password == ""{
                    self.confirmPasswordTextField.layer.borderColor = red_color.CGColor
                    self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Confirm password cannot be empty"
                }
                else if password == "" && confirm_password != ""{
                    self.passwordTextField.layer.borderColor = red_color.CGColor
                    self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.password_errorLabel.hidden = false
                    self.password_errorLabel.text = "Password cannot be empty"
                }
                else{
                    self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.confirmPasswordTextField.layer.borderColor = UIColor.redColor().CGColor
                    self.password_errorLabel.hidden = true
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Password does not match"
                }
            }
            else {
                if password == "" && confirm_password == "" {
                    self.passwordTextField.layer.borderColor = red_color.CGColor
                    self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.password_errorLabel.hidden = false
                    self.password_errorLabel.text = "Password cannot be empty"
                    
                    self.confirmPasswordTextField.layer.borderColor = red_color.CGColor
                    self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Confirm password cannot be empty"
                }
                else{
                    self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.password_errorLabel.hidden = true
                    self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.confrimPassword_errorLabel.hidden = true
                }
            }
        }
        else if email != "" && username != "" && password != "" && verification != "" {
            if password != confirm_password{
                if password != "" && confirm_password == ""{
                    self.confirmPasswordTextField.layer.borderColor = red_color.CGColor
                    self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Confirm password cannot be empty"
                }
                else if password == "" && confirm_password != ""{
                    self.passwordTextField.layer.borderColor = red_color.CGColor
                    self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.password_errorLabel.hidden = false
                    self.password_errorLabel.text = "Password cannot be empty"
                }
                else{
                    self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.password_errorLabel.hidden = true
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Password does not match"
                }
            }
            else{
                registrationProcess(email, username: username, password: password, verification: verification)
            }
        }
    }
    
    func registrationProcess(email: String, username: String, password: String, verification: String)
    {
        let registerationUrlString = "http://52.87.233.57:80/register"
        let registerationUrl: NSURL = NSURL(string: registerationUrlString)!
        
        let registerationRequest: NSMutableURLRequest = NSMutableURLRequest(URL: registerationUrl)
        registerationRequest.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        
        // when dictionary is used !
        
        //        let resgistrationParams : NSString = "email="+email+"username="+username+"password="+password+"verification"+verification
        //        registerationRequest.HTTPBody = resgistrationParams.dataUsingEncoding(NSUTF8StringEncoding)
        //        registerationRequest.setValue("application/json", forHTTPHeaderField: "Accept");
        
        let resgistrationParams = ["email":email, "username":username, "password":password, "verification":verification] as Dictionary<String, String>
        registerationRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(resgistrationParams, options: [])
        
        let task = session.dataTaskWithRequest(registerationRequest, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("error=\(error)")
                dispatch_async(dispatch_get_main_queue(), {
                    //self.feedsTableView.hidden = true
                    
                    let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 90, self.view.frame.size.height-320, 90+90, 24))
                    toastLabel.backgroundColor = UIColor.blackColor()
                    toastLabel.textColor = UIColor.whiteColor()
                    toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 14.5)
                    toastLabel.textAlignment = NSTextAlignment.Center;
                    toastLabel.text = "No internet connection."
                    toastLabel.alpha = 1.0
                    toastLabel.layer.cornerRadius = 4;
                    toastLabel.layer.borderColor = UIColor.whiteColor().CGColor
                    toastLabel.layer.borderWidth = CGFloat(Float (2.0))
                    toastLabel.clipsToBounds = true
                    
                    self.view.addSubview(toastLabel)
                    
                    UIView.animateWithDuration(2.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                        
                        toastLabel.alpha = 0.0
                        
                        }, completion: nil)
                })
                return
            }
            
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                if let dict = json as? NSDictionary {
                    // ... process the data
                    print(dict)
                    //var msg = "No message"
                    
                    // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                    if(error != nil) {
                        print(error!.localizedDescription)
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: '\(jsonStr)'")
                        //postCompleted(succeeded: false, msg: "Error")
                    }
                    else {
                        
                        // The JSONObjectWithData constructor didn't return an error. But, we should still
                        // check and make sure that json has a value using optional binding.
                        if let dict = json as? NSDictionary {
                            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                            if let response_code = dict["response_code"] as? Int {
                                print("response_code: \(response_code)")
                                
                                dispatch_async(dispatch_get_main_queue(),{
                                    if response_code == 1 {
                                        
                                        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 140, self.view.frame.size.height-80, 285, 24))
                                        toastLabel.backgroundColor = UIColor.blackColor()
                                        toastLabel.textColor = UIColor.whiteColor()
                                        toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 15)
                                        toastLabel.textAlignment = NSTextAlignment.Center;
                                        self.view.addSubview(toastLabel)
                                        //change
                                        toastLabel.text = "You have been successfully registered."
                                        toastLabel.alpha = 1.0
                                        toastLabel.layer.cornerRadius = 5;
                                        toastLabel.clipsToBounds  =  true
                                        
                                        UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                                            
                                            toastLabel.alpha = 0.0
                                            
                                            }, completion: {(completed) in
                                                
                                                let viewController: UIViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
                                                UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
                                                self.navigationController?.popToRootViewControllerAnimated(true)
                                        })
                                    }
                                    else if response_code == 2 {
                                        self.email_errorLabel.hidden = false
                                        self.email_errorLabel.text = "This email is in use"
                                        
                                        self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                                        self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                                    }
                                    else if response_code == 3 {
                                        self.email_errorLabel.hidden = false
                                        self.email_errorLabel.text = "Email not valid. Please use NJIT email."
                                        
                                        self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                                        self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                                    }
                                    else if response_code == 4 {
                                        self.password_errorLabel.hidden = false
                                        self.password_errorLabel.text = "Password must be atleast 8 chararters long"
                                        
                                        self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor
                                        self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                                    }
                                    else if response_code == 8 {
                                        self.self.verificationCode_errorLabel.hidden = false
                                        self.self.verificationCode_errorLabel.text = "Verification code does not match"
                                        
                                        self.self.verificationCodeTextField.layer.borderColor = UIColor.redColor().CGColor
                                        self.self.verificationCodeTextField.layer.borderWidth = CGFloat(Float (1.0))
                                    }
                                    else if response_code == 9 {
                                        //Verification code has expired.
                                        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 115, self.view.frame.size.height-320, 230, 24))
                                        toastLabel.backgroundColor = UIColor.blackColor()
                                        toastLabel.textColor = UIColor.whiteColor()
                                        toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 15)
                                        toastLabel.textAlignment = NSTextAlignment.Center;
                                        self.view.addSubview(toastLabel)
                                        //change
                                        toastLabel.text = "Verification code has expired."
                                        toastLabel.alpha = 1.0
                                        toastLabel.layer.cornerRadius = 5;
                                        toastLabel.clipsToBounds  =  true
                                        
                                        UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                                            
                                            toastLabel.alpha = 0.0
                                            
                                            }, completion: nil)
                                    }
                                })
                            }
                            return
                        }
                        else {
                            // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                            let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("Error could not parse JSON: \(jsonStr)")
                            //postCompleted(succeeded: false, msg: "Error")
                        }
                    }
                }
            } catch let error as NSError {
                print("An error occurred: \(error)")
            }
        })
        task.resume()
    }
    
    func isValidEmail(email:String) -> Bool {
        //let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailRegEx = "[A-Z0-9a-z._%+-]+@njit+\\.edu"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
   
    
    @IBAction func emailTextFieldEditingChanged(sender: AnyObject) {
        if !isValidEmail(emailTextField.text!){
            self.email_errorLabel.hidden = false
            self.email_errorLabel.text = "Please enter a NJIT email"
        }
        else{
            self.email_errorLabel.hidden = true
            self.emailTextField.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    @IBAction func usernameTextFieldEditingChanged(sender: AnyObject) {
        self.username_errorLabel.hidden = true
        self.usernameTextField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    @IBAction func passwordTextFieldEditingChanged(sender: AnyObject) {
        self.password_errorLabel.hidden = true
        self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
        if self.passwordTextField.text == self.confirmPasswordTextField.text{
            self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
            self.password_errorLabel.hidden = true
            self.confrimPassword_errorLabel.hidden = true
        }
    }
    
    @IBAction func confrimPasswordTextFieldEditingChanged(sender: AnyObject) {
        self.confrimPassword_errorLabel.hidden = true
        self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
        if self.passwordTextField.text == self.confirmPasswordTextField.text{
            self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
            self.password_errorLabel.hidden = true
            self.confrimPassword_errorLabel.hidden = true
        }
    }
    
    @IBAction func verificationCodeTextFieldEditingChanged(sender: AnyObject) {
        self.verificationCode_errorLabel.hidden = true
        self.verificationCodeTextField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == self.emailTextField{
            if !isValidEmail(self.emailTextField.text!){
                self.emailTextField.layer.borderColor = UIColor.redColor().CGColor
                self.emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.email_errorLabel.hidden = false
                self.email_errorLabel.text = "Please enter a NJIT email"
            }
            else{
                self.emailTextField.resignFirstResponder()
                self.usernameTextField.becomeFirstResponder()
            }
        }
        if textField == self.usernameTextField{
            if self.usernameTextField.text == ""{
                self.usernameTextField.layer.borderColor = UIColor.redColor().CGColor
                self.usernameTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.username_errorLabel.hidden = false
                self.username_errorLabel.text = "Username cannot be empty"
            }
            else{
                self.usernameTextField.layer.borderColor = UIColor.clearColor().CGColor
                self.username_errorLabel.hidden = true
                
                self.usernameTextField.resignFirstResponder()
                self.passwordTextField.becomeFirstResponder()
            }
        }
        if textField == self.passwordTextField{
            if self.passwordTextField.text == ""{
                self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor
                self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                
                self.password_errorLabel.hidden = false
                self.password_errorLabel.text = "Password cannot be empty"
            }
            else{
                self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                self.password_errorLabel.hidden = true
                
                self.passwordTextField.resignFirstResponder()
                self.confirmPasswordTextField.becomeFirstResponder()
            }
        }
        if textField == self.confirmPasswordTextField{
 
            if self.passwordTextField.text != self.confirmPasswordTextField.text{
                if self.passwordTextField.text != "" && self.confirmPasswordTextField.text == ""{
                    self.confirmPasswordTextField.layer.borderColor = UIColor.redColor().CGColor
                    self.confirmPasswordTextField.layer.borderWidth = CGFloat(Float(1.0))
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Confirm password cannot be empty"
                }
                else if self.passwordTextField.text == "" && self.confirmPasswordTextField.text != ""{
                    self.passwordTextField.layer.borderColor = UIColor.redColor().CGColor
                    self.passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                    
                    self.password_errorLabel.hidden = false
                    self.password_errorLabel.text = "Password cannot be empty"
                }
                else{
                    self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
                    self.password_errorLabel.hidden = true
                    
                    self.confrimPassword_errorLabel.hidden = false
                    self.confrimPassword_errorLabel.text = "Password does not match"
                }
            }
            else{
                self.confirmPasswordTextField.layer.borderColor = UIColor.clearColor().CGColor
                self.confrimPassword_errorLabel.hidden = true
                
                self.confirmPasswordTextField.resignFirstResponder()
                self.verificationCodeTextField.becomeFirstResponder()
            }
            
        }

        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.emailTextField.becomeFirstResponder()
        
        
 
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
