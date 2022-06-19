//
//  User.swift
//  LoginWithFirebaseApp
//
//  Created by 高木克 on 2022/06/19.
//

import Foundation
import Firebase

//userのmodel
struct User {
    let name: String
    let createAt: Timestamp
    let email: String
    
//    javaで言うところのコンストラクタ。インスタンス生成時に自動で呼ばれるメソッド
//    登録する際のdocDataが辞書型のため、取得する際には辞書型で取得する。辞書型はdocやつ。
    init(dic: [String: Any]){
        self.name = dic["name"] as! String
        self.createAt = dic["createdAt"] as! Timestamp
        self.email = dic["email"] as! String
    }
}
