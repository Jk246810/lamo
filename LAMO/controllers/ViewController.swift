//
//  ViewController.swift
//  LAMO
//
//  Created by Nguyễn Lâm on 7/3/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var imagesButton: UIButton!
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        print("camera button tapped")
    }
    
    @IBAction func imagesButtonTapped(_ sender: UIButton) {
        print("image button tapped")
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

