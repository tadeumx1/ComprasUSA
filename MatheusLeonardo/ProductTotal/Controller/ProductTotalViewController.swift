//
//  ProductTotalViewController.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 21/11/21.
//

import UIKit
import CoreData

class ProductTotalViewController: UIViewController {
    @IBOutlet weak var labelTotalPriceDolar: UILabel!
    @IBOutlet weak var labelTotalPriceDolarResult: UILabel!
    @IBOutlet weak var labelTotalPriceReal: UILabel!
    @IBOutlet weak var labelTotalPriceRealResult: UILabel!
    
    var dolarValue: Double = 0.0
    var realValue: Double = 0.0
    
    var dolarCotationValue: Double = 0.0
    var taxValue: Double = 0.0
    
    let userDefaults = UserDefaults.standard
    
    var products: [Product] = []
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dolar = userDefaults.double(forKey: "dolarValue")
        let iof = userDefaults.double(forKey: "iof")
        
        dolarCotationValue = dolar
        taxValue = iof
        
        formatLabel()
        getProducts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged), name: UserDefaults.didChangeNotification, object: nil)

    }
    
    @objc private func settingChanged() {
        let dolar = userDefaults.double(forKey: "dolarValue")
        let iof = userDefaults.double(forKey: "iof")
        
        dolarCotationValue = dolar
        taxValue = iof
    }
    
    private func formatLabel() {
        dolarValue = 0.0
        realValue = 0.0

        labelTotalPriceDolarResult.text = String(format: "%.2f", dolarValue)
        labelTotalPriceRealResult.text = String(format: "%.2f", realValue)
    }
    
    private func getProducts() {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            products = try context.fetch(fetchRequest)
            calculate()

        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func calculate() {
        for product in products {
            
            guard let productState = product.state else {
                showAlertValidateMessage(messageAlert: "Todos os produtos devem possuir o estado de compra")
                return
            }
            
            var value = product.price + (product.price * ((productState.tax) / 100))
            
            if product.credit_card {
                value = value + value * (taxValue / 100)
            }
              
            dolarValue += value
          }
        
        realValue = dolarValue * dolarCotationValue
                
        labelTotalPriceDolarResult.text = String(format: "%.2f", dolarValue)
        labelTotalPriceRealResult.text =  String(format: "%.2f", realValue)
        
    }
    
    func showAlertValidateMessage(messageAlert: String) {
        let alert = UIAlertController(title: "Atenção", message: messageAlert, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
