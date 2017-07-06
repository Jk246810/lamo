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
    
    let googleAPIKey = "AIzaSyBWULC40id62H2C7Iao2ZjBu4B5mU7vkvc"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    var image: UIImage?
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultsSegue" {
            if let resultsViewController = segue.destination as? ResultsViewController {
//                let images = image
//                resultsViewController.imageView = images
                resultsViewController.newImage = image
                
            }
        }
    }
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var faceResult: UILabel!

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
    func analyzeResult(_ dataToParse: Data) {
        DispatchQueue.main.async( execute: {
            
            
            // Use swifty json to parse the result
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            if (errorObj.dictionaryValue != [:]) {
                self.resultLabel.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // print the json to the console
                print(json)
                
                let response: JSON = json["responses"][0]
                
                // get face annotation
                let faceAnnotation: JSON = response["faceAnnotations"]
                if faceAnnotation != JSON.null {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                    
                    let numPeopleDetected: Int = faceAnnotation.count
                    
                    self.faceResult.text = "People detected: \(numPeopleDetected)\nEmotions detected:\n"
                    
                    var emotionalsTotal: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionalLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY": 0.25, "VERY_UNLIKELY": 0.0]
                    
                    for person in 0..<numPeopleDetected {
                        let personData: JSON = faceAnnotation[person]
                        
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let results: String = personData[lookup].stringValue
                            
                            emotionalsTotal[emotion]! += emotionalLikelihoods[results]!
                        }
                    }
                    
                    for (emotion, total) in emotionalsTotal {
                        let likelihood: Double = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
                            
                        self.faceResult.text! += "\(emotion): \(percent)%\n"
                    }
                    
                } else {
                    self.faceResult.text = "No face detected"
                }
                
                // get label annotation
                let labelAnnotation: JSON = response["labelAnnotations"]
                let numLabel = labelAnnotation.count
                
                var labels: Array<String> = []
                
                if numLabel > 0 {
                    var labelResultText = "Label found: "
                    
                    for index in 0..<numLabel {
                        let label = labelAnnotation[index]["description"].stringValue
                        labels.append(label)
                    }
                    
                    for label in labels {
                        if labels[labels.count - 1] != label {
                            labelResultText += "\(label), "
                        } else {
                            labelResultText += "\(label) "
                        }
                    }
                    
                    self.resultLabel.text = labelResultText
                } else {
                    self.resultLabel.text = "No label found"
                }
            }
            
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        // photo library
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // do the init during rendering the code for the images
            print("code is running")
            
            let binaryImageData = base64EncodeImage(pickedImage)
            // create the request with the image data retrieved
            createRequest(with: binaryImageData)
        }
//        dismiss(animated: true, completion: nil)
        
        // camera
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.image = selectedImage
        }
        
        picker.dismiss(animated: true)
        self.performSegue(withIdentifier: "resultsSegue", sender: nil)
    }
    
    // close the photo library when its cancelled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // resize the image
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}

// networking
extension MainViewController {
    // return the image data
    func base64EncodeImage(_ image: UIImage) -> String {
        var imageData = UIImagePNGRepresentation(image)
        
        // resize the image if it is larger than 2mb limit
        if (imageData!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resizeImage(newSize, image: image)
        }
        
        return imageData!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // build api request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ],
                    [
                        "type": "FACE_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // serialize the json
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // run the request
        DispatchQueue.global().async {
            self.runRequestOnBackgroundThread(request)
        }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request 
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // call the analyze result function
            self.analyzeResult(data)
        }
        
        task.resume()
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
