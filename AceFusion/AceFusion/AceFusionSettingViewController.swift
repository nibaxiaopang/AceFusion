//
//  SettingViewController.swift
//  AceFusion
//
//  Created by jin fu on 2024/11/1.
//

import UIKit

class AceFusionSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
