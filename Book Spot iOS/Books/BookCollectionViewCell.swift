//
//  BookCollectionViewCell.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 16/12/24.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var reservationAction: UIButton!
    
    var reserveAction: (() -> Void)?
    
    @IBAction func reserveAction(_ sender: Any) {
        reserveAction?()
    }
    
}
