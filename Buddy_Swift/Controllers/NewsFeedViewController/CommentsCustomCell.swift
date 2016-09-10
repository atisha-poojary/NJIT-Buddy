//
//  CommentsCustomCell.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 18/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class CommentsCustomCell: UITableViewCell {

    @IBOutlet weak var nameAndTimeStampLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
