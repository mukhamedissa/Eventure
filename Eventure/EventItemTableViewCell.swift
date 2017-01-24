//
//  EventItemTableViewCell.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/17/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import Cosmos

class EventItemTableViewCell: UITableViewCell {

    @IBOutlet weak var eventThumbnail: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventRating: CosmosView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
