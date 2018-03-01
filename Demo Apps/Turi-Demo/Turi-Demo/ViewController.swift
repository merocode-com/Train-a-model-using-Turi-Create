//
//  ViewController.swift
//  Turi-Demo
//
//  Created by Elmansy, Amira on 2/11/18.
//  Copyright © 2018 Elmansy, Amira. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classLabel: UILabel!

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

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)

        classLabel.text = "Analyzing Image..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
        imageView.image = image
        guard let coreImage = CIImage(image: image) else { return }

        guard let vnModel = try? VNCoreMLModel(for: dog_classifier().model) else { return }

        let request = VNCoreMLRequest(model: vnModel) { (request, error) in
            guard
                let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else { return }

            let identifier = topResult.identifier

            let classLabel = identifier.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: ".", with: " ").components(separatedBy: CharacterSet.decimalDigits).joined()

            DispatchQueue.main.async { [weak self] in
                self?.classLabel.text = "This is \(classLabel)"
            }
        }

        let handler = VNImageRequestHandler(ciImage: coreImage)
        try?handler.perform([request])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
}

extension ViewController: UINavigationControllerDelegate {
}

