//
//  ViewController.swift
//  CICD_iOS
//
//  Created by Mu_Mac on 2025/5/13.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var testBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func testAction(_ sender: Any) {
        self.testBtn.setTitle("testOK", for: .normal)
    }
    
}

