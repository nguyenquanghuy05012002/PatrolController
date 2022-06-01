//
//  ViewController.swift
//  App
//
//  Created by Nguyễn Quang Huy on 16/05/2022.
//

import UIKit
import SwiftUI

class Option: UIViewController {


    @IBOutlet weak var nameApp: UILabel!
    @IBOutlet weak var thuCongLabel: UIButton!
    @IBOutlet weak var tuDongLabel: UIButton!
    
    @IBAction func thuCongButton(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 162/255, green: 161/255, blue: 217/255, alpha: 1)
        sender.tintColor = UIColor.white

    }
    
    @IBAction func tuDongButton(_ sender: UIButton) {
        sender.backgroundColor = UIColor(red: 162/255, green: 161/255, blue: 217/255, alpha: 1)
        sender.tintColor = UIColor.white
    }
}
