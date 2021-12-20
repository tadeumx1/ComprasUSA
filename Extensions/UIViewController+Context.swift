//
//  UIViewController+Context.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 23/11/21.
//

import Foundation

import UIKit
import CoreData

extension UIViewController {
    var context: NSManagedObjectContext {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        return appdelegate.persistentContainer.viewContext
    }
}
