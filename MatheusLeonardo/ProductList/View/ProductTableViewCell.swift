//
//  ProductTableViewCell.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 21/11/21.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var productPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with product: Product){
        productName.text = product.name ?? ""
        productPrice.text = "US$ \( String(describing: product.price) )"
        productImage.image = product.imageData
        
    }

}
