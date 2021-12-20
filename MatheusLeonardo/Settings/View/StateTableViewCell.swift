//
//  StateTableViewCell.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 07/12/21.
//

import UIKit

class StateTableViewCell: UITableViewCell {

    @IBOutlet weak var stateName: UILabel!
    @IBOutlet weak var stateTaxValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with state: State){
        stateName.text = state.name ?? ""
        stateTaxValue.text = String(state.tax)
    }

}
