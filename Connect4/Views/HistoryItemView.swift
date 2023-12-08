//
//  HistoryTableViewCell.swift
//  Connect4
//
//  Created by Yuhong He on 06/12/2023.
//

import UIKit

class HistoryItemView: UITableViewCell {

    @IBOutlet weak var gameBoardView: UIView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
    let maskShapeLayer = CAShapeLayer()
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
