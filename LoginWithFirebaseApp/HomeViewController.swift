//
//  HomeViewController.swift
//  LoginWithFirebaseApp
//
//  Created by 高木克 on 2022/06/12.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        
    }
    
}
