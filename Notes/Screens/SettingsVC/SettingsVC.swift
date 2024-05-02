
import UIKit

protocol CategoryColorUpdateDelegate: AnyObject {
    func updateCategoryColor(_ color: UIColor, forCategory category: String)
}

class SettingsVC: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var redColorSlider: UISlider!
    @IBOutlet weak var greenColorSlider: UISlider!
    @IBOutlet weak var blueColorSlider: UISlider!
    
    //MARK: - Properties
    
    weak var colorUpdateDelegate: CategoryColorUpdateDelegate?
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSliders()
        setupPicker()
        categoryPicker.reloadAllComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupPicker()
        categoryPicker.reloadAllComponents()
    }
    
    //MARK: - Setup
    
    private func setupUI() {
        colorView.layer.cornerRadius = min(colorView.frame.size.width, colorView.frame.size.height) / 2.0
        view.backgroundColor = .myDark
        loadSavedColors()
        updateColorAndView()
    }
    
    private func setupSliders() {
        redColorSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        greenColorSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        blueColorSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func setupPicker() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
    }
    
    //MARK: - Actions
    
    @objc private func sliderValueChanged() {
        let selectedCategory = CartegoryPerson.categories[categoryPicker.selectedRow(inComponent: 0)]
        let redValue = CGFloat(redColorSlider.value)
        let greenValue = CGFloat(greenColorSlider.value)
        let blueValue = CGFloat(blueColorSlider.value)
        
        let color = UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        CategoryData.categoryColors[selectedCategory] = color
        colorView.backgroundColor = color
        categoryPicker.reloadAllComponents()
        
        colorUpdateDelegate?.updateCategoryColor(color, forCategory: selectedCategory)
        
        UserDefaults.standard.set(color.encode(), forKey: "\(selectedCategory)_color")
    }
    
    //MARK: - Helpers
    
    private func updateColorAndView() {
        let selectedCategory = CartegoryPerson.categories[categoryPicker.selectedRow(inComponent: 0)]
        
        if let colorData = UserDefaults.standard.data(forKey: "\(selectedCategory)_color"),
           let savedColor = UIColor.decode(data: colorData) {
            CategoryData.categoryColors[selectedCategory] = savedColor
        }
        
        if let savedColorComponents = UserDefaults.standard.array(forKey: "\(selectedCategory)_color") as? [CGFloat],
           savedColorComponents.count == 4 {
            let savedColor = UIColor(red: savedColorComponents[0], green: savedColorComponents[1], blue: savedColorComponents[2], alpha: savedColorComponents[3])
            CategoryData.categoryColors[selectedCategory] = savedColor
        }
        
        let color = CategoryData.categoryColors[selectedCategory] ?? .white
        
        colorView.backgroundColor = color
        
        if let rgbComponents = color.rgbComponents {
            redColorSlider.value = Float(rgbComponents.red)
            greenColorSlider.value = Float(rgbComponents.green)
            blueColorSlider.value = Float(rgbComponents.blue)
        } else {
            colorView.backgroundColor = color
        }
    }
    
    private func loadSavedColors() {
        for category in CartegoryPerson.categories {
            if let colorData = UserDefaults.standard.data(forKey: "\(category)_color"),
               let savedColor = UIColor.decode(data: colorData) {
                CategoryData.categoryColors[category] = savedColor
            }
        }
    }
}

//MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension SettingsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CartegoryPerson.categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let selectedCategory = CartegoryPerson.categories[row]
        let color = CategoryData.categoryColors[selectedCategory] ?? .white
        return NSAttributedString(string: selectedCategory, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateColorAndView()
    }
}
