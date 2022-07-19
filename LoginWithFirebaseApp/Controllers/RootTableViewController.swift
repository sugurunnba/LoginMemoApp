//
//  RootTableViewController.swift
//  memoAppFirebase6
//
//  Created by 高木克 on 2022/07/03.
//

import UIKit
import Firebase

class RootTableViewController: UITableViewController {
    
    var user: User? {
//        インスタンスを取得時に起動する
        didSet {
            print("user?.name: ", user?.name)
        }
    }
    
    var memos: [Memo]! = []
    @IBOutlet weak var logoutButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("成功")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        confirmLoggetInUser()
        
        memos = []
        
//        データベースへの参照を定義
        let data = Firestore.firestore()
        data.collection("memos").getDocuments { [self] (snap, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            } else {
                for document in snap!.documents {
                    let data = document.data()
                    let memo = Memo.init(dic: data, documentId: document.documentID)
                    print(memo.documentId)
    //                メモの配列に追加
                    self.memos.append(memo)
                }
            }
            self.tableView.reloadData()
        }
    }

    
    @IBAction func addButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let AddVC = storyboard.instantiateViewController(withIdentifier: "addNavigationController") as! UINavigationController
        let view = AddVC.topViewController as! AddViewController
        self.navigationController?.pushViewController(view, animated: true)
    }
    
//    ログアウトボタン押下
    @IBAction func tappedLogoutButton(_ sender: Any) {
        handleLogout()
    }
    
    private func handleLogout() {
//        importでFirebaseを追加する
        
        do {
            try Auth.auth().signOut()
            presentToSignUpViewController()
//            dismiss(animated: true, completion: nil)
        } catch (let err) {
            print("ログアウトに失敗しました\(err)")
        }
        
    }
    
//    ログイン済みでなければ、新規登録画面を表示するメソッド
//    viewDidAppearは、画面が呼び出された直後に呼び出されるメソッド。つまりSneneDelegateでHome.storyboardが呼び出されたタイミングで発火する。
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        confirmLoggetInUser()
    }
    
//    ログイン済みでなければ、新規登録画面を表示するメソッド
    private func confirmLoggetInUser() {
        if Auth.auth().currentUser?.uid == nil || user == nil {
            presentToSignUpViewController()
        }
    }
    
//    新規登録画面へ遷移するメソッド
    private func presentToSignUpViewController() {
//      画面の遷移準備
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
//      identifierを設定する際、「Use Storyboard　ID」をチェックも忘れずに。
        let viewController = storyBoard.instantiateViewController(identifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: viewController)
//      遷移後の画面をフルスクリーン化
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }
    
//    時間の設定メソッド
    private func dateFormatterForCreatedAt(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier:  "ja_jP")
        return formatter.string(from: date)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let _memos = memos else { return 0 }
        return _memos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RootTableViewCell", for: indexPath)
        let memo = memos[indexPath.row]
        
        let nameLabel = cell.viewWithTag(1) as! UILabel
        nameLabel.text = memo.name
        
        let textLabel = cell.viewWithTag(2) as! UILabel
        textLabel.text = memo.text
        
        return cell
    }
    
//    セルタップ時
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // セルがタップされた時の処理
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      print("tapped")
      performSegue(withIdentifier: "EditViewController", sender: self)
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            

            Firestore.firestore().collection("memos").document(memos[indexPath.row].documentId).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            memos.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditViewController" {
            
            let NC = segue.destination as! UINavigationController
            let nextVC = NC.topViewController as! EditViewController
            nextVC.memo = self.memos[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }


}
