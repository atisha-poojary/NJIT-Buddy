//
//  ChangePasswordViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 24/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var currentPassword_textField: UITextField!
    @IBOutlet weak var newPassword_textField: UITextField!
    @IBOutlet weak var confirmNewPassword_textField: UITextField!
    
    @IBOutlet weak var currentPassword_errorLabel: UILabel!
    @IBOutlet weak var newPassword_errorLabel: UILabel!
    @IBOutlet weak var confirmNewPassword_errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitButtonClicked(sender: AnyObject) {
        self.currentPassword_textField.resignFirstResponder()
        self.newPassword_textField.resignFirstResponder()
        self.confirmNewPassword_textField.resignFirstResponder()
        self.changePassword()
    }
    
    func changePassword(){
        
        let currentPassword = currentPassword_textField.text!
        let newPassword = newPassword_textField.text!
        let confirmNewPassword = confirmNewPassword_textField.text!
        
        if currentPassword == "" && newPassword == "" && confirmNewPassword == "" {
            
            currentPassword_textField.layer.borderColor = UIColor.redColor().CGColor
            currentPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
            
            newPassword_textField.layer.borderColor = UIColor.redColor().CGColor
            newPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
            
            confirmNewPassword_textField.layer.borderColor = UIColor.redColor().CGColor
            confirmNewPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
            
            currentPassword_errorLabel.hidden = false
            currentPassword_errorLabel.text = "All fields are required"
        }
        else if currentPassword == "" || newPassword == "" || confirmNewPassword == "" {
            
            if currentPassword == "" {
                currentPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                currentPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
                
                currentPassword_errorLabel.hidden = false
                currentPassword_errorLabel.text = "This is a required field"
            }
            if newPassword == "" {
                newPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                newPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
                
                newPassword_errorLabel.hidden = false
                newPassword_errorLabel.text = "This is a required field"
            }
            if confirmNewPassword == "" {
                confirmNewPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                confirmNewPassword_textField.layer.borderWidth = CGFloat(Float (1.0))
                
                confirmNewPassword_errorLabel.hidden = false
                confirmNewPassword_errorLabel.text = "This is a required field"
            }
        }
            
        else if currentPassword != "" && newPassword != "" && confirmNewPassword != ""{
            
            if newPassword.characters.count < 8 {
                newPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                newPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                
                newPassword_errorLabel.hidden = false
                newPassword_errorLabel.text = "Password must be atleast 8 characters long"
            }
            else {
                if newPassword != confirmNewPassword {
                    confirmNewPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                    confirmNewPassword_textField.layer.borderColor = UIColor.redColor().CGColor
                    
                    confirmNewPassword_errorLabel.hidden = false
                    confirmNewPassword_errorLabel.text = "Password did not match"
                }
                else{
                    
                    let urlString = "http://52.87.233.57:80/password/change"
                    let url: NSURL = NSURL(string: urlString)!
                    
                    let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
                    request.HTTPMethod = "POST"
                    let session = NSURLSession.sharedSession()
                    
                    let loginParams = ["old_password":currentPassword, "new_password":newPassword] as Dictionary<String, String>
                    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(loginParams, options: [])
                    
                    let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
                    request.setValue(authorization, forHTTPHeaderField: "Authorization")
                    
                    
                    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                        
                        if error != nil {
                            print("error=\(error)")
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
                                                if response_code == 5 {
                                                    self.currentPassword_errorLabel.hidden = false
                                                    self.currentPassword_errorLabel.text = "Password miss match"
                                                }
                                                else if response_code == 1 {
                                                    
                                                    let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 110, self.view.frame.size.height-80, 220, 24))
                                                    toastLabel.backgroundColor = UIColor.blackColor()
                                                    toastLabel.textColor = UIColor.whiteColor()
                                                    toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 14.5)
                                                    toastLabel.textAlignment = NSTextAlignment.Center;
                                                    self.view.addSubview(toastLabel)
                                                    toastLabel.text = "Password has been changed."
                                                    toastLabel.alpha = 1.0
                                                    toastLabel.layer.cornerRadius = 4;
                                                    toastLabel.layer.borderColor = UIColor.whiteColor().CGColor
                                                    toastLabel.layer.borderWidth = CGFloat(Float (2.0))
                                                    toastLabel.clipsToBounds = true
                                                    
                                                    UIView.animateWithDuration(2.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                                                        
                                                        toastLabel.alpha = 0.0
                                                        
                                                        }, completion: nil)
                                                    
                                                    self.currentPassword_textField.text = ""
                                                    self.newPassword_textField.text = ""
                                                    self.confirmNewPassword_textField.text = ""
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
        }
    }
    
    @IBAction func currentPassword_textFieldEditingChanged(sender: AnyObject) {
        currentPassword_errorLabel.hidden = true
        currentPassword_textField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    @IBAction func newPassword_textFieldEditingChanged(sender: AnyObject) {
        newPassword_errorLabel.hidden = true
        newPassword_textField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    @IBAction func confirmNewPassword_textFieldEditingChanged(sender: AnyObject) {
        confirmNewPassword_errorLabel.hidden = true
        confirmNewPassword_textField.layer.borderColor = UIColor.clearColor().CGColor
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == self.currentPassword_textField{
            self.currentPassword_textField.resignFirstResponder()
            self.newPassword_textField.becomeFirstResponder()
        }
        if textField == self.newPassword_textField{
            self.newPassword_textField.resignFirstResponder()
            self.confirmNewPassword_textField.becomeFirstResponder()
        }
        if textField == self.confirmNewPassword_textField{
            self.confirmNewPassword_textField.resignFirstResponder()
            self.changePassword()
        }
        return true
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
