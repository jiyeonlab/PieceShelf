//
//  AddViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    lazy var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showActionSheet(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    @IBAction func tappedBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func showActionSheet(_ sender: UITapGestureRecognizer){
        let alert = UIAlertController()
        
        let webSearch = UIAlertAction(title: "웹에서 검색하기", style: .default){ _ in
            guard let webSearchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebSearchVC") as? WebSearchViewController else {
                return
            }
            
            webSearchVC.modalPresentationStyle = .fullScreen
            self.present(webSearchVC, animated: true)
        }
        let albumSearch = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            self.openAlbum()
        }
        let camera = UIAlertAction(title: "카메라로 촬영하기", style: .default) { _ in
            self.openCamera()
        }
        
        alert.addAction(webSearch)
        alert.addAction(albumSearch)
        alert.addAction(camera)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}

// UIImagePicker 추가
extension AddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func openAlbum() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func openCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true)
        }else{
            print("Camera not available")
        }
        
    }
}

