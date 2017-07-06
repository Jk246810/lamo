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
        labelResult.text = PhotoLibrary.resultLabelText
        facialResult.text = PhotoLibrary.resultFacialText
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
