//
//  SettingsViewController.swift
//  yolov3
//
//  Created by Alexander on 19/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet weak var iouSlider: UISlider!
  @IBOutlet weak var confSlider: UISlider!
  @IBOutlet weak var modelPicker: UIPickerView!
  @IBOutlet weak var iouLabel: UILabel!
  @IBOutlet weak var confLabel: UILabel!
  @IBOutlet weak var isSmoothed: UISwitch!
  @IBOutlet weak var liveSwitch: UISwitch!
  
  var alert: UIAlertController?
  
  var pickerData: [String] = []
  
  weak var settings: Settings!

  override func viewDidLoad() {
    super.viewDidLoad()
    settings = Settings.shared
    settings.delegate = self
    iouSlider.minimumValue = 0.001
    iouSlider.maximumValue = 1
    confSlider.minimumValue = 0.001
    confSlider.maximumValue = 1
    iouSlider.value = settings.iouThreshold
    iouLabel.text = String(format: "%.2f", iouSlider.value)
    confSlider.value = settings.confidenceThreshold
    confLabel.text = String(format: "%.2f", confSlider.value)
    
    pickerData = YOLOType.modelNames()
    
    modelPicker.selectRow(pickerData.firstIndex(of: settings.modelType.description())!,
                          inComponent: 0, animated: true)
    liveSwitch.isOn = UserDefaults.standard.bool(forKey: "liveModeEnabled")
  }
  
  @IBAction func save() {
    settings.isSmoothed = isSmoothed.isOn
    let isReloading = settings.save(modelType: YOLOType.initFrom(name:
      pickerData[modelPicker.selectedRow(inComponent: 0)]))
    if isReloading {
      alert = UIAlertController(title: "Please wait", message: "Model is reloading",
                                    preferredStyle: .alert)
      self.present(alert!, animated: true, completion: nil)
    }
  }
  
  @IBAction func restoreDefault() {
    settings.restore()
    iouSlider.value = settings.iouThreshold
    iouLabel.text = String(format: "%.2f", iouSlider.value)
    confSlider.value = settings.confidenceThreshold
    confLabel.text = String(format: "%.2f", confSlider.value)
    isSmoothed.isOn = settings.isSmoothed
    modelPicker.selectRow(pickerData.firstIndex(of: settings.modelType.description())!,
                          inComponent: 0, animated: true)
  }
  
  @IBAction func iouChanged() {
    iouLabel.text = String(format: "%.2f", iouSlider.value)
    settings.iouThreshold = iouSlider.value
  }
  
  @IBAction func confChanged() {
    confLabel.text = String(format: "%.2f", confSlider.value)
    settings.confidenceThreshold = confSlider.value
  }
  
  @IBAction func liveOption(_ sender: UISwitch) {
    guard var viewControllers = tabBarController?.viewControllers else { return }
    if sender.isOn {
      UserDefaults.standard.set(true, forKey: "liveModeEnabled")
      let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnlineViewController")
      viewControllers.insert(vc, at: 0)
    } else {
      UserDefaults.standard.set(false, forKey: "liveModeEnabled")
      viewControllers.remove(at: 0)
    }
    tabBarController?.setViewControllers(viewControllers, animated: false)
  }
  
}

extension SettingsViewController: SettingsDelegate {
  
  func reloadingFinished() {
    guard let alert = self.alert else {
      return
    }
    alert.dismiss(animated: true, completion: nil)
  }
  
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int,
                  forComponent component: Int) -> String? {
    return pickerData[row]
  }
  
}
