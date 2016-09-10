//
//  HugsViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 28/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class HugsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pid: Int!
    var page: String!
    var hugsArray : NSArray!
    var postDictionary : NSDictionary!
    @IBOutlet weak var hugsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.pid = self.postDictionary.objectForKey("pid") as! Int
        let page = 0
        
        connectionRequest(self.pid, page: page)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(false)
    }
    
    //MARK: - Connection Request
    func connectionRequest(pid: Int, page: Int) {
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            print("authorization \(authorization)")
            
            
            let urlString = "http://52.87.233.57:80/post/hug/list"
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
                                        if response_code == 1 {
                                            self.hugsArray = dict["hugs"] as? NSArray
                                            print("hugsArray: \(self.hugsArray)")
                                            print("response_code: \(response_code)")
                                            
                                            if self.hugsArray != nil{
                                                self.hugsTableView.estimatedRowHeight = 50;
                                                self.hugsTableView.rowHeight = UITableViewAutomaticDimension;
                                                self.hugsTableView.reloadData()
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

    //MARK: - Tableview Delegate & Datasource
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        if self.hugsArray != nil{
            return self.hugsArray.count
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = self.hugsTableView.dequeueReusableCellWithIdentifier("hugsCustomCell")! as UITableViewCell
        
        //cell.textLabel?.text = self.hugsArray.objectAtIndex(indexPath.row).objectForKey("username") as? String
        
        if let nameLabel = cell.viewWithTag(100) as? UILabel {
            nameLabel.text = self.hugsArray.objectAtIndex(indexPath.row).objectForKey("username") as? String
        }
        
        return cell
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
