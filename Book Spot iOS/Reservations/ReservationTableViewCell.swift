//
//  ReservationTableViewCell.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//

import UIKit

class ReservationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageBookView: UIImageView!
    @IBOutlet weak var titleBookLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
