//
//  FeedsCustomCell.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 14/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import Foundation
import UIKit

//protocol feedsTableViewCellDelegate {
//    func commentsClickedOnCell(sender: FeedsCustomCell)
//}

class FeedsCustomCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var bellButton: UIButton!
    @IBOutlet weak var hugButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var hugsCountLabel: UILabel!
    @IBOutlet weak var huggersButton: UIButton!
}

