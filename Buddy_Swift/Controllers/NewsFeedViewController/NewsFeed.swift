//
//  NewsFeed.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 11/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import Foundation
import UIKit

struct NewsFeed {
    var name: String?
    var message: String?
    var timeStamp: String?
    var flag: UIButton?
    var bell: UIButton?
    var hug: UIButton?
    var comments: UIButton?
    
    init(name: String?, message: String?, timeStamp: String?,flag: UIButton?, bell: UIButton?, hug: UIButton?,comments: UIButton? ) {
        self.name = name
        self.message = message
        self.timeStamp = timeStamp
        self.flag = flag
        self.bell = bell
        self.hug = hug
        self.comments = comments
    }
}