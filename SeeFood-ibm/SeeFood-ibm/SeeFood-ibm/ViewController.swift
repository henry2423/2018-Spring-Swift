//
//  ViewController.swift
//  SeeFood-ibm
//
//  Created by Henry on 03/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    let apiKey = "e651723c53caab6e52e0d98ac22c4bb1db9bba89"
    let version = "2018-03-02"
    
    let imagePicker = UIImagePickerController()
    var classificationResults: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareButton.isHidden = true
        imagePicker.delegate = self
    }
    
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
           let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText("My food is \(navigationItem.title)")
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
        } else {
            self.navigationItem.title = "Please Log into Twitter"
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        guard let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Can't convert to UIImage")
        }
        imageView.image = userPickedImage
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
        
        let imageData = UIImageJPEGRepresentation(userPickedImage, 0.01)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
        
        try? imageData?.write(to: fileURL, options: [])
        
        visualRecognition.classify(imageFile: fileURL) { (classfiedImages) in
            
            let classes = classfiedImages.images.first!.classifiers.first!.classes
            
            self.classificationResults = []
            
            for index in 1..<classes.count {
                self.classificationResults.append(classes[index].classification)
            }
            
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                SVProgressHUD.dismiss()
                self.shareButton.isHidden = false
            }
            
            if self.classificationResults.contains("hotdog") {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = false
                    self.topBarImageView.image = #imageLiteral(resourceName: "hotdog")
                }
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.title = "Not Hotdog!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.red
                    self.navigationController?.navigationBar.isTranslucent = false
                    self.topBarImageView.image = #imageLiteral(resourceName: "not-hotdog")
                }
            }
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    

}

