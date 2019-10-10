//
//  PhotoViewController.swift
//  yolov3
//
//  Created by Alexander on 09/07/2019.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var detectButton: UIButton!
  @IBOutlet weak var damageView: UIView!
  @IBOutlet weak var costButton: UIButton!
  @IBOutlet weak var cameraButtonStackView: UIStackView!
  @IBOutlet weak var folderButtonStackView: UIStackView!
  @IBOutlet weak var photoButtonsStackView: UIStackView!
  
  var processed = false
  var processStarted = false
  weak var modelProvider: ModelProvider!
  var predictionLayer: PredictionLayer!

  override func viewDidLoad() {
    super.viewDidLoad()
    modelProvider = ModelProvider.shared
    modelProvider.delegate = self
    predictionLayer = PredictionLayer()
    predictionLayer.addToParentLayer(imageView.layer)
    
    cameraButtonStackView.isUserInteractionEnabled = true
    cameraButtonStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takePhoto)))
    folderButtonStackView.isUserInteractionEnabled = true
    folderButtonStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(choosePhoto)))
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    predictionLayer.hide()
    predictionLayer.clear()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    modelProvider.delegate = self
    predictionLayer.clear()
    processed = false
    detectButton.setTitle("Détecter", for: .normal)
    damageView.isHidden = true
    costButton.isHidden = true
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if detectButton.layer.cornerRadius == 0 {
      detectButton.layer.cornerRadius = detectButton.frame.height / 2
      detectButton.layer.masksToBounds = true
    }
    if costButton.layer.cornerRadius == 0 {
      costButton.layer.cornerRadius = detectButton.frame.height / 2
      costButton.layer.masksToBounds = true
    }
  }
  
  @IBAction func choosePhoto() {
    let imagePicker = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      predictionLayer.hide()
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true)
    } else {
      showAlert(title: "Error!", msg: "Photo library is not available!")
    }
  }
  
  @IBAction func takePhoto() {
    let imagePicker = UIImagePickerController()
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      predictionLayer.hide()
      imagePicker.delegate = self
      imagePicker.sourceType = .camera
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true)
    } else {
      showAlert(title: "Error!", msg: "Camera is not available!")
    }
  }
  
  @IBAction func processImage() {
    if !processed {
      guard let image = imageView.image else {
        showAlert(title: "Warning!", msg: "Please choose image first or take a photo.")
        return
      }
      processStarted = true
      modelProvider.predict(frame: image)
    } else {
      processed = false
      detectButton.setTitle("Détecter", for: .normal)
      damageView.isHidden = true
      costButton.isHidden = true
      predictionLayer.hide()
      predictionLayer.clear()
    }
  }
  
  @IBAction func damageCost(_ sender: Any) {
    damageView.isHidden = false
  }
  
  func showAlert(title: String, msg: String) {
    let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

}

// MARK: - ModelProvaiderDelegate

extension PhotoViewController: ModelProviderDelegate {
  
  func show(predictions: [YOLO.Prediction]?,
            stat: ModelProvider.Statistics, error: YOLOError?) {
    guard let predictions = predictions else {
      guard let error = error else {
        showAlert(title: "Error!", msg: "Unknow error")
        return
      }
      if let errorDescription = error.errorDescription {
        showAlert(title: "Error!", msg: errorDescription)
      } else {
        showAlert(title: "Error!", msg: "Unknow error")
      }
      return
    }
    if processStarted {
      predictionLayer.addBoundingBoxes(predictions: predictions)
      predictionLayer.show()
      processed = true
      detectButton.setTitle("Recommencer", for: .normal)
      for prediction in predictions {
        // Show when there are damages
        if prediction.classIndex == 1 {
          costButton.isHidden = false
        }
      }
      processStarted = false
    }
  }
  
}

// MARK: - UIImagePickerControllerDelegate

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    self.dismiss(animated: true)
    predictionLayer.show()
  }
  
  @objc func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      self.imageView.image = pickedImage
      photoButtonsStackView.isHidden = true
      self.imageView.backgroundColor = .clear
      predictionLayer.update(imageViewFrame: imageView.frame, imageSize: pickedImage.size)
      predictionLayer.clear()
      processed = false
      detectButton.setTitle("Détecter", for: .normal)
      damageView.isHidden = true
      costButton.isHidden = true
    }
    self.dismiss(animated: true)
  }

}
