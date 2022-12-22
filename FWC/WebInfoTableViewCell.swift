//
//  WebInfoTableViewCell.swift
//  FWC
//
//  Created by user on 2022/12/21.
//

import UIKit

class WebInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var webName: UILabel!
    @IBOutlet weak var webType: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
