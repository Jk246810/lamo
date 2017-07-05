//
//  ViewController.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/3/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imagesButton: UIButton!
    
    var image: UIImage?
    
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
    
    @IBAction func imagesButtonTapped(_ sender: UIButton) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = selectedImage
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

