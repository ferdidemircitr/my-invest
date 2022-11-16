//
//  PortfolioTVC.swift
//  MyInvest
//
//  Created by Ferdi DEMİRCİ on 18.09.2022.
//

import UIKit

class PortfolioTVC: UITableViewCell {

    @IBOutlet weak var investNameLabel: UILabel!
    @IBOutlet weak var buyingLabel: UILabel!
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
