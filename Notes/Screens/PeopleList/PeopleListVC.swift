
import UIKit

class NoHighlightButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = .clear
            } else {
                backgroundColor = .myPerple
            }
        }
    }
}

class PeopleListVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var newButton: NoHighlightButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var sortControl: UISegmentedControl!
    
    // MARK: - Properties
    
    var people: [Model] = []
    var allPeople: [Model] = []
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    func setupUI() {
        setupNotificationCenter()
        setupNavigationBar()
        setupTableView()
        setupTextField()
        setupSortControl()
        loadPeople()
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategoryColors), name: NSNotification.Name("CategoryColorUpdated"), object: nil)
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupTableView() {
        tableView.backgroundColor = .myDark
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "Cell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    func setupTextField() {
        textField.delegate = self
        textField.textColor = .white
        textField.backgroundColor = .myPerple
        textField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        let searchImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        searchImageView.tintColor = .lightGray
        
        textField.leftView = searchImageView
        textField.leftViewMode = .always
    }
    
    func setupSortControl() {
        sortControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        sortControl.backgroundColor = .myPerple
        sortControl.selectedSegmentTintColor = .myDarkPerple
    }
    
    // MARK: - Actions
    
    @IBAction func newButtonAction(_ sender: Any) {
        alert()
    }
    
    @IBAction func sortAction(_ sender: Any) {
        guard let sortControl = sender as? UISegmentedControl else {
            return
        }
        switch sortControl.selectedSegmentIndex {
        case 0:
            people.sort { $0.name.first ?? " " < $1.name.first ?? " " }
        case 1:
            people.sort { $0.phone < $1.phone }
        default:
            break
        }
        tableView.reloadData()
    }
    
    @objc func updateCategoryColors() {
        tableView.reloadData()
    }
    
}

// MARK: - Save

extension PeopleListVC {
    func savePeople() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(people) {
            UserDefaults.standard.set(encoded, forKey: "people")
        }
    }
    
    func loadPeople() {
        if let savedPeopleData = UserDefaults.standard.data(forKey: "people") {
            let decoder = JSONDecoder()
            if let decodedPeople = try? decoder.decode([Model].self, from: savedPeopleData) {
                allPeople = decodedPeople
                people = allPeople
                tableView.reloadData()
            }
        }
    }
}

// MARK: - Alert

extension PeopleListVC {
    func alert() {
        let alertController = UIAlertController(title: "Add New Contact", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType = .words
        }
        alertController.addTextField { textField in
            textField.placeholder = "Phone"
            textField.keyboardType = .phonePad
        }
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default) { [ weak self ] _ in
            guard let self = self else { return }
            if let nameTextField = alertController.textFields?.first,
               let phoneTextField = alertController.textFields?[1],
               let passwordTextField = alertController.textFields?.last,
               let name = nameTextField.text,
               let phone = phoneTextField.text,
               let password = passwordTextField.text,
               !name.isEmpty && !phone.isEmpty {
                
                if let phoneNomber = Int(phone), phone.count == 10 {
                    let formattedName = name.prefix(1).uppercased() + name.dropFirst()
                    let newPerson = Model(name: name, phone: phone, image: UIImage(), address: nil, category: "", password: password.isEmpty ? nil : password)
                    self.people.append(newPerson)
                    self.savePeople()
                    self.tableView.reloadData()
                } else {
                    let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid phone number", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func requestPassword(for person: Model, correctPassword: String) {
        let alertController = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let enteredPassword = alertController.textFields?.first?.text, enteredPassword == correctPassword {
                Navigator.share.showContact(view: self, person: person)
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Incorrect password", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - TableView

extension PeopleListVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = people[indexPath.row]
        if let password = person.password {
            requestPassword(for: person, correctPassword: password)
        } else {
            Navigator.share.showContact(view: self, person: person)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        let person = people[indexPath.row]
        cell.selectionStyle = .none
        //   cell.config(model: person)
        cell.config(model: person)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            people.remove(at: indexPath.row)
            savePeople()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - TextField

extension PeopleListVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.isEmpty {
            loadPeople()
        } else {
            people = allPeople.filter { $0.name.localizedCaseInsensitiveContains(newText) }
        }
        
        tableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension PeopleListVC: ContactUpdateDelegate {
    func updateContact(_ contact: Model) {
        if let index = people.firstIndex(where: { $0.name == contact.name }) {
            people[index] = contact
            savePeople()
            tableView.reloadData()
            
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? Cell {
                
            }
        }
    }
}

#Preview {
    return PeopleListVC()
}
