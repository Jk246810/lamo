//
//  CameraViewController.swift
//  LAMO
//
//  Created by Brian on 7/5/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error : NSError?
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if (error == nil && captureSession?.canAddInput(input) != nil) {
                captureSession?.addInput(input)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                if (captureSession?.canAddOutput(stillImageOutput) != nil) {
                    captureSession?.addOutput(stillImageOutput)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                    cameraView.layer.addSublayer(previewLayer!)
                    captureSession?.startRunning()
                    
                }
                
            }
        } catch {
            
            
        }
        
    }

    
    @IBOutlet weak var tempImageView: UIImageView!

    func didPressTakePhoto() {
        if let videoConnection = stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData! as CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    
                    self.tempImageView.image = image
                    self.tempImageView.isHidden = false
                    
                }
                
                
                
            })
            
        }
    }
    
    var didTakePhoto = Bool()
    
    func didPressTakeAnother() {
        if didTakePhoto == true {
            tempImageView.isHidden = true
            didTakePhoto = false
            
        } else {
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        didPressTakeAnother()
    }


}
