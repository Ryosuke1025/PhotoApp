//
//  PhotoViewController.swift
//  PhotoApp
//
//  Created by 須崎良祐 on 2022/11/08.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Nuke

class PhotoViewController: UIViewController {
    
    private var post: PostModel?
    @IBOutlet weak var collectionView: UICollectionView!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "CustomCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
        fetchData()
        
    }
    
    func fetchData() {
        let db = Firestore.firestore()
        db.document("/users/user1").getDocument() { document, error in
            if error != nil {
                assertionFailure("データの取得に失敗しました")
            }
            guard let document = document else { return }
            do {
                self.post = try document.data(as: PostModel.self)
                DispatchQueue.main.async {
                    self.collectionView.dataSource = self
                    self.collectionView.reloadData()
                }
            } catch {
                assertionFailure("デコードに失敗しました")
            }
        }
    }
    
    func fetchUIImage(url: String) -> UIImage {
        guard let url = URL(string: url) else { fatalError("String型からURL型への変換に失敗しました")}
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { fatalError("UIImageが空です")}
            return image
        } catch {
            fatalError("UIImageへの変換に失敗しました")
        }
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let safePost = self.post else { fatalError("safePostが空です")
        }
        guard let safePhotoURLs = safePost.photoURLs else { fatalError("URLが空です") }
        return safePhotoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let safePost = self.post else { fatalError("postが空です") }
        guard let safePhotoURLs = safePost.photoURLs else { fatalError("URLが空です") }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell else { fatalError("cellが空です")}
        Nuke.loadImage(with: safePhotoURLs[indexPath.row], into: cell.imageView)
        return cell
    }
}

extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth:CGFloat = collectionView.bounds.width / 3
        let cellHeight:CGFloat = cellWidth
        print(cellWidth)
        print(cellHeight)
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
