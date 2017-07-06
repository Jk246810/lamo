//
//  MainViewController.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/5/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    
    var image: UIImage?
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        
        //implement initialze a uiimagepickerconroller
        let cameraViewController = UIImagePickerController()
        //set the type to camera
        cameraViewController.sourceType = .camera
        
        //delegate
        
        cameraViewController.delegate = self
        //present the imagepicker
        
        present(cameraViewController, animated: true, completion: nil)
    }

    
    // open the photo library
    @IBAction func libraryButtonTapped(_ sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
}

// handle the photos
extension MainViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        // photo library
        PhotoLibrary.info = info
        
        // camera
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = selectedImage
        }
        
        picker.dismiss(animated: true)
        performSegue(withIdentifier: "toResultPage", sender: self)
    }
    
    // close the photo library when its cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
