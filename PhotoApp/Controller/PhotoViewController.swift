//
//  PhotoViewController.swift
//  PhotoApp
//
//  Created by 須崎良祐 on 2022/11/08.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class PhotoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFromFireStore()
    }
    
    func getFromFireStore(){
        // FirestoreのDB取得
        let db = Firestore.firestore()
        // usersコレクションを取得
        db.document("/users/user1").getDocument() { document, error in
            // エラー発生時
            if error != nil {
                assertionFailure("データの取得に失敗しました")
            }
            guard let document = document else { return }
            do {
                let post = try document.data(as: PostModel.self)
                print(post)
            } catch {
                print("デコードに失敗しました")
            }   
        }
    }
    
}

