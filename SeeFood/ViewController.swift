//
//  ViewController.swift
//  SeeFood
//
//  Created by Pathompat Mekbenchapivat on 20/4/2567 BE.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate and properties of the image picker
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            // Convert UIImage to CIImage for processing
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not converted to CIImage.")
            }
            
            // Detect objects in the image
            detect(image: ciimage)
        }
        
        // Dismiss the image picker after selection
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Object Detection
    
    func detect(image: CIImage) {
        // Load the CoreML model for object detection
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed.")
        }
        
        // Create a request to process the image
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            // Check if the first result contains "hotdog" identifier
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "Hotdog!"
                } else {
                    self.navigationItem.title = "Not Hotdog!"
                }
            }
        }
        
        // Create a handler to perform the image request
        let handler = VNImageRequestHandler(ciImage: image)
        
        // Perform the image request
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cameraTab(_ sender: UIBarButtonItem) {
        // Present the image picker when camera button is tapped
        present(imagePicker, animated: true, completion: nil)
    }
}

