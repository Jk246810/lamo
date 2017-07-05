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
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var faceResult: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        imagePicker.delegate = self
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        print("camera button tapped")
    }
    
    // open the photo library
    @IBAction func libraryButtonTapped(_ sender: UIButton) {
        print("library button tapped")
        
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
                
                let response: JSON = json["response"][0]
                
                // get face annotation
                let faceAnnotation: JSON = response["faceAnnotations"]
                if faceAnnotation != nil {
                    let emotions: Array<String> = ["joy", "sorrow", "suprise", "anger"]
                    
                    let numPeopleDetected: Int = faceAnnotation.count
                    
                    self.faceResult.text = "People detected: \(numPeopleDetected)\nEmotions detected:\n"
                    
                    var emotionalsTotal: [String: Double] = ["sorrow": 0, "joy": 0, "suprise": 0, "anger": 0]
                    var emotionalLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY": 0.25, "VERY_UNLIKELY": 0.0]
                    
                    for person in 0..<numPeopleDetected {
                        let personData: JSON = faceAnnotation[person]
                        
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let results: String = personData[lookup].stringValue
                            
                            emotionalsTotal[emotion]! += emotionalLikelihoods[results]!
                        }
                        
                        for (emotion, total) in emotionalsTotal {
                            let likelihood: Double = total / Double(numPeopleDetected)
                            let percent: Int = Int(round(likelihood * 100))
                            
                            self.faceResult.text! += "\(emotion): \(percent)%\n"
                        }
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
}
















