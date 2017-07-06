//
//  PhotoLibrary.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PhotoLibrary {
    // resize the image
    static func resize(imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    static func analyzeResult(_ dataToParse: Data, target mainViewController: MainViewController) {
        DispatchQueue.main.async( execute: {
            
            
            // Use swifty json to parse the result
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            if (errorObj.dictionaryValue != [:]) {
                mainViewController.resultLabel.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // print the json to the console
                print(json)
                
                let response: JSON = json["responses"][0]
                
                // get face annotation
                let faceAnnotation: JSON = response["faceAnnotations"]
                if faceAnnotation != JSON.null {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                    
                    let numPeopleDetected: Int = faceAnnotation.count
                    
                    mainViewController.faceResult.text = "People detected: \(numPeopleDetected)\nEmotions detected:\n"
                    
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
                        
                        mainViewController.faceResult.text! += "\(emotion): \(percent)%\n"
                    }
                    
                } else {
                    mainViewController.faceResult.text = "No face detected"
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
                    
                    mainViewController.resultLabel.text = labelResultText
                } else {
                    mainViewController.resultLabel.text = "No label found"
                }
            }
            
        })
    }
    
    // return the image data
    static func base64EncodeImage(_ image: UIImage) -> String {
        var imageData = UIImagePNGRepresentation(image)
        
        // resize the image if it is larger than 2mb limit
        if (imageData!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resize(imageSize: newSize, image: image)
        }
        
        return imageData!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    private static func runRequestOnBackgroundThread(_ request: URLRequest, target mainViewController: MainViewController) {
        // run the request
        let task: URLSessionDataTask = mainViewController.session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            // call the analyze result function
            self.analyzeResult(data, target: mainViewController)
        }
        task.resume()
    }
    
    static func createRequest(with imageBase64: String, url googleURL: URL, viewController: MainViewController) {
        
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
            self.runRequestOnBackgroundThread(request, target: viewController)
        }
    }
}
