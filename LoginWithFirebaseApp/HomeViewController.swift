//
//  HomeViewController.swift
//  LoginWithFirebaseApp
//
//  Created by 高木克 on 2022/06/12.
//

import Foundation
import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    var user: User? {
//        インスタンスを取得時に起動する
        didSet {
            print("user?.name: ", user?.name)
        }
    }

    @IBAction func tappedLogoutButton(_ sender: Any) {
        handleLogout()
    }
    
    private func handleLogout() {
//        importでFirebaseを追加する
        
        do {
            try Auth.auth().signOut()
            dismiss(animated: true, completion: nil)
        } catch (let err) {
            print("ログアウトに失敗しました\(err)")
        }
        
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.layer.cornerRadius = 10
        
        if let user = user{
            nameLabel.text = user.name + "さんようこそ"
            emailLabel.text = user.email
//            時間の設定
            let dataString = dateFormatterForCreatedAt(date: user.createAt.dateValue())
            dateLabel.text = "作成日: " + dataString
        }
    }
    
//    時間の設定メソッド
    private func dateFormatterForCreatedAt(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier:  "ja_jP")
        return formatter.string(from: date)
    }
    
}
