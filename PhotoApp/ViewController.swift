//
//  ViewController.swift
//  PhotoApp
//
//  Created by 須崎良祐 on 2022/11/07.
//

import UIKit
import FirebaseStorage

class ViewController: UIViewController {
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func presentImagePicker(_ sender: Any) {
        imagePicker.allowsEditing = true //画像の切り抜きが出来るようになります。
        imagePicker.sourceType = .photoLibrary //画像ライブラリを呼び出します
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func startUpload(_ sender: Any) {
        upload()
    }
    
    fileprivate func upload() {
            let date = NSDate()
            let currentTimeStampInSecond = UInt64(floor(date.timeIntervalSince1970 * 1000))
            let storageRef = Storage.storage().reference(forURL: "gs://photoapp-4542d.appspot.com").child("images").child("\(currentTimeStampInSecond).jpg")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            if let uploadData = self.imageView.image?.jpegData(compressionQuality: 0.9) {
                storageRef.putData(uploadData, metadata: metaData) { (metadata , error) in
                    if error != nil {
                        print("error: \(error?.localizedDescription)")
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("error: \(error?.localizedDescription)")
                        }
                        print("url: \(url?.absoluteString)")
                    })
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

