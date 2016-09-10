//
//  CommentsViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 18/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    var pID: Int!
    var page = 0
    
    var reverseArray : NSArray!
    var commentsArray: NSMutableArray = []
    
    var postDictionary : NSDictionary!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var textFieldContainerView: UIView!
    @IBOutlet var textFieldBottomConstraint: NSLayoutConstraint?
    
    var hasCommented : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tabBarController?.tabBar.hidden = true
        
        pID = self.postDictionary.objectForKey("pid") as? Int
        
        self.hasCommented = false
        
        let tapOnTabelView = UITapGestureRecognizer(target: self, action:#selector(CommentsViewController.handleTap(_:)))
        self.commentsTableView.addGestureRecognizer(tapOnTabelView)
        
        self.commentsTableView.estimatedSectionHeaderHeight = 40;
        self.commentsTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CommentsViewController.handleKeyboardNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CommentsViewController.handleKeyboardNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if Reachability.isConnectedToNetwork() == true {
            self.getCommentRequest(pID!, page: self.page)
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
        // Do any additional setup after loading the view.
    }
    
    func handleKeyboardNotification (notification: NSNotification){
        if let userInfo = notification.userInfo{
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
            
            let isKeyboardShowing = notification.name == UIKeyboardWillShowNotification
            
            self.textFieldBottomConstraint!.constant = isKeyboardShowing ? keyboardFrame!.size.height : 0
            
            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations:self.view.layoutIfNeeded, completion: {(completed) in
                
                if isKeyboardShowing {
                    /*
                    if (self.reverseArray.count != 0){
                        let indexPath = NSIndexPath(forItem: self.reverseArray.count-1, inSection: 1)
                        self.commentsTableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
                    }
                    
                    */
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCommentRequest(pid: Int, page: Int) {
        //var currentUser: String = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            print("authorization \(authorization)")
            
            
            let urlString = "http://52.87.233.57:80/comment/list"
            let url: NSURL = NSURL(string: urlString)!
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            let param = ["pid":pid, "page":page] as Dictionary<String, Int>
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
                                        if response_code == 5 {
                                            
                                        }
                                        else if response_code == 1 {
                                            /*
                                            self.commentsArray = dict["comments"] as? NSArray
                                            
                                            self.commentsArray = self.commentsArray.reverse()
                                            
                                            print("commentsArray: \(self.commentsArray)")
                                            print("response_code: \(response_code)")
                                            
                                            if self.commentsArray != nil{
                                                self.commentsTableView.estimatedRowHeight = 40;
                                                self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
                                                self.commentsTableView.reloadData()
                                            }
*/
                                          
                                            if let responseArray: NSArray = dict["comments"] as? NSArray{
                                                if responseArray.count == 0{
                                                    self.page -= 1
                                                    return
                                                }
                                                else {
                                                    if self.hasCommented == true {
                                                        self.commentsArray = (dict["comments"] as? NSMutableArray)!
                                                        self.hasCommented = false
                                                    }
                                                    else {
                                                        self.commentsArray.addObjectsFromArray((dict["comments"] as? NSArray)! as [AnyObject])
                                                    }
                                                    
                                                    if self.commentsArray.count != 0{
                                                        
                                                        print("commentsArray: \(self.commentsArray)")
                                                        
                                                        print("reverseArray: \(self.reverseArray)")
                                                        
                                                        self.reverseArray = self.commentsArray as NSArray
                                                        self.reverseArray = self.reverseArray.reverse()
                                                        
                                                        self.commentsTableView.estimatedRowHeight = 40;
                                                        self.commentsTableView.rowHeight = UITableViewAutomaticDimension;
                                                        
                                                        self.commentsTableView.reloadData()
                                                        /*
                                                        //test
                                                        let bottom = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
                                                       
                                                        self.commentsTableView.scrollToRowAtIndexPath(bottom, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true);
*/
                                                    }
                                                }
                                            }
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
    
    func postCommentRequest(pid: Int, content: String) {
        //var currentUser: String = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            print("authorization \(authorization)")
            
            let urlString = "http://52.87.233.57:80/comment/create"
            let url: NSURL = NSURL(string: urlString)!
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            let param = ["pid":pid, "content":content] as Dictionary<String, NSObject>
            print("param: \(param)")
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(param, options: [])
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
            
            let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                
                if error != nil {
                    print("error=\(error)")
                    if error?.code == -1009{
                        print("error_msg= The Internet connection appears to be offline.")
                        
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
                                        self.commentTextField.endEditing(true)
                                        self.commentTextField.text = ""
                                        
                                        if response_code == 1 {
                                            self.hasCommented = true
                                            self.getCommentRequest(self.pID, page:0)
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

    
    //MARK: - Tableview Delegate & Datasource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if self.reverseArray != nil{
            return self.reverseArray.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell:FeedsCustomCell = (self.commentsTableView?.dequeueReusableCellWithIdentifier("feedsCustomCell") as! FeedsCustomCell!)
        
        cell.nameLabel.text = self.postDictionary.objectForKey("username") as? String
        
        //cell.nameButton.tag = indexPath.row
        cell.nameButton.addTarget(self, action: #selector(CommentsViewController.nameClickedOnSection0(_:)), forControlEvents: .TouchUpInside)
        
        cell.timeStampLabel.text = timeStringFromUnixTime ((self.postDictionary.objectForKey("timestamp") as? Double)!)
        
        cell.messageLabel.text = self.postDictionary.objectForKey("content") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let commentCell:CommentsCustomCell = (self.commentsTableView?.dequeueReusableCellWithIdentifier("commentsCustomCell") as! CommentsCustomCell!)
        commentCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        commentCell.nameAndTimeStampLabel.text = "\(self.reverseArray.objectAtIndex(indexPath.row).objectForKey("username") as! String) [\(timeStringFromUnixTime ((self.reverseArray.objectAtIndex(indexPath.row).objectForKey("timestamp") as? Double)!))]"
        
        let myRange = NSRange(location: (self.reverseArray.objectAtIndex(indexPath.row).objectForKey("username") as! String).characters.count+1, length: (timeStringFromUnixTime ((self.reverseArray.objectAtIndex(indexPath.row).objectForKey("timestamp") as? Double)!)).characters.count+2)
        //let myAttribute = [ NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14.0)! ]
        let myString = NSMutableAttributedString(string: commentCell.nameAndTimeStampLabel.text!)
        
        myString.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: myRange)
        myString.addAttribute(NSFontAttributeName,
            value: UIFont(name: "HelveticaNeue", size: 14.0)!, range: myRange)
        
        //            let attrString = NSAttributedString(string: " [\(timeStringFromUnixTime ((self.reverseArray.objectAtIndex(indexPath.row).objectForKey("timestamp") as? Double)!))]")
        //            myString.appendAttributedString(attrString)
        
        commentCell.nameAndTimeStampLabel.attributedText = myString
        
        
        commentCell.nameButton.tag = indexPath.row
        commentCell.nameButton.addTarget(self, action: #selector(CommentsViewController.nameClickedOnSection1(_:)), forControlEvents: .TouchUpInside)
        
        commentCell.commentLabel.text = self.reverseArray.objectAtIndex(indexPath.row).objectForKey("content") as? String
        
        return commentCell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        self.hasCommented = false
        if self.reverseArray == nil {
           return
        }
        else {
            if indexPath.row+1 == self.reverseArray.count {
                print("last row reached")
                if self.page == 0 {
                    self.page += 1
                }
                else if self.page > 0 {
                    self.getCommentRequest(self.pID, page: self.page)
                    self.page += 1
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.commentTextField.endEditing(true)
    }
    
    func timeStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970:(unixTime)/1000)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        //dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        //dateFormatter.timeStyle = .MediumStyle
        return dateFormatter.stringFromDate(date)
    }
   
    func nameClickedOnSection0(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        let postDictionary: NSDictionary = self.postDictionary;
        print("postDictionary: \(postDictionary)")
        vc.postDictionary = postDictionary
        //self.presentViewController(vc, animated:true, completion:nil)
        
        //when navigation controller is present
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    func nameClickedOnSection1(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        let postDictionary: NSDictionary = (self.reverseArray.objectAtIndex(sender.tag) as? NSDictionary)!
        print("postDictionary: \(postDictionary)")
        vc.postDictionary = postDictionary
        
        vc.hidesBottomBarWhenPushed = true
        
        //self.presentViewController(vc, animated:true, completion:nil)
        
        //when navigation controller is present
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    // MARK: Gesture recognizer
    func handleTap(recognizer: UITapGestureRecognizer){
        self.commentTextField.endEditing(true)
    }

    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        if self.commentTextField.text! != ""{
            self.postCommentRequest(pID, content: self.commentTextField.text!)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        if textField == self.commentTextField{
            if self.commentTextField.text! != ""{
                if Reachability.isConnectedToNetwork() == true {
                    self.postCommentRequest(pID, content: self.commentTextField.text!)
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
        }
        return true
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
