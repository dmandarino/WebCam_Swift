//
//  ViewController.swift
//  WebCam
//
//  Created by Douglas Mandarino on 5/26/16.
//  Copyright © 2016 Douglas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let webCam = WebCamViewController()
        webCam.startCam()
        self.view.addSubview(webCam.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

