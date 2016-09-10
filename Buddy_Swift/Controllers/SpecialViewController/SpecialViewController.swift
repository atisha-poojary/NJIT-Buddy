//
//  SpecialViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 20/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class SpecialViewController: UIViewController {

    @IBOutlet weak var specialFeedsTableView: UITableView!
    var postsArray : NSMutableArray = []
    var refreshControl: UIRefreshControl!
    var i = 0
    var categoryType = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(SpecialViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.specialFeedsTableView.addSubview(refreshControl)
        
        //self.connectionRequest (0, category: -1, attention: 1, target_uid: 0)
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if Reachability.isConnectedToNetwork() == true {
            if self.postsArray.count != 0{
                self.postsArray.removeAllObjects()
            }
            self.i = 0
            self.connectionRequest (0, category: -1, attention: 1, target_uid: 0)
        }
        else{
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
//                                            self.postsArray = dict["posts"] as? NSArray
//                                            print("post: \(self.postsArray)")
//                                            print("response_code: \(response_code)")
//                                            
//                                            if self.postsArray != nil{
//                                                self.specialFeedsTableView.estimatedRowHeight = 35;
//                                                self.specialFeedsTableView.rowHeight = UITableViewAutomaticDimension;
//                                                self.specialFeedsTableView.reloadData()
//                                            }
                                            
                                            if let responseArray: NSArray = dict["posts"] as? NSArray{
                                                if responseArray.count == 0{
                                                    self.i-=1
                                                    return
                                                }
                                                else {
                                                    print("post1: \(self.postsArray)")
                                                    self.postsArray.addObjectsFromArray((dict["posts"] as? NSArray)! as [AnyObject])
                                                    print("post2: \(self.postsArray)")
                                                    
                                                    print("post2 count: \(self.postsArray.count)")
                                                    
                                                    self.specialFeedsTableView.estimatedRowHeight = 35;
                                                    self.specialFeedsTableView.rowHeight = UITableViewAutomaticDimension;
                                                    self.specialFeedsTableView.reloadData()
                                                    
                                                    if self.postsArray.count != 0{
                                                        
                                                    }
                                                }
                                            }
                                            
                                            //self.readJSONObject(dict as! [String : AnyObject])
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
        let cell:FeedsCustomCell = (self.specialFeedsTableView?.dequeueReusableCellWithIdentifier("feedsCustomCell") as! FeedsCustomCell!)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None

        if self.postsArray.count != 0 {
            
            print(" \(self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int) and \(NSUserDefaults.standardUserDefaults().integerForKey("currentUser"))  ")
            
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int == NSUserDefaults.standardUserDefaults().integerForKey("currentUser"){
                
                NSUserDefaults.standardUserDefaults().setObject(self.postsArray.objectAtIndex(indexPath.row).objectForKey("username"), forKey:"username")
            }
            
            cell.nameLabel.text = self.postsArray.objectAtIndex(indexPath.row).objectForKey("username") as? String
            
            cell.nameButton.tag = indexPath.row
            cell.nameButton.addTarget(self, action: #selector(SpecialViewController.nameClickedOnCell(_:)), forControlEvents: .TouchUpInside)
            
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
            
            cell.flagButton.addTarget(self, action: #selector(SpecialViewController.flag_bell_hug_postRequest(_:)), forControlEvents: .TouchUpInside)
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
                cell.commentsButton.addTarget(self, action: #selector(SpecialViewController.commentsClickedOnCell(_:)), forControlEvents: .TouchUpInside)
                /*
                //hide bell
                cell.bellButton.hidden = true
*/
            }
            else{
                cell.commentsButton.hidden=true
                cell.commentsCountLabel.hidden=true
                
                /*
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
                cell.bellButton.addTarget(self, action: "flag_bell_hug_postRequest:", forControlEvents: .TouchUpInside)
                cell.bellButton.tag = (self.postsArray.objectAtIndex(indexPath.row).objectForKey("pid") as! Int)

*/
            }
            
            
            
            if self.postsArray.objectAtIndex(indexPath.row).objectForKey("uid") as! Int == NSUserDefaults.standardUserDefaults().integerForKey("currentUser"){
                
                cell.flagButton.hidden = true
                //cell.bellButton.hidden = true
                
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
                    cell.huggersButton.addTarget(self, action: #selector(SpecialViewController.hugsClickedOnCell(_:)), forControlEvents: .TouchUpInside)
                }
            }
            else {
                /*
                if self.postsArray.objectAtIndex(indexPath.row).objectForKey("category") as! Int == 1{
                    
                    //hide bell
                    cell.bellButton.hidden = true
                }
                else {
                    cell.bellButton.hidden = false
                }
*/
                
                cell.flagButton.hidden = false
                
                cell.hugButton.userInteractionEnabled = true
                cell.huggersButton.hidden = true
                cell.hugsCountLabel.hidden=true
                
                cell.hugButton.addTarget(self, action: #selector(SpecialViewController.flag_bell_hug_postRequest(_:)), forControlEvents: .TouchUpInside)
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
                self.connectionRequest (self.i, category: -1, attention: 1, target_uid: 0)
                self.i += 1
            }
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

    func refresh(sender:AnyObject) {
        // Code to refresh table view
        if Reachability.isConnectedToNetwork() == true {
            if self.postsArray.count != 0{
                self.postsArray.removeAllObjects()
                self.i = 0
            }
            self.connectionRequest (0, category: -1, attention: 1, target_uid: 0)
        }
        else{
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
        }
        refreshControl.endRefreshing()
    }
    
    
    // MARK: - Cell's button fuctions
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
