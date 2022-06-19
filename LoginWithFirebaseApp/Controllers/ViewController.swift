//
//  ViewController.swift
//  LoginWithFirebaseApp
//
//  Created by 高木克 on 2022/06/11.
//

import UIKit
import Firebase
import PKHUD

class ViewController: UIViewController  {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
//    登録ボタンが押された時
    @IBAction func tappedRegisterButton(_ sender: Any) {
//    登録ボタンが押された時のメソッド
        handleAuthToFirebase()
    }
    
//    「コチラ」ボタンを押下時
    @IBAction func tappedAlrealyHaveAccountButton(_ sender: Any) {
//       「コチラ」ボタンを押下時のメソッド
        pushToLoginViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        初期画面の画面パーツの設定メソッド
        setupViews()
//        キーボードを表示/非表示の際、いい感じに画面を調節するメソッド
        setupNotificationObserver()
    }
    
//    ナビゲーションバーを非表示にする
//    画面が呼び出される直前に呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }

//       「コチラ」ボタンを押下時のメソッド
    private func pushToLoginViewController() {
//      画面の遷移準備
        let storyBoard = UIStoryboard(name: "Login", bundle: nil)
//      identifierを設定する際、「Use Storyboard　ID」をチェックも忘れずに。
        let loginViewController = storyBoard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
//      ボタン押下後、横にスライドしながら遷移する
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
//    初期画面の画面パーツの設定メソッド
    private func setupViews() {
//        ボタンを押せないようにする
        registerButton.isEnabled = false
        registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
//        ボタンの丸みを設定
        registerButton.layer.cornerRadius = 10
        
//        emailTextField・passwordTextFieldの処理は、extensionのdelegateで処理している
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        
    }

//        キーボードを表示/非表示の際、いい感じに画面を調節するメソッド
    private func setupNotificationObserver() {
//        キーボードが表示されたときに通知する
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
//        キーボードが非表示になったときに通知する
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
//    登録ボタンが押された時のメソッド
    private func handleAuthToFirebase() {
//        登録中のぐるぐる画面の設定
        HUD.show(.progress, onView: view)
        
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
//        ユーザの作成
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
//            エラーが発生した場合
            if let err = err {
                print("認証情報の保存に失敗しました。\(err)")
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
//            メール・パスワード認証でエラーが発生しなかった時の処理
            self.addUerInfoToFirestore(email: email)
        }
    }
    
//    メール・パスワード認証でエラーが発生しなかった時の処理
//    Firestore(DB)にユーザー情報を保存するロジック
    private func addUerInfoToFirestore(email: String) {
//        成功した場合
        print("認証情報の保存に成功しました。")
        
//        ユーザUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else {return}
//        入力されたユーザ名を取得
        guard let name = self.usernameTextField.text else {return}
        
        let docData = ["email": email, "name": name, "createdAt": Timestamp()] as [String : Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        
//        FirebaseDBに登録しているコレクション(Entity名)の選択。そのコレクションにデータを登録する
        userRef.setData(docData) {
            (err) in
            if let err = err {
                print("FIrestoreへの保存に失敗しました。\(err)")
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
                return
            }
//            Firestore(DB)からユーザデータを取得して、次画面へ遷移するメソッド
            self.fetchUserInfoFromFirestore(userRef: userRef)
        }
    }
    
//    Firestore(DB)からユーザデータを取得して、次画面へ遷移するメソッド
    private func fetchUserInfoFromFirestore(userRef: DocumentReference) {
//        Firestoreからデータを取得
        userRef.getDocument{ (snapshot, err) in
            if let err = err {
                print("ユーザー情報の取得に失敗しました。\(err)")
                HUD.hide { (_) in
                    HUD.flash(.error, delay: 1)
                }
            }
            
//            登録したデータを取得
            guard let data = snapshot?.data() else {return}
//            取得したデータをモデルに変換して、変数化
            let user = User.init(dic: data)
            print("ユーザー情報の取得に成功しました。\(user.name)")
            HUD.hide { (_) in
//                成功した後に、画面遷移を行いたいので、成功後に遷移が始まるようにする
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    self.presentToHomeViewController(user: user)
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
    
//    NotificationCenter(show)で通知する内容
//    キーボードを表示した時、全体が見えるように調整する
    @objc func showKeyboard(notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        let registerButtonMaxY = registerButton.frame.maxY
        let distance = registerButtonMaxY - keyboardMinY
        
        let transform = CGAffineTransform(translationX: 0, y: -distance)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transform
        })
        
//        print("keyboardMinY :", keyboardMinY, "registerButtonMaxY: ", registerButtonMaxY)
    }
//    NotificationCenter(hide)で通知する内容
//    キーボードを隠したとき、画面の見え方を調整する
    @objc func hideKeyboard(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    
//    テキストフィールドを選択している際、テキストフィールド外を押せばキーボードが収まる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension ViewController: UITextFieldDelegate {
//    テキストフィールドで入力した値を受け取る
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let emailIsEmpty = emailTextField.text?.isEmpty ?? true
        let passwordIsEmpty = passwordTextField.text?.isEmpty ?? true
        let usernameIsEmpty = usernameTextField.text?.isEmpty ?? true
        
        if emailIsEmpty || passwordIsEmpty || usernameIsEmpty {
            registerButton.isEnabled = false
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 221, blue: 187)
        } else {
            registerButton.isEnabled = true
            registerButton.backgroundColor = UIColor.rgb(red: 255, green: 141, blue: 0)
        }
    }
}

