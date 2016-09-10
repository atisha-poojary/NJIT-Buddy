//
//  ProfileViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 24/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITextFieldDelegate {

    var postDictionary : NSDictionary!
    var uid: Int!
    var username: String!
    var category: Int!
    var textField: UITextField!
    
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var birthday_label: UILabel!
    @IBOutlet weak var sexuality_label: UILabel!
    @IBOutlet weak var race_label: UILabel!
    @IBOutlet weak var gender_label: UILabel!
    
    
    @IBOutlet weak var description_editButton: UIButton!
    @IBOutlet weak var birthday_editButton: UIButton!
    @IBOutlet weak var gender_editButton: UIButton!
    @IBOutlet weak var sexuality_editButton: UIButton!
    @IBOutlet weak var race_editButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.textField = UITextField()
        self.textField.delegate = self
        
        if self.isUserProfile() == true {
            if (NSUserDefaults.standardUserDefaults().stringForKey("name") != nil) {
                self.username_label.text =  NSUserDefaults.standardUserDefaults().stringForKey("name")
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            self.description_label.text = defaults.stringForKey("textField0")
            self.birthday_label.text = defaults.stringForKey("textField1")
            self.gender_label.text = defaults.stringForKey("textField2")
            self.sexuality_label.text = defaults.stringForKey("textField3")
            self.race_label.text = defaults.stringForKey("textField4")
            
            self.viewProfileInfoRequest(self.uid)
        }
        else{
            //others profile
            description_editButton.hidden = true
            birthday_editButton.hidden = true
            gender_editButton.hidden = true
            sexuality_editButton.hidden = true
            race_editButton.hidden = true
            
            self.viewProfileInfoRequest(self.uid)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editClicked(sender: AnyObject) {
        self.openInputField(sender.tag)
        self.category = sender.tag
    }
    
    func openInputField(category: Int) {
        let titleString: String?
        
        var description: String!
        let description_open = 1
        var birthday: String!
        let birthday_open = 1
        var gender: String!
        let gender_open = 1
        var sexuality: String!
        let sexuality_open = 1
        var race: String!
        let race_open = 1
        
        if category == 0 {
            titleString = "Input your self-introduction:"
        }
        else if category == 1{
            titleString = "Enter your Birthday:"
        }
        else if category == 2{
            titleString = "Enter your Gender:"
        }
        else if category == 3{
            titleString = "Enter your Sexuality:"
        }
        else if category == 4{
            titleString = "Enter your Race:"
        }
        else{
            titleString = ""
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let attributedString = NSAttributedString(string: titleString!, attributes: [
            NSFontAttributeName : UIFont.systemFontOfSize(17),
            NSForegroundColorAttributeName : UIColor(red:33.0/255, green:127.0/255, blue:242.0/255, alpha: 1.0)
            ])
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        
        alert.setValue(attributedString, forKey: "attributedMessage")
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            if let textFieldContents = defaults.stringForKey("textField\(category)") {
                textField.text = textFieldContents
            } else {
                textField.text = ""
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.textField = alert.textFields![0] as UITextField
            print("Text field: \(self.textField.text!)")

            if self.textField.text != "" {
                
                if category == 0 {
                    description = self.textField.text!
                    birthday = defaults.stringForKey("textField1")
                    gender = defaults.stringForKey("textField2")
                    sexuality = defaults.stringForKey("textField3")
                    race = defaults.stringForKey("textField4")
                }
                else if category == 1{
                    birthday = self.textField.text!
                    description = defaults.stringForKey("textField0")
                    gender = defaults.stringForKey("textField2")
                    sexuality = defaults.stringForKey("textField3")
                    race = defaults.stringForKey("textField4")
                }
                else if category == 2{
                    gender = self.textField.text!
                    description = defaults.stringForKey("textField0")
                    birthday = defaults.stringForKey("textField1")
                    sexuality = defaults.stringForKey("textField3")
                    race = defaults.stringForKey("textField4")
                }
                else if category == 3{
                    sexuality = self.textField.text!
                    description = defaults.stringForKey("textField0")
                    birthday = defaults.stringForKey("textField1")
                    gender = defaults.stringForKey("textField2")
                    race = defaults.stringForKey("textField4")
                }
                else if category == 4{
                    race = self.textField.text!
                    description = defaults.stringForKey("textField0")
                    birthday = defaults.stringForKey("textField1")
                    gender = defaults.stringForKey("textField2")
                    sexuality = defaults.stringForKey("textField3")
                }
                
                if description == nil {
                    description = ""
                }
                if birthday == nil {
                    birthday = ""
                }
                if gender == nil {
                    gender = ""
                }
                if sexuality == nil {
                    sexuality = ""
                }
                if race == nil {
                  race = ""
                }
                
                print("Post request \(self.username_label.text!) \(description) \(birthday) \(gender) \(sexuality) \(race)")
                self.postProfileInfoRequest(self.username_label.text!, description: description, description_open: description_open, birthday: birthday, birthday_open: birthday_open, gender: gender, gender_open: gender_open, sexuality: sexuality, sexuality_open: sexuality_open, race: race, race_open: race_open)
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func postProfileInfoRequest(username: String, description: String, description_open: Int, birthday: String, birthday_open: Int, gender: String, gender_open: Int, sexuality: String, sexuality_open: Int, race: String, race_open:Int) {
        
        let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        let urlString = "http://52.87.233.57:80/profile/edit"
        let url: NSURL = NSURL(string: urlString)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        
        let param = ["username":username, "description":description, "description_open":description_open, "birthday":birthday, "birthday_open":birthday_open, "gender":gender, "gender_open":gender_open, "sexuality":sexuality, "sexuality_open":sexuality_open, "race":race , "race_open":race_open ] as Dictionary<String, NSObject>
        //let param = ["username":"strider", "description":"", "description_open":1, "birthday":"", "birthday_open":1, "gender":"", "gender_open":1, "sexuality":"", "sexuality_open":1, "race":"" , "race_open":1 ] as Dictionary<String, NSObject>
       
        print(param)
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(param, options: [])
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
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
                    print("dict: \(dict)")
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
                                        
                                        if self.isUserProfile() == true {
                                            let defaults = NSUserDefaults.standardUserDefaults()
                                            defaults.setValue(self.textField.text, forKey: "textField\(self.category)")
                                        }
                     
                                        if self.category == 0 {
                                            self.description_label.text = self.textField.text
                                        }
                                        else if self.category == 1{
                                            self.birthday_label.text = self.textField.text
                                        }
                                        else if self.category == 2{
                                            self.gender_label.text = self.textField.text
                                        }
                                        else if self.category == 3{
                                            self.sexuality_label.text = self.textField.text
                                        }
                                        else if self.category == 4{
                                            self.race_label.text = self.textField.text
                                        }
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
    
    func viewProfileInfoRequest(uid: Int) {
        
        let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        let urlString = "http://52.87.233.57:80/profile/view"
        let url: NSURL = NSURL(string: urlString)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        
        let param = ["uid":self.uid] as Dictionary<String, Int>
        print("param: \(param)")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(param, options: [])
        request.setValue(authorization, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)
                if let dict = json as? NSDictionary {
                    // ... process the data
                    print("dict: \(dict)")
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
                                        self.username_label.text = dict["username"] as? String
                                        
                                        let defaults = NSUserDefaults.standardUserDefaults()
                                        
                                    
                                        if dict["description_open"] as? Int! == 1 {
                                            self.description_label.text = dict["description"] as? String
                                            if self.isUserProfile() == true {
                                                defaults.setValue(dict["description"] as? String, forKey: "textField0")
                                            }
                                        }
                                        else {
                                            self.description_label.text = ""
                                        }
                                        
                                        if dict["birthday_open"] as? Int! == 1 {
                                            self.birthday_label.text = dict["birthday"] as? String
                                            if self.isUserProfile() == true {
                                                defaults.setValue(dict["birthday"] as? String, forKey: "textField1")
                                            }
                                            
                                        }
                                        else {
                                            self.birthday_label.text = ""
                                        }
                                        
                                        if dict["gender_open"] as? Int! == 1 {
                                            self.gender_label.text = dict["gender"] as? String
                                            if self.isUserProfile() == true {
                                                defaults.setValue(dict["gender"] as? String, forKey: "textField2")
                                            }
                                        }
                                        else {
                                            self.gender_label.text = ""
                                        }
                                        
                                        if dict["sexuality_open"] as? Int! == 1 {
                                            self.sexuality_label.text = dict["sexuality"] as? String
                                            if self.isUserProfile() == true {
                                                defaults.setValue(dict["sexuality"] as? String, forKey: "textField3")
                                            }
                                        }
                                        else {
                                            self.sexuality_label.text = ""
                                        }

                                        if dict["race_open"] as? Int! == 1 {
                                            self.race_label.text = dict["race"] as? String
                                            if self.isUserProfile() == true {
                                                defaults.setValue(dict["race"] as? String, forKey: "textField4")
                                            }
                                        }
                                        else {
                                            self.race_label.text = ""
                                        }
                                        
                                        /*let defaults = NSUserDefaults.standardUserDefaults()
                                        defaults.setValue(self.textField.text, forKey: "textField\(self.category)")
                                        
                                        if self.category == 0 {
                                            self.description_label.text = self.textField.text
                                        }
                                        else if self.category == 1{
                                            self.birthday_label.text = self.textField.text
                                        }
                                        else if self.category == 2{
                                            self.gender_label.text = self.textField.text
                                        }
                                        else if self.category == 3{
                                            self.sexuality_label.text = self.textField.text
                                        }
                                        else if self.category == 4{
                                            self.race_label.text = self.textField.text
                                        }*/
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postSegue" {
            
            let destinationVC = storyboard!.instantiateViewControllerWithIdentifier("postsViewController") as! PostsViewController
            destinationVC.target_uid = self.uid
            
            //let vc = segue.destinationViewController
        }
    }
    
    
    @IBAction func pushButtonClicked(sender: AnyObject) {
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("postsViewController") as! PostsViewController
        
        vc.target_uid = self.uid
        
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }

    func isUserProfile() -> Bool {
        let n: Int! = self.navigationController?.viewControllers.count
        if let viewController = self.navigationController?.viewControllers[n-2] {
            if viewController.isKindOfClass(NewsFeedViewController) || viewController.isKindOfClass(CommentsViewController) || viewController.isKindOfClass(SpecialViewController) {
                
                self.uid = self.postDictionary.objectForKey("uid") as? Int
                self.username = self.postDictionary.objectForKey("username") as? String
                self.username_label.text = self.username
                
                if self.uid == NSUserDefaults.standardUserDefaults().integerForKey("currentUser") {
                    return true
                }
                else{
                    return false
                }
            }
            else {
                self.uid = NSUserDefaults.standardUserDefaults().integerForKey("currentUser")
                return true
            }
        }
        return true
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
