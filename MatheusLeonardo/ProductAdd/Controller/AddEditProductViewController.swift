//
//  AddEditProductViewController.swift
//  MatheusLeonardo
//
//  Created by MATHEUS TADEU RABELO QUERINO on 21/11/21.
//

import UIKit
import CoreData

class AddEditProductViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var textFieldProductName: UITextField!
    @IBOutlet weak var imageViewProduct: UIImageView!
    @IBOutlet weak var textFieldStateProduct: UITextField!
    @IBOutlet weak var buttonAddStateProduct: UIButton!
    @IBOutlet weak var textFieldPrice: UITextField!
    @IBOutlet weak var creditCardProduct: UISwitch!
    @IBOutlet weak var buttonRegisterEditProduct: UIButton!
    
    var pickerView: UIPickerView!
    var states: [State]!
    var stateSelected: State!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewClick(tapGestureRecognizer:)))
            imageViewProduct.isUserInteractionEnabled = true
            imageViewProduct.addGestureRecognizer(tapGestureRecognizer)
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        textFieldProductName.delegate = self
        textFieldPrice.delegate = self
        
        initToolbarPicker()
        addProductInformationEdit()

        // Do any additional setup after loading the view.
    }
    
    func initToolbarPicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let btnCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPicker))
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [btnCancel, btnSpace, btnDone]
        textFieldStateProduct.inputView = pickerView
        textFieldStateProduct.inputAccessoryView = toolBar
    }
    
    func addProductInformationEdit() {
        if let product = product {
            title = "Editar produto"
            textFieldProductName.text = product.name
            imageViewProduct.image = product.imageData
            textFieldStateProduct.text = product.state?.name
            textFieldPrice.text = String(describing: product.price)

            let credit = product.credit_card ? true : false
            creditCardProduct.setOn(credit, animated:true)

            buttonRegisterEditProduct.setTitle("ALTERAR", for: .normal)

        } else {
            title = "Cadastrar produto"
        }
    }
    
    @IBAction func addEditProductClickButton(_ sender: UIButton) {
        if product == nil {
            product = Product(context: context)
        }
        
        let productName = textFieldProductName.text
        let productPrice = textFieldPrice.text
        let productState = textFieldStateProduct.text
        
        if (checkTextEmpty(text: productName)) {
            showAlertValidateMessage(messageAlert: "O Campo do nome do produto deve ser preenchido")
            return
        } else {
            product.name = productName
        }
        
        if let image = imageViewProduct.image {
            product.image = image.jpegData(compressionQuality: 0.8)
        } else {
            showAlertValidateMessage(messageAlert: "O Campo de imagem do produto deve ser preenchido")
            return
        }
        
        if (checkTextEmpty(text: productState)) {
            showAlertValidateMessage(messageAlert: "O Campo do estado deve ser preenchido")
            return
        } else {
            let state = states[pickerView.selectedRow(inComponent: 0)]
            product.state = state
        }

        if let price = productPrice {
            if (checkTextEmpty(text: productPrice)) {
                showAlertValidateMessage(messageAlert: "O Campo do valor do produto deve ser preenchido")
                return
            } else {
                if let price = Double(price) {
                    product.price = price
                }
            }
        }
        
        product.credit_card = creditCardProduct.isOn
        
        do {
            try self.context.save()
            
            navigationController?.popViewController(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkTextEmpty(text: String?) -> Bool {
        if text == "" {
            return true
        } else {
            return false
        }
    }
    
    @objc func imageViewClick(tapGestureRecognizer: UITapGestureRecognizer) {
           let alert = UIAlertController(title: "Selecionar foto", message: "De onde você quer escolher a foto?", preferredStyle: .actionSheet)
           
           if UIImagePickerController.isSourceTypeAvailable(.camera) {
               let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                       self.selectImage(sourceType: .camera)
               })

               alert.addAction(cameraAction)
           }
           
           let libraryAction = UIAlertAction(title: "Biblioteca", style: .default, handler: { (action) in
               self.selectImage(sourceType: .photoLibrary)
           })

           alert.addAction(libraryAction)
           
           let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
           alert.addAction(cancelAction)
           
           present(alert, animated: true, completion: nil)
           
       }
    
    func selectImage(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            states = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        
        if states.count > 0 {
            textFieldStateProduct.isUserInteractionEnabled = true
        } else {
            textFieldStateProduct.text = nil
            textFieldStateProduct.isUserInteractionEnabled = false
        }
    }
       
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
       
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
       
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return states[row].name
    }
    
    func showAlertValidateMessage(messageAlert: String) {
        let alert = UIAlertController(title: "Atenção", message: messageAlert, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func cancelPicker() {
        textFieldStateProduct.resignFirstResponder()
    }
    
    @objc func donePicker() {
        textFieldStateProduct.text = states[pickerView.selectedRow(inComponent: 0)].name!
        stateSelected = states[pickerView.selectedRow(inComponent: 0)]
        textFieldStateProduct.resignFirstResponder()
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
    func isDecimal() -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.locale = Locale.current
        return formatter.number(from: self) != nil
    }
}

extension AddEditProductViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == textFieldProductName {
            let allowedCharacter = CharacterSet.letters
            let allowedCharacter1 = CharacterSet.whitespaces
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacter.isSuperset(of: characterSet) || allowedCharacter1.isSuperset(of: characterSet)
            
        }
        
        if textField == textFieldPrice {
            guard !string.isEmpty else {
                  return true
              }

              let currentText = textField.text ?? ""
              let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)

              return replacementText.isDecimal()
        }

        return true
    }
}

extension AddEditProductViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageViewProduct.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}
