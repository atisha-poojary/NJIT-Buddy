//
//  MoreViewController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 08/07/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var instructionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let textAttachment = NSTextAttachment()
//        
//        let attributedString = NSMutableAttributedString(string: "")
//        
//        textAttachment.image = UIImage(named: "ic_flag_selected.png")!
//        textAttachment.image = UIImage(CGImage: textAttachment.image!.CGImage!, scale: 2, orientation: .Up)
//        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//        
//        attributedString.appendAttributedString(attrStringWithImage);
//        
//        let attributedString1 = NSMutableAttributedString(string: "Hug: To give feedback to a post. Comment: To provide comments on post in the Ask category. Flag: To report any inappropriate post. Bell: To give more attention to a post.")
//
//        
//        attributedString.appendAttributedString(attributedString1)
//        
//        self.instructionLabel.attributedText = attributedString;
     
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "accountSegue" || segue.identifier == "profileSegue" {
            let vc = segue.destinationViewController
            vc.hidesBottomBarWhenPushed = true
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
