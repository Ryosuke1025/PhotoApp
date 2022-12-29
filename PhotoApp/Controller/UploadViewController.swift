//
//  ViewController.swift
//  PhotoApp
//
//  Created by 須崎良祐 on 2022/11/07.
//

import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

class UploadViewController: UIViewController {
    
    private lazy var picker: PHPickerViewController = {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.selectionLimit = 3
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func presentImagePicker(_ sender: Any) {
        present(picker, animated: true, completion: nil)
    }

    
    @IBAction func fotoView(_ sender: Any) {
        let storyboard = UIStoryboard(name: "PhotoView", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "PhotoViewController")
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    func uploadToStorage(image: UIImage) {
        let date = NSDate()
        let currentTimeStampInSecond = UInt64(floor(date.timeIntervalSince1970 * 1000))
        let storageRef = Storage.storage().reference(forURL: "gs://photoapp-4542d.appspot.com").child("images").child("\(currentTimeStampInSecond).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        if let uploadData = image.jpegData(compressionQuality: 0.9) {
            storageRef.putData(uploadData, metadata: metaData) { (metadata , error) in
                if error != nil {
                    print("写真のアップロードに失敗しました")
                }
                storageRef.downloadURL(completion: { (url, error) in
                    if error != nil {
                        print("URLの取得に失敗しました")
                    }
                    self.uploadToFireStore(url: url)
                })
            }
        }
    }
    
    func uploadToFireStore(url: URL?) {
        guard let photo_url = url?.absoluteString else { return }
        let db = Firestore.firestore()
        db.collection("users").document("user1").setData(
        [
            "ID": "1",
            "photoURLs": FieldValue.arrayUnion([photo_url]),
        ], merge: true
        ) { error in
            if error != nil {
                print("データの保存に失敗しました")
            }
        }
    }
}

extension UploadViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        // Pickerを閉じたときにコールされる
        for image in results {
            // PHPickerResultからImageを読み込む
            image.itemProvider.loadObject(ofClass: UIImage.self) { (selectedImage, error) in
                if error != nil {
                    assertionFailure("写真の選択に失敗しました")
                    return
                }
                // UIImageに変換
                guard let wrapImage = selectedImage as? UIImage else {
                    assertionFailure("UIImageへの変換に失敗しました")
                    return
                }
                self.uploadToStorage(image: wrapImage)
            }
        }
        dismiss(animated: true)
    }
}

