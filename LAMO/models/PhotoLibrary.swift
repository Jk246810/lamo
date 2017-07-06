//
//  PhotoLibrary.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/6/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct PhotoLibrary {
    private static let googleAPIKey = "AIzaSyBWULC40id62H2C7Iao2ZjBu4B5mU7vkvc"
    static var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    static var info: [String: Any] = [:]
    
    static var resultLabelText: String = String()
    static var resultFacialText: String = String()
    
    // resize the image
    static func resize(imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
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
    
    static func analyzeResult(_ dataToParse: Data) {
        
        // Use swifty json to parse the result
        let json = JSON(data: dataToParse)
        let errorObj: JSON = json["error"]
        
        if (errorObj.dictionaryValue != [:]) {
            resultLabelText = "Error code \(errorObj["code"]): \(errorObj["message"])"
        } else {
            // print the json to the console
            print(json)
            
            let response: JSON = json["responses"][0]
            
            // get face annotation
            let faceAnnotation: JSON = response["faceAnnotations"]
            if faceAnnotation != JSON.null {
                let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                
                let numPeopleDetected: Int = faceAnnotation.count
                
                resultFacialText = "People detected: \(numPeopleDetected)\nEmotions detected:\n"
                
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
                    
                    resultFacialText += "\(emotion): \(percent)%\n"
                }
                
            } else {
                resultFacialText = "No face detected"
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
                
                resultLabelText = labelResultText
            } else {
                resultLabelText = "No label found"
            }
        }
    }
    
    static func createRequest(with imageBase64: String, url googleURL: URL, completion: @escaping ([String]) -> Void) {
        
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
        
        Alamofire.request(request).responseJSON(queue: .global(), options: []) { response in
            self.analyzeResult(response.data!)
            completion([resultLabelText, resultFacialText])
        }
        
    }
}
