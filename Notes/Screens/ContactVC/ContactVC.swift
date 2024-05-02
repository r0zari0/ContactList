
import UIKit
import MobileCoreServices
import SwiftUI

protocol ContactUpdateDelegate: AnyObject {
    func updateContact(_ contact: Model)
}

class ContactVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var personPhone: UILabel!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var privateButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    
    @IBOutlet weak var personeImage: UIImageView!
    
    @IBOutlet weak var categoriesPicker: UIPickerView!
    
    // MARK: - Properties
    
    weak var delegate: ContactUpdateDelegate?
    
    var content: Model
    
    // MARK: - Init
    
    init(content: Model) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateAppearance()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        personeImage.isUserInteractionEnabled = true
        personeImage.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(imageLongPressed))
        personeImage.addGestureRecognizer(longPressGesture)
        
        
    }
    
    //MARK: - SetupUI
    
    func setupUI() {
        savedContent()
        
        
        
        categoriesPicker.isHidden = true
        categoryButton.backgroundColor = .myPerple
        
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = .myDark
        personeImage.backgroundColor = .myPerple
        
        personeImage.layer.cornerRadius = personeImage.frame.size.height / 2
        personeImage.clipsToBounds = true
        
        personLabel.text = "Name: \(content.name)"
        personPhone.text = "Phone: \(content.phone)"
        categoryLabel.text = "Category: \(content.category)"
        
        categoriesPicker.delegate = self
        categoriesPicker.dataSource = self
        
        categoryButton.tintColor = .myPerple
        categoryButton.layer.cornerRadius = categoryButton.frame.size.height / 2
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addressLabelTapped))
            addressLabel.isUserInteractionEnabled = true
            addressLabel.addGestureRecognizer(tapGesture)
    }
    
    func updateAddress(_ newAddress: String) {
        content.address = newAddress
        addressLabel.text = "Address: \(newAddress)"
        UserDefaults.standard.set(newAddress, forKey: "\(content.name)_address")
    }
    
    func savedContent() {
        if let imageData = UserDefaults.standard.data(forKey: "\(content.name)_imageData"), let image = UIImage(data: imageData) {
            personeImage.image = image
        }
        
        if let savedAddress = UserDefaults.standard.string(forKey: "\(content.name)_address") {
            updateAddress(savedAddress)
        }
        
        if let savedCategory = UserDefaults.standard.string(forKey: "\(content.name)_category") {
            content.category = savedCategory
            categoryLabel.text = "Category: \(savedCategory)"
        }
    }
    
    func animateAppearance() {
        view.center = CGPoint(x: view.frame.midX, y: -view.frame.height)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.center = CGPoint(x: self.view.frame.midX, y: self.view.frame.midY)
        }, completion: nil)
    }
    
    //MARK: - Alerts
    
    func changeAlert() {
        let alertController = UIAlertController(title: "Change Contact", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textFielf in
            textFielf.text = self.content.name
            textFielf.autocapitalizationType = .words
        }
        
        alertController.addTextField { textField in
            textField.text = self.content.phone
            textField.keyboardType = .phonePad
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let nameTextField = alertController.textFields?.first,
               let phoneTextField = alertController.textFields?.last,
               let newName = nameTextField.text,
               let newPhone = phoneTextField.text,
               !newName.isEmpty && !newPhone.isEmpty {
                
                if let phoneNumber = Int(newPhone), newPhone.count == 10 {
                    let formattedName = newName.prefix(1).uppercased() + newName.dropFirst()
                    
                    self.content.name = formattedName
                    self.content.phone = newPhone
                    
                    self.setupUI()
                    
                    if let delegate = self.delegate {
                        delegate.updateContact(self.content)
                    }
                } else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid phone number", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            } else {
                let emptyFieldsAlert = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
                emptyFieldsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(emptyFieldsAlert, animated: true, completion: nil)
            }
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addressAlert() {
        let alertController = UIAlertController(title: "Add Location", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter location"
            textField.autocapitalizationType = .words
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first, let address = textField.text, !address.isEmpty else {
                return
            }
            self?.updateAddress(address) // Сохраняем адрес в модели контакта
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func imageLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            showFullScreenImage()
        }
    }
    
    //MARK: - Actions
    
    @IBAction func backButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func categoryButtonAction(_ sender: Any) {
        if categoriesPicker.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.categoriesPicker.alpha = 1.0
                self.categoryButton.alpha = 0.0
                self.privateButton.alpha = 0.0
                self.addressButton.alpha = 0.0
            }) { _ in
                self.categoriesPicker.isHidden = false
                self.categoryButton.isHidden = true
                self.privateButton.isHidden = true
                self.addressButton.isHidden = true
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.categoriesPicker.alpha = 0.0
                self.categoryButton.alpha = 1.0
                self.privateButton.alpha = 1.0
                self.addressButton.alpha = 1.0
            }) { _ in
                self.categoriesPicker.isHidden = true
                self.categoryButton.isHidden = false
                self.addressButton.isHidden = false
                self.privateButton.isHidden = false
            }
        }
    }
    
    @IBAction func privateButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Set Password", message: "Enter a password for this contact", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let password = alertController.textFields?.first?.text, !password.isEmpty {
                self.content.password = password
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please enter a password", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changButtonAction(_ sender: Any) {
        changeAlert()
    }
    
    @IBAction func addLocationAction(_ sender: Any) {
        addressAlert()
    }
    
    @objc func addressLabelTapped() {
           let address = addressLabel.text ?? ""
           
           if let url = URL(string: "http://maps.apple.com/?address=\(address)") {
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
           } else {
               let alertController = UIAlertController(title: "Error", message: "Maps app is not available", preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alertController, animated: true, completion: nil)
           }
       }
    
    func showFullScreenImage() {
        let imageViewController = UIViewController()
        let imageView = UIImageView(image: personeImage.image)
        imageView.contentMode = .scaleAspectFit
        imageViewController.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: imageViewController.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageViewController.view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: imageViewController.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageViewController.view.bottomAnchor)
        ])
        
        present(imageViewController, animated: true, completion: nil)
    }
}

//MARK: - Picker

extension ContactVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            personeImage.image = pickedImage
            if let imageData = pickedImage.jpegData(compressionQuality: 1.0) {
                UserDefaults.standard.set(imageData, forKey: "\(content.name)_imageData")
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ContactVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CartegoryPerson.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CartegoryPerson.categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCategory = CartegoryPerson.categories[row]
        content.category = selectedCategory
        UserDefaults.standard.set(selectedCategory, forKey: "\(content.name)_category")
        
        categoryLabel.text = "Category: \(content.category)"
        
        delegate?.updateContact(content)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.categoryButton.alpha = 1.0
            self.categoriesPicker.alpha = 0.0
            self.addressButton.alpha = 1.0
            self.privateButton.alpha = 1.0
        }, completion: { _ in
            self.categoryButton.isHidden = false
            self.categoriesPicker.isHidden = true
            self.addressButton.isHidden = false
            self.privateButton.isHidden = false
        })
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = CartegoryPerson.categories[row]
        let color = CategoryData.categoryColors[title] ?? .white
        
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}

extension ContactVC: CategoryColorUpdateDelegate {
    func updateCategoryColor(_ color: UIColor, forCategory category: String) {
        CategoryData.categoryColors[category] = color
        UserDefaults.standard.set(color.cgColor.components, forKey: "\(category)_color")
        categoryLabel.textColor = color
    }
}

//#Preview {
//    let content: Model = Model(name: "mac", phone: "12341232")
//    return ContactVC(content: content)
//}
