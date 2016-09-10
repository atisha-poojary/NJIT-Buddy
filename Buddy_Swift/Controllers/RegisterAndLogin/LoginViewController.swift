//
//  LoginViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 25/05/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var email_errorLabel: UILabel!
    @IBOutlet weak var password_errorLabel: UILabel!
    
    var newsfeedNavigationController: UINavigationController!
    var newsfeedTabbarController: NewsFeedUITabBarController!
    
    var window: UIWindow?
    
    @IBAction func signInClicked(sender: AnyObject){
        if Reachability.isConnectedToNetwork() == true {
            self.signIn()
        }
        else{
            dispatch_async(dispatch_get_main_queue(), {
                //self.feedsTableView.hidden = true
                
                let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 90, self.view.frame.size.height-80, 90+90, 24))
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
        }
    }
    
    func signIn() {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if email == "" && password == "" {
            
            //            self.newsfeedTabbarController = UIStoryboard.centerViewController()
            //            self.newsfeedNavigationController = UINavigationController(rootViewController: self.newsfeedTabbarController)
            //            self.view.addSubview(self.newsfeedNavigationController.view)
            //            self.addChildViewController(self.newsfeedNavigationController)
            //
            //            UIApplication.sharedApplication().keyWindow?.rootViewController = self.newsfeedTabbarController;
            
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            passwordTextField.layer.borderColor = UIColor.redColor().CGColor
            passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            email_errorLabel.hidden = false
            email_errorLabel.text = "All fields are required"
            self.emailTextField.becomeFirstResponder()
        }
        else if email == "" || password == "" {
            
            if email == "" {
                emailTextField.layer.borderColor = UIColor.redColor().CGColor
                emailTextField.layer.borderWidth = CGFloat(Float (1.0))
                email_errorLabel.hidden = false
                email_errorLabel.text = "This is a required field"
                self.emailTextField.becomeFirstResponder()
            }
            if password == "" {
                passwordTextField.layer.borderColor = UIColor.redColor().CGColor
                passwordTextField.layer.borderWidth = CGFloat(Float (1.0))
                password_errorLabel.hidden = false
                password_errorLabel.text = "This is a required field"
                self.passwordTextField.becomeFirstResponder()
            }
        }
        else if email != "" && password != "" {
            
            let loginUrlString = "http://52.87.233.57:80/login"
            let loginUrl: NSURL = NSURL(string: loginUrlString)!
            
            let loginRequest: NSMutableURLRequest = NSMutableURLRequest(URL: loginUrl)
            loginRequest.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            let loginParams = ["email":email, "password":password] as Dictionary<String, String>
            loginRequest.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(loginParams, options: [])
            
            let task = session.dataTaskWithRequest(loginRequest, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    print("error=\(error)")
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 90, self.view.frame.size.height-80, 90+90, 24))
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
                                        if response_code == 3 {
                                            self.emailTextField.becomeFirstResponder()
                                            self.emailTextField.hidden = false
                                            self.emailTextField.text = "Please enter a valid NJIT email"
                                        }
                                        else if response_code == 5 {
                                            self.passwordTextField.becomeFirstResponder()
                                            self.password_errorLabel.hidden = false
                                            self.password_errorLabel.text = "Password miss match"
                                        }
                                        else if response_code == 1 {
                                            NSUserDefaults.standardUserDefaults().setObject(dict["uid"], forKey:"currentUser")
                                        NSUserDefaults.standardUserDefaults().setObject(dict["authorization"], forKey:"authorization")
                                            
                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isFirstTimeLogin")
                                            
                                            
                                            let viewController: UITabBarController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("NewsFeedTabBarController") as? UITabBarController
                                            //self.window?.rootViewController = viewController
            
                                            UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
                                            self.navigationController?.popToRootViewControllerAnimated(true)
                                            
                                            /*
                                            self.newsfeedTabbarController = UIStoryboard.centerViewController()
                                            self.newsfeedNavigationController = UINavigationController(rootViewController: self.newsfeedTabbarController)
                                            self.view.addSubview(self.newsfeedNavigationController.view)
                                            self.addChildViewController(self.newsfeedNavigationController)
                                            UIApplication.sharedApplication().keyWindow?.rootViewController = self.newsfeedTabbarController;
*/
                                        }
                                        else if response_code == -1 {
                                            
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
    }
    
    func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@njit+\\.edu"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    @IBAction func emailTextFieldEditingChanged(sender: AnyObject) {
        if !isValidEmail(emailTextField.text!){
            emailTextField.layer.borderColor = UIColor.redColor().CGColor
            emailTextField.layer.borderWidth = CGFloat(Float (1.0))
            
            email_errorLabel.hidden = false
            email_errorLabel.text = "Please enter a NJIT email"
        }
        else{
            email_errorLabel.hidden = true
            emailTextField.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    
    @IBAction func passwordTextFieldEditingChanged(sender: AnyObject) {
        password_errorLabel.hidden = true
        passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == self.emailTextField{
            self.emailTextField.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField{
            self.passwordTextField.resignFirstResponder()
            if Reachability.isConnectedToNetwork() == true {
                self.signIn()
            } else {
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
        /*
        let emailTextFieldborder = CALayer()
        let emailTextFieldwidth = CGFloat(1.0)
        emailTextFieldborder.borderColor = UIColor.darkGrayColor().CGColor
        emailTextFieldborder.frame = CGRect(x: 0, y: emailTextField.frame.size.height - emailTextFieldwidth, width:  emailTextField.frame.size.width + 50, height: emailTextField.frame.size.height)
        
        emailTextFieldborder.borderWidth = emailTextFieldwidth
        emailTextField.layer.addSublayer(emailTextFieldborder)
        emailTextField.layer.masksToBounds = true
        
        
        let passwordTextFieldborder = CALayer()
        let passwordTextFieldwidth = CGFloat(1.0)
        passwordTextFieldborder.borderColor = UIColor.darkGrayColor().CGColor
        passwordTextFieldborder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - passwordTextFieldwidth, width:  passwordTextField.frame.size.width + 50, height: passwordTextField.frame.size.height)
        
        passwordTextFieldborder.borderWidth = passwordTextFieldwidth
        passwordTextField.layer.addSublayer(passwordTextFieldborder)
        passwordTextField.layer.masksToBounds = true */
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        self.emailTextField.becomeFirstResponder()
        
        self.emailTextField.text = ""
        self.emailTextField.layer.borderColor = UIColor.clearColor().CGColor
        self.email_errorLabel.text = ""
        
        self.passwordTextField.text = ""
        self.passwordTextField.layer.borderColor = UIColor.clearColor().CGColor
        self.password_errorLabel.text = ""
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

private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func centerViewController() -> NewsFeedUITabBarController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("NewsFeedTabBarController") as? NewsFeedUITabBarController
    }
}
