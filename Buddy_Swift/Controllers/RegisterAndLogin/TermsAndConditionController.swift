//
//  TermsAndConditionController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 24/05/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import Foundation
import UIKit

class TermsAndConditionController: UIViewController {
    
    @IBAction func rejectButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}