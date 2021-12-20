//
//  Product+Various.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 23/11/21.
//

import UIKit

extension Product {
    var imageData: UIImage? {
        if let data = image {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
}
