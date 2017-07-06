//
//  PhotoLibraryViewController.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PhotoLibraryViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var labelResult: UILabel!
    @IBOutlet weak var facialResult: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoView.image = PhotoLibrary.pickedPhoto
        
        if let pickedImage = PhotoLibrary.info[UIImagePickerControllerOriginalImage] as? UIImage {
            // do the init during rendering the code for the images
            let binaryImageData = PhotoLibrary.base64EncodeImage(pickedImage)
            // create the request with the image data retrieved
            PhotoLibrary.createRequest(with: binaryImageData, url: PhotoLibrary.googleURL, completion: { (result) in
                self.labelResult.text = result[0]
                self.facialResult.text = result[1]
            })
            
            // set the photo in the photolibrary to the picked image
            PhotoLibrary.pickedPhoto = pickedImage
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
