//
//  NewsFeedViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 06/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class NewsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    //feedsTableViewCellDelegate
    
    @IBOutlet weak var introduction_imageView: UIImageView!
    @IBOutlet weak var feedsTableView: UITableView!
    @IBOutlet weak var categoryName: UILabel!
    var postsArray: NSMutableArray = []
    var refreshControl: UIRefreshControl!
    var i = 0
    var categoryType = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if NSUserDefaults.standardUserDefaults().boolForKey("isFirstTimeLogin") == true{
            self.introduction_imageView.hidden = false
            let tapOnImageView = UITapGestureRecognizer(target: self, action:#selector(NewsFeedViewController.handleTap(_:)))
            self.introduction_imageView.addGestureRecognizer(tapOnImageView)
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isFirstTimeLogin")
            
            let tabBarControllerItems = self.tabBarController?.tabBar.items
            
            if let arrayOfTabBarItems = tabBarControllerItems as! AnyObject as? NSArray{
                
                let tabBarItem_1 = arrayOfTabBarItems[0] as! UITabBarItem
                tabBarItem_1.enabled = false
                
                let tabBarItem_2 = arrayOfTabBarItems[1] as! UITabBarItem
                tabBarItem_2.enabled = false
                
                let tabBarItem_3 = arrayOfTabBarItems[2] as! UITabBarItem
                tabBarItem_3.enabled = false
            }
        }
        else{
            self.introduction_imageView.hidden = true
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(NewsFeedViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.feedsTableView.addSubview(refreshControl)
        
        self.categoryType = -1
        //self.connectionRequest (0, category:self.categoryType, attention: 0, target_uid: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        if Reachability.isConnectedToNetwork() == true {
            if self.postsArray.count != 0{
                self.postsArray.removeAllObjects()
                self.i = 0
                self.connectionRequest (0, category: self.categoryType, attention: 0, target_uid: 0)
            }
            else{
                self.i = 0
                self.connectionRequest (0, category: self.categoryType, attention: 0, target_uid: 0)
            }
        } else {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func connectionRequest(page: Int, category: Int, attention: Int, target_uid: Int) {
        //var currentUser: String = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            print("authorization \(authorization)")
        
        
        let urlString = "http://52.87.233.57:80/post/list"
        let url: NSURL = NSURL(string: urlString)!
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let session = NSURLSession.sharedSession()
        
        let param = ["page":page, "category":category, "attention":attention, "target_uid":target_uid] as Dictionary<String, Int>
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
                
                //self.feedsTableView.hidden = false
                
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

//                                        self.postsArray.addObject((dict["posts"] as? NSArray)!)
//                                        
//                                        print("post: \(self.postsArray)")
//                                        print("response_code: \(response_code)")
//                                        
//                                        self.postsArray = self.postsArray[0] as! NSMutableArray
//                                        print("self.postsArray: \(self.postsArray)")
                                        
//                                        if let reponseArray = (dict["posts"] as? NSArray {
//                                            print("post1: \(reponseArray)")
//                                        }
                                        
                                        if let responseArray: NSArray = dict["posts"] as? NSArray{
                                            if responseArray.count == 0{
                                                self.i -= 1 
                                                return
                                            }
                                            else {
                                                print("post1: \(self.postsArray)")
                                                self.postsArray.addObjectsFromArray((dict["posts"] as? NSArray)! as [AnyObject])
                                                print("post2: \(self.postsArray)")
                                                
                                                print("post2 count: \(self.postsArray.count)")
                                                
                                                if self.postsArray.count != 0{
                                                    self.feedsTableView.estimatedRowHeight = 35;
                                                    self.feedsTableView.rowHeight = UITableViewAutomaticDimension;
                                                    self.feedsTableView.reloadData()
                                                }
                                            }
                                        }
                                        //self.readJSONObject(dict as! [String : AnyObject])
                                    }
                                    else if response_code == -1 {
                                        
                                    }
                                    else if response_code == 100 {
                                        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 110, self.view.frame.size.height-80, 220, 24))
                                        toastLabel.backgroundColor = UIColor.blackColor()
                                        toastLabel.textColor = UIColor.whiteColor()
                                        toastLabel.font = UIFont(name: toastLabel.font.fontName, size: 15)
                                        toastLabel.textAlignment = NSTextAlignment.Center;
                                        self.view.addSubview(toastLabel)
                                        toastLabel.text = "Login is required."
                                        toastLabel.alpha = 1.0
                                        toastLabel.layer.cornerRadius = 5;
                                        toastLabel.clipsToBounds  =  true
                                        
                                        UIView.animateWithDuration(4.0, delay: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations:{
                                            
                                            toastLabel.alpha = 0.0
                                            
                                            }, completion: {(completed) in
                                                let viewController: UIViewController? = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController")
                                                UIApplication.sharedApplication().keyWindow?.rootViewController = viewController
                                                
                                                NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"currentUser")
                                                NSUserDefaults.standardUserDefaults().setObject(nil, forKey:"authorization")
                                                
                                                self.navigationController?.popToRootViewControllerAnimated(true)
                                        })
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
        if self.postsArray.count != 0{
            return self.postsArray.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
         let cell:FeedsCustomCell = (self.feedsTableView?.dequeueReusableCellWithIdentifier("feedsCustomCell") as! FeedsCustomCell!)
        
//        if let nameLabel = cell.viewWithTag(100) as? UILabel {
//            nameLabel.text = self.postsArray.objectAtIndex(indexPath.row).objectForKey("username") as? String
//        }
        
        if self.postsArray.count != 0 {
            
            print(" \(self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int) and \(NSUserDefaults.standardUserDefaults().integerForKey("currentUser"))  ")
            
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int == NSUserDefaults.standardUserDefaults().integerForKey("currentUser"){
                
                NSUserDefaults.standardUserDefaults().setObject(self.postsArray.objectAtIndex(indexPath.row).objectForKey("username"), forKey:"username")
            }            
            
            cell.nameLabel.text = self.postsArray.objectAtIndex(indexPath.row).objectForKey("username") as? String
            
            cell.nameButton.tag = indexPath.row
            cell.nameButton.addTarget(self, action: #selector(NewsFeedViewController.nameClickedOnCell(_:)), forControlEvents: .TouchUpInside)
            
            cell.timeStampLabel.text = timeStringFromUnixTime ((self.postsArray.objectAtIndex(indexPath.row).objectForKey("timestamp") as? Double)!)
            
            cell.messageLabel.text = self.postsArray.objectAtIndex(indexPath.row).objectForKey("content") as? String
            
            print("indexPath: \(indexPath.row)")
            
            //set flag
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("flagged") as! Int == 1{
                cell.flagButton.setImage(UIImage(named: "ic_flag_selected.png")!, forState: .Normal)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_flag")
            }
            else{
                cell.flagButton.setImage(UIImage(named: "ic_flag_unselected.png")!, forState: .Normal)
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_flag")
            }
            
            cell.flagButton.addTarget(self, action: #selector(NewsFeedViewController.flag_bell_hug_postRequest(_:)), forControlEvents: .TouchUpInside)
            cell.flagButton.tag = (self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)
            
            
            //set hug
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("hugged") as! Int == 1{
                cell.hugButton.setImage(UIImage(named: "ic_hug_selected.png")!, forState: .Normal)
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_hug")
            }
            else{
                cell.hugButton.setImage(UIImage(named: "ic_hug_unselected.png")!, forState: .Normal)
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_hug")
            }
            
            
            // category = ASK
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("category") as! Int == 1{
                cell.commentsButton.hidden=false
                cell.commentsCountLabel.hidden=false
                cell.commentsCountLabel.text = "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("comments") as! Int)"
                //String (self.postsArray.objectAtIndex(indexPath.row).objectForKey("comments") as? Int)
                cell.commentsButton.tag = indexPath.row
                cell.commentsButton.addTarget(self, action: #selector(NewsFeedViewController.commentsClickedOnCell(_:)), forControlEvents: .TouchUpInside)
                
                //hide bell
                cell.bellButton.hidden = true
            }
            else{
                cell.commentsButton.hidden=true
                cell.commentsCountLabel.hidden=true
                
                //show bell
                cell.bellButton.hidden = false
                
                //set bell
                if self.postsArray.objectAtIndex(indexPath.row).objectForKey("belled") as! Int == 1{
                    cell.bellButton.setImage(UIImage(named: "ic_bell_selected.png")!, forState: .Normal)
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_bell")
                }
                else{
                    cell.bellButton.setImage(UIImage(named: "ic_bell_unselected.png")!, forState: .Normal)
                    NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)_bell")
                }
                
                //set target action for bell
                cell.bellButton.addTarget(self, action: #selector(NewsFeedViewController.flag_bell_hug_postRequest(_:)), forControlEvents: .TouchUpInside)
                cell.bellButton.tag = (self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)
            }
            
            
            
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int == NSUserDefaults.standardUserDefaults().integerForKey("currentUser"){
                
                cell.flagButton.hidden = true
                cell.bellButton.hidden = true
                
                cell.hugButton.userInteractionEnabled = false
                cell.huggersButton.hidden = false
                
                if self.postsArray.objectAtIndex(indexPath.row).objectForKey("hugs") as! Int == 0{
                    cell.hugsCountLabel.hidden=true
                }
                else{
                    cell.hugButton.hidden=false
                    cell.hugsCountLabel.hidden=false
                    cell.hugsCountLabel.text = "\(self.postsArray.objectAtIndex(indexPath.row).objectForKey("hugs") as! Int)"
                    cell.huggersButton.tag = indexPath.row
                    cell.huggersButton.addTarget(self, action: #selector(NewsFeedViewController.hugsClickedOnCell(_:)), forControlEvents: .TouchUpInside)
                }
            }
            else {
                
                if self.postsArray.objectAtIndex(indexPath.row).objectForKey("category") as! Int == 1{
                    
                    //hide bell
                    cell.bellButton.hidden = true
                }
                else {
                    cell.bellButton.hidden = false
                }
                
                cell.flagButton.hidden = false
                
                cell.hugButton.userInteractionEnabled = true
                cell.huggersButton.hidden = true
                cell.hugsCountLabel.hidden=true
                
                cell.hugButton.addTarget(self, action: #selector(NewsFeedViewController.flag_bell_hug_postRequest(_:)), forControlEvents: .TouchUpInside)
                cell.hugButton.tag = (self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row+1 == self.postsArray.count {
            print("last row reached")
            if self.i == 0 {
                self.i += 1
            }
            else if self.i > 0 {
                self.connectionRequest (self.i, category: self.categoryType, attention: 0, target_uid: 0)
                self.i += 1
            }
        }
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        if let posts = object["posts"] as? NSDictionary {
            print("post: \(posts)")
        }
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
    
    
    @IBAction func changeCategoryClicked(sender: UIButton) {
        
        let top = NSIndexPath(forRow: Foundation.NSNotFound, inSection: 0);
        self.feedsTableView.scrollToRowAtIndexPath(top, atScrollPosition: UITableViewScrollPosition.Top, animated: true);
        
        if Reachability.isConnectedToNetwork() == true {
            
            switch sender.tag {
            case 0:
                if self.postsArray.count != 0{
                    self.i = 0
                    self.postsArray.removeAllObjects()
                }
                
                    if categoryName.text == "All"{
                        categoryName.text = "Announce"
                        self.categoryType = 5
                    }
                    else if categoryName.text == "Announce"{
                        categoryName.text = "Encourage"
                        self.categoryType = 4
                    }
                    else if categoryName.text == "Encourage"{
                        categoryName.text = "Laugh"
                        self.categoryType = 3
                    }
                    else if categoryName.text == "Laugh"{
                        categoryName.text = "Vent"
                        self.categoryType = 2
                    }
                    else if categoryName.text == "Vent"{
                        categoryName.text = "Ask"
                        self.categoryType = 1
                    }
                    else if categoryName.text == "Ask"{
                        categoryName.text = "Confess"
                        self.categoryType = 0
                    }
                    else if categoryName.text == "Confess"{
                        categoryName.text = "All"
                        self.categoryType = -1
                    }
                    
                    self.connectionRequest (0, category: self.categoryType, attention: 0, target_uid: 0)
                
            case 1:
                if self.postsArray.count != 0{
                    self.i = 0
                    self.postsArray.removeAllObjects()
                }
                
                    if categoryName.text == "All"{
                        categoryName.text = "Confess"
                        self.categoryType = 0
                    }
                    else if categoryName.text == "Confess"{
                        categoryName.text = "Ask"
                        self.categoryType = 1
                    }
                    else if categoryName.text == "Ask"{
                        categoryName.text = "Vent"
                        self.categoryType = 2
                    }
                    else if categoryName.text == "Vent"{
                        categoryName.text = "Laugh"
                        self.categoryType = 3
                    }
                    else if categoryName.text == "Laugh"{
                        categoryName.text = "Encourage"
                        self.categoryType = 4
                    }
                    else if categoryName.text == "Encourage"{
                        categoryName.text = "Announce"
                        self.categoryType = 5
                    }
                    else if categoryName.text == "Announce"{
                        categoryName.text = "All"
                        self.categoryType = -1
                    }
                    
                    self.connectionRequest (0, category: self.categoryType, attention: 0, target_uid: 0)
            
                
            default:
                print("default")
        
            }
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

    func nameClickedOnCell(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("profileViewController") as! ProfileViewController
        
        let postDictionary: NSDictionary = (self.postsArray.objectAtIndex(sender.tag) as? NSDictionary)!
        print("postDictionary: \(postDictionary)")
        vc.postDictionary = postDictionary
        
        vc.hidesBottomBarWhenPushed = true
        
        //self.presentViewController(vc, animated:true, completion:nil)
        
        //when navigation controller is present
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    func commentsClickedOnCell(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("commentsViewController") as! CommentsViewController
        
        let postDictionary: NSDictionary = (self.postsArray.objectAtIndex(sender.tag) as? NSDictionary)!
        print("postDictionary: \(postDictionary)")
        vc.postDictionary = postDictionary
        
        vc.hidesBottomBarWhenPushed = true
        
        //self.presentViewController(vc, animated:true, completion:nil)

        //when navigation controller is present
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    func hugsClickedOnCell(sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("hugsViewController") as! HugsViewController
        
        let postDictionary: NSDictionary = (self.postsArray.objectAtIndex(sender.tag) as? NSDictionary)!
        print("postDictionary: \(postDictionary)")
        vc.postDictionary = postDictionary
        
        vc.hidesBottomBarWhenPushed = true
        
        //self.presentViewController(vc, animated:true, completion:nil)
        
        //when navigation controller is present
        self.navigationController?.showViewController(vc, sender: nil)
    }
    
    func flag_bell_hug_postRequest(sender: UIButton) {
        let pid = sender.tag

        let isFlagBellHug = sender.titleLabel!.text!
        
        let isSelected = NSUserDefaults.standardUserDefaults().boolForKey("\(pid)_\(isFlagBellHug)")
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            
            let urlString = "http://52.87.233.57:80/post/\(isFlagBellHug)"
            print("urlString: \(urlString)")
            let url: NSURL = NSURL(string: urlString)!
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            let param = ["pid":pid] as Dictionary<String, NSObject>
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
                        print("flag_bell_hug_postRequest_dict: \(dict)")
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
                                            if isSelected == false {
                                                sender.setImage(UIImage(named: "ic_\(isFlagBellHug)_selected.png")!, forState: .Normal)
                                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "\(pid)_\(isFlagBellHug)")
                                            }
                                            else{
                                                sender.setImage(UIImage(named: "ic_\(isFlagBellHug)_unselected.png")!, forState: .Normal)
                                                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "\(pid)_\(isFlagBellHug)")
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
    }

    @IBAction func addButtonClicked(sender: AnyObject) {
        //self.performSegueWithIdentifier("showPopover", sender: self)
        
        let popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("showPopoverContoller")
        
        popoverContent!.modalPresentationStyle = .Popover
        _ = popoverContent!.popoverPresentationController
        
        if let popover = popoverContent!.popoverPresentationController {
            
            let viewForSource = sender as! UIView
            popover.sourceView = viewForSource
            
            // the position of the popover where it's showed
            popover.sourceRect = viewForSource.bounds
            
            // the size you want to display
            popoverContent!.preferredContentSize = CGSizeMake(281,318)
            popover.delegate = self
        }            
        
        self.presentViewController(popoverContent!, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showPopover" {
            let vc = segue.destinationViewController
            let controller = vc.popoverPresentationController
            if controller != nil {
                controller?.delegate = self
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        
        if self.postsArray.count != 0{
            self.postsArray.removeAllObjects()
            self.i = 0
        }
        
        if categoryName.text == "All"{
            self.connectionRequest (0, category: -1, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Confess"{
            self.connectionRequest (0, category: 0, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Ask"{
            self.connectionRequest (0, category: 1, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Vent"{
            self.connectionRequest (0, category: 2, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Laugh"{
            self.connectionRequest (0, category: 3, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Encourage"{
            self.connectionRequest (0, category: 4, attention: 0, target_uid: 0)
        }
        else if categoryName.text == "Announce"{
            self.connectionRequest (0, category: 5, attention: 0, target_uid: 0)
        }
        refreshControl.endRefreshing()
    }

    func handleTap(recognizer: UITapGestureRecognizer){
        self.introduction_imageView.hidden = true
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let arrayOfTabBarItems = tabBarControllerItems as! AnyObject as? NSArray{
            
            let tabBarItem_1 = arrayOfTabBarItems[0] as! UITabBarItem
            tabBarItem_1.enabled = true
            
            let tabBarItem_2 = arrayOfTabBarItems[1] as! UITabBarItem
            tabBarItem_2.enabled = true
            
            let tabBarItem_3 = arrayOfTabBarItems[2] as! UITabBarItem
            tabBarItem_3.enabled = true
        }
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
