//
//  ViewController.swift
//  CatOrNot
//
//  Created by Виталий Антипов on 27/11/2019.
//  Copyright © 2019 Виталий Антипов. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var predictLabel: UILabel!
  
  private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: MobileNet.modelInfo)

  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard modelDataHandler != nil else {
      fatalError("Model set up failed")
    }
    
    imageView.layer.borderWidth = 1
    imageView.layer.borderColor = UIColor.gray.cgColor
    
  }

  @IBAction func pickPhoto(_ sender: Any) {
    let picker = UIImagePickerController()
    picker.delegate = self
    present(picker, animated: true)
  }
  
  func predict() {
    guard let image = imageView.image else {
      return
    }
    let resizedImage = image.resized(width: 150.0, height: 150.0)!
    let pixelBuffer = CVPixelBuffer.from(image: resizedImage)
    if let result = modelDataHandler!.runModel(onFrame: pixelBuffer!) {
      let predict = String(format: "%0.2f %%", (1 - result) * 100)
      predictLabel.text = "Вероятность присутствия кошки: \n \(predict)"
    } else {
      predictLabel.text = "Ошибка в вычислениях"
    }
    
  }
  
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.originalImage] as? UIImage {
      imageView.image = image
      imageView.layer.borderColor = UIColor.clear.cgColor
      picker.dismiss(animated: true)
      predict()
    }
  }
}

extension UIImage {
  func resized(width: CGFloat, height: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

