//
//  ViewController.swift
//  CustomModel
//
//  Created by Elmansy, Amira on 6/23/17.
//  Copyright © 2017 Elmansy, Amira. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifierLabel: UILabel!

    var model: EmotiW_VGG_S!

    override func viewDidLoad() {
        super.viewDidLoad()

        model = EmotiW_VGG_S()
    }

    // MARK: Actions
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) { return }

        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false

        present(cameraPicker, animated: true, completion: nil)
    }

    @IBAction func libraryButtonTapped(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false

        present(picker, animated: true, completion: nil)
    }
}

extension ViewController: UINavigationControllerDelegate {
}

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)

        classifierLabel.text = "Analyzing Image..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
        imageView.image = image

        // ***** Begin of: Using Vision *****

        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let coreImage = CIImage(image: image) else { return }
        guard let vnModel = try? VNCoreMLModel(for: EmotiW_VGG_S().model) else { return }

        let request = VNCoreMLRequest(model: vnModel) { request, error in
            guard
                let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else { return }

            DispatchQueue.main.async { [weak self] in
                self?.classifierLabel.text = topResult.identifier
            }
        }
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(ciImage: coreImage, orientation: orientation)
        try?handler.perform([request])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }

        // ***** End of: Using Vision *****

        // ***** Begin of: Using Core ML *****

//        guard let pixelBuffer = image.buffer(with: CGSize(width: 224, height: 224)) else { return }
//
//        // Core ML
//        guard let prediction = try?model.prediction(data: pixelBuffer) else { return }
//        classifierLabel.text = prediction.classLabel

        // ***** End of: Using Core ML *****
    }
}

