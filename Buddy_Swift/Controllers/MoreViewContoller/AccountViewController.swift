//
//  AccountViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 24/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
  
    @IBOutlet weak var username_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if (NSUserDefaults.standardUserDefaults().stringForKey("name") != nil) {
            self.username_label.text =  NSUserDefaults.standardUserDefaults().stringForKey("name")
        }
        else{
            self.getUsername(NSUserDefaults.standardUserDefaults().integerForKey("currentUser"))
        }
    }
    
    func getUsername(uid: Int) {
        
        let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        let urlString = "http://52.87.233.57:80/profile/view"
        let url: NSURL = NSURL(string: urlString)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        
        let param = ["uid":uid] as Dictionary<String, Int>
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
                        if let dict = json as? NSDictionary {
                            // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                            if let response_code = dict["response_code"] as? Int {
                                print("response_code: \(response_code)")
                                dispatch_async(dispatch_get_main_queue(),{
                                    if response_code == 1 {
                                        self.username_label.text = dict["username"] as? String
                                        NSUserDefaults.standardUserDefaults().setObject(dict["username"] as? String, forKey:"name")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        segue.destinationViewController.hidesBottomBarWhenPushed = true;
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        
        let viewController: UIViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
        UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"currentUser")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"authorization")
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"name")
        
        self.navigationController?.popToRootViewControllerAnimated(true)
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
