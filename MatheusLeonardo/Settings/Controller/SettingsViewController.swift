//
//  SettingsViewController.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 21/11/21.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldDolarValue: UITextField!
    
    @IBOutlet weak var textFieldTaxValue: UITextField!
    
    @IBOutlet weak var statesTableView: UITableView!
    
    var states: [State]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        
        registerDefaultsFromSettingsBundle()
        
        statesTableView.delegate = self
        statesTableView.dataSource = self
    }
    
    let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Lista de estados vazia."
        label.textAlignment = .center
        label.font = UIFont.italicSystemFont(ofSize: 16.0)
        return label
    }()
    
    private func setupData() {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            states = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    let userDefaults = UserDefaults.standard
    
    private func configureTextField() {
        textFieldDolarValue.text = String(userDefaults.double(forKey: "dolarValue"))
        textFieldTaxValue.text = String(userDefaults.double(forKey: "iof"))
    }
    
    private func registerDefaultsFromSettingsBundle() {

        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") else {
           print("Could not locate Settings.bundle")
           return
            
        }
        
        guard let settings = NSDictionary(contentsOfFile: settingsBundle + "/Root.plist") else {
           print("Could not read Root.plist")
           return

        }
        
        let preferences = settings["PreferenceSpecifiers"] as! NSArray
        var defaultsToRegister = [String: AnyObject]()
        for prefSpecification in preferences {
            if let post = prefSpecification as? [String: AnyObject] {
                guard let key = post["Key"] as? String,
                      let defaultValue = post["DefaultValue"] else {
                    continue
                    
                }
                defaultsToRegister[key] = defaultValue
                
            }
            
        }

        UserDefaults.standard.register(defaults: defaultsToRegister)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTextField()

        setupData()
        statesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(settingChanged), name: UserDefaults.didChangeNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func settingChanged() {
        let dolar = userDefaults.double(forKey: "dolarValue")
        let iof = userDefaults.double(forKey: "iof")
        
        textFieldDolarValue.text = String(dolar)
        textFieldTaxValue.text = String(iof)
    }
    
    @IBAction func addState(_ sender: Any) {
        addStateAlert()
    }
    
    @IBAction func editingDidEndDolarTextField(_ sender: UITextField) {
        guard let dolarValueText = sender.text else {
            return
        }
        
        let doubleValue = dolarValueText.toDouble()
        
        userDefaults.set(doubleValue, forKey: "dolarValue")
        
        userDefaults.synchronize()

    }
    
    @IBAction func editingDidEndTaxValueTextField(_ sender: UITextField) {
        guard let taxValueText = sender.text else {
            return
        }
        
        let doubleValue = taxValueText.toDouble()
        
        userDefaults.set(doubleValue, forKey: "iof")
        
        userDefaults.synchronize()
    }
    
    
    private func addStateAlert() {

        let alert = UIAlertController(title: "Adicionar estado", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.keyboardType = .decimalPad
        }
        
        let submitAction = UIAlertAction(title: "Adicionar", style: .default, handler: { (action) -> Void in
            let stateName = alert.textFields?.first?.text
            let taxValue = alert.textFields?.last?.text
            
            let state = State(context: self.context)
            
            if (self.checkTextEmpty(text: stateName)) {
                self.showAlertValidateMessage(messageAlert: "O Campo do nome do estado deve ser preenchido")
                return
            } else {
                state.name = stateName
            }
           
            if (self.checkTextEmpty(text: taxValue)) {
                self.showAlertValidateMessage(messageAlert: "O Campo do imposto deve ser preenchido")
                return
            } else {
                state.tax = taxValue?.toDouble() ?? 0.0
            }
            
            guard let stateNameTextField = stateName else {
                return
            }
            
            guard let taxValueTextField = taxValue else {
                return
            }
            
            let numbersRange = stateNameTextField.rangeOfCharacter(from: .decimalDigits)
            let hasNumbers = (numbersRange != nil)
            
            if (hasNumbers) {
                self.showAlertValidateMessage(messageAlert: "O Campo do nome do estado apenas aceita letras")
                return
            }
            
            let numbersRangeTaxValue = taxValueTextField.rangeOfCharacter(from: .decimalDigits)
            let hasNumbersValue = (numbersRangeTaxValue != nil)
            
            if(!hasNumbersValue) {
                self.showAlertValidateMessage(messageAlert: "O Campo do imposto apenas aceita números")
                return
            }
            
            if(!hasNumbers && hasNumbersValue) {
                do {
                  try self.context.save()
                  self.setupData()
                  self.statesTableView.reloadData()
                } catch {
                  print(error.localizedDescription)
                }
            }
          
        })
        
        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func editStateAlert(state: State?) {

        let alert = UIAlertController(title: "Editar estado", message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        guard let state = state else {
            return
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            textField.text = state.name
            
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            textField.text = String(state.tax)
            textField.keyboardType = .decimalPad
        }
        
        let submitAction = UIAlertAction(title: "Adicionar", style: .default, handler: { (action) -> Void in
            let stateName = alert.textFields?.first?.text
            let taxValue = alert.textFields?.last?.text
                        
            if (self.checkTextEmpty(text: stateName)) {
                self.showAlertValidateMessage(messageAlert: "O Campo do nome do estado deve ser preenchido")
                return
            } else {
                state.name = stateName
            }
           
            if (self.checkTextEmpty(text: taxValue)) {
                self.showAlertValidateMessage(messageAlert: "O Campo do imposto deve ser preenchido")
                return
            } else {
                state.tax = taxValue?.toDouble() ?? 0.0
            }
            
            guard let stateNameTextField = stateName else {
                return
            }
            
            guard let taxValueTextField = taxValue else {
                return
            }
            
            let numbersRange = stateNameTextField.rangeOfCharacter(from: .decimalDigits)
            let hasNumbers = (numbersRange != nil)
            
            if (hasNumbers) {
                self.showAlertValidateMessage(messageAlert: "O Campo do nome do estado apenas aceita letras")
                return
            }
            
            let numbersRangeTaxValue = taxValueTextField.rangeOfCharacter(from: .decimalDigits)
            let hasNumbersValue = (numbersRangeTaxValue != nil)
            
            if(!hasNumbersValue) {
                self.showAlertValidateMessage(messageAlert: "O Campo do imposto apenas aceita números")
                return
            }
            
            do {
                try self.context.save()
                self.setupData()
                self.statesTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        })

        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func checkTextEmpty(text: String?) -> Bool {
        if text == "" {
            return true
        } else {
            return false
        }
    }
    
    func showAlertValidateMessage(messageAlert: String) {
        let alert = UIAlertController(title: "Atenção", message: messageAlert, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = states.count 
        tableView.backgroundView = rows == 0 ? label : nil
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_states", for: indexPath)
        guard let state = states?[indexPath.row] else { return cell }

        cell.textLabel?.text = state.name
        cell.detailTextLabel?.text = "\(state.tax)%"
        return cell
    
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let state = states[indexPath.row]
            self.context.delete(state)

            do {
                try self.context.save()
                self.setupData()
                self.statesTableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }

        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let state = states?[indexPath.row]
        editStateAlert(state: state)
        tableView.deselectRow(at: indexPath, animated: true)
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

extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
