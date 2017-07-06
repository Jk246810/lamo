//
//  ResultsViewController.swift
//  LAMO
//
//  Created by Brian on 7/5/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var newImage: UIImage!
    
    @IBOutlet weak var facialResultLabel2: UILabel!
    @IBOutlet weak var resultLabel2: UILabel!
    //do i need to declare it as an optional or should I be forcably unwrapping it 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = newImage
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "done" {
                print("done button tapped")
            }
        }
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
