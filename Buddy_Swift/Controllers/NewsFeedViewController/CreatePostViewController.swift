//
//  CreatePostViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 19/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class CreatePostViewController: UIViewController, UITextViewDelegate {
    
    var textView : UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func categoryClicked(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == true {
            let button = sender as! UIButton
            button.backgroundColor = UIColor(red: 85.0/255.0, green: 85.0/255.0, blue: 85.0/255.0, alpha: 0.1)
            self.openInputField(sender.tag)
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
    
    func imageFromColor(colour: UIColor) -> UIImage
    {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, colour.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func openInputField(category: Int) {
        
        let attributedString = NSAttributedString(string: "Say something...", attributes: [
            NSFontAttributeName : UIFont.systemFontOfSize(17),
            NSForegroundColorAttributeName : UIColor(red:33.0/255, green:127.0/255, blue:242.0/255, alpha: 1.0)
            ])
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        
//        //let margin:CGFloat = 8.0
//        let rect = CGRectMake(15, 45, 240, 50)
//        textView = UITextView(frame: rect)
//        textView.font               = UIFont(name: "Helvetica", size: 15)
//        textView.textColor          = UIColor.darkGrayColor()
//        textView.backgroundColor    = UIColor.whiteColor()
//        //textView.layer.borderColor  = UIColor.lightGrayColor().CGColor
//        //textView.layer.borderWidth  = 1.0
//        //textView.text               = "Enter message here"
//        
//        textView.delegate           = self
        
        alert.setValue(attributedString, forKey: "attributedMessage")
        
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            
            //alert.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.New, context: nil)

           
            
            
            
        })
//        
//        alert.view.addSubview(self.textView)
//        
//        var frame = self.textView.frame
//        frame.size.height = self.textView.contentSize.height
//        self.textView.frame = frame
//        self.textView.resignFirstResponder()
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title: "Post", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            print("Text field: \(textField.text!)")
            if textField.text != "" {
                self.createPostRequest(category, content: textField.text!)
                //self.createPostRequest(category, content: self.textView.text!)
            }
            else{
                
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        
        self.presentViewController(alert, animated: true, completion: nil)

        
    }
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if keyPath == "bounds"{
//            if let rect = (change?[NSKeyValueChangeNewKey] as? NSValue)?.CGRectValue(){
//                let margin:CGFloat = 8.0
//                textView.frame = CGRectMake(rect.origin.x + margin, rect.origin.y + 50, CGRectGetWidth(rect) - 2*margin, CGRectGetHeight(rect) / 2 - 35)
//                textView.bounds = CGRectMake(rect.origin.x + margin, rect.origin.y + 50, CGRectGetWidth(rect) - 2*margin, CGRectGetHeight(rect) / 2 - 35)
//            }
//        }
//    }
    
    func createPostRequest(category: Int, content: String) {
        //var currentUser: String = NSUserDefaults.standardUserDefaults().stringForKey("authorization")
        
        if let authorization = NSUserDefaults.standardUserDefaults().stringForKey("authorization"){
            print("authorization \(authorization)")
            
            let urlString = "http://52.87.233.57:80/post/create"
            let url: NSURL = NSURL(string: urlString)!
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let session = NSURLSession.sharedSession()
            
            let param = ["category":category, "content":content] as Dictionary<String, NSObject>
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
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text
        let updatedText = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGrayColor()
            
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
            return false
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
    }
    */
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
