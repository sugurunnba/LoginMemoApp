//
//  LoginViewController.swift
//  LoginWithFirebaseApp
//
//  Created by 高木克 on 2022/06/18.
//

import UIKit
import Firebase
import PKHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
//    SecureTextEntryをチェックすることで、入力したパスワードが隠れて表示される
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func dontHaveAccountButton(_ sender: Any) {
//        前の画面に戻る
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedLoginButton(_ sender: Any) {
//        HUDが起動するようにするメソッド
        HUD.show(.progress, onView: self.view)
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}

        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            if let err = err {
                print("ログイン情報の取得に失敗しました", err)
                return
            }
            print("ログインに成功しました")
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let userRef = Firestore.firestore().collection("users").document(uid)
//                Firestoreからデータを取得
                userRef.getDocument{ (snapshot, err) in
                    if let err = err {
                        print("ユーザー情報の取得に失敗しました。\(err)")
                        HUD.hide { (_) in
                            HUD.flash(.error, delay: 1)
                        }
                    }
                    
//                    登録したデータを取得
                    guard let data = snapshot?.data() else {return}
//                    取得したデータをモデルに変換して、変数化
                    let user = User.init(dic: data)
                    print("ユーザー情報の取得に成功しました。\(user.name)")
                    HUD.hide { (_) in
//                        成功した後に、画面遷移を行いたいので、成功後に遷移が始まるようにする
                        HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                            self.presentToHomeViewController(user: user)
                        }
                    }
            }
        }
    }
    
    private func presentToHomeViewController(user: User) {
//      画面の遷移準備
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
//      identifierを設定する際、「Use Storyboard　ID」をチェックも忘れずに。
        let homeViewController = storyBoard.instantiateViewController(identifier: "HomeViewController") as! HomeViewController
        homeViewController.user = user
//      遷移後の画面をフルスクリーン化
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ボタンを押せないようにする
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
//        ボタンの丸みを設定
        loginButton.layer.cornerRadius = 10

//        emailTextField・passwordTextFieldの処理は、extensionのdelegateで処理している
//        delegate処理を行うクラスはどこ？ = それは自身のインスタンス内のメソッドで行う(ここではextensionのtextFieldChangeSelectionで実行)
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
}


extension LoginViewController: UITextFieldDelegate {
//    テキストフィールドで入力した値を受け取る
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true

        if emailIsEmpty || passwordIsEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}
