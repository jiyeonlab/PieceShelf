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
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UIButton!
    @IBOutlet weak var catecoryField: UIButton!
    
    lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showActionSheet(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        // imageView Height 조정
        imageViewHeight.constant = view.frame.height / Constant.imageViewHeightRatio
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
            
            // WebSearchVC에서 선택한 썸네일 데이터를 받기 위해, 추가
            webSearchVC.sendThumbnailDelegate = self
            
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
    
    // 날짜 선택 버튼을 눌렀을 때.
    @IBAction func selectDate(_ sender: Any) {
        let actionSheet = UIAlertController()
        
        // ActionSheet에 DatePicker 추가
        let datePicker = UIViewController()
        datePicker.view = datePickerView
        datePicker.preferredContentSize.height = Constant.datePickerHeight
        actionSheet.setValue(datePicker, forKey: "contentViewController")
        
        actionSheet.addAction(UIAlertAction(title: "저장", style: .default, handler: { _ in
            let date = self.datePickerView.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"

            self.dateField.setTitle(dateFormatter.string(from: date), for: .normal)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(actionSheet, animated: true)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            self.imageView.image = selectedImage
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.backgroundColor = .clear
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// WebSearchVC로부터 Thumbnail을 받기 위해.
extension AddViewController: SendThumbnailDelegate {
    func sendThumbnail(url: String) {
        
        imageView.image = nil
        imageView.backgroundColor = .clear
        
        DispatchQueue.global().async {
            guard let thumbnailURL = URL(string: url) else {
                return
            }
            guard let thumbnail = try? Data(contentsOf: thumbnailURL) else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: thumbnail)
                self.imageView.contentMode = .scaleAspectFit
            }
        }
    }
}
