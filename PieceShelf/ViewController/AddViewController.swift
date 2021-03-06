//
//  AddViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var plusButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var imageAddButton: UILabel!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UIButton!
    @IBOutlet weak var catecoryField: UIButton!
    @IBOutlet weak var memoField: UITextView!
    
    lazy var imagePicker = UIImagePickerController()

    // 카테고리 picker 추가
    var customPickerView: UIPickerView?
    
    var selectedCatecoryIndex: Int = 0
    
    // Firebase DB 참조 및 정의
    var ref: DatabaseReference!
    
    // 썸네일 저장해 둘 변수
    var thumbnail: String?
    
    // UIImagePicker를 통해 불러온 사진을 저장해 둘 변수
    var image: UIImage?
    
    // 썸네일의 상태
    var thumbnailState: ThumbnailState?
    
    // 이미지 여부
    var isFilledImg = false
    
    lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        
        return picker
    }()
    
    // titlefield, memofield 중 어디인지
    var isTitle = false
    var isMemo = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showActionSheet(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        titleField.delegate = self
        memoField.delegate = self
        
        // imageView Height 조정
        imageViewHeight.constant = view.frame.height / Constant.imageViewHeightRatio
        plusButtonHeight.constant = imageViewHeight.constant / Constant.plusButtonHeightRatio
        // Firebase DB 참조
        ref = Database.database().reference()
        
        // textfield 입력 시 키보드에 따른 view 위치 조정을 위해.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
            
            self.dateField.setTitleColor(.darkGray, for: .normal)
            self.dateField.setTitle(dateFormatter.string(from: date), for: .normal)
            
            self.disableField()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(actionSheet, animated: true)
    }
    
    // 카테고리 선택 버튼을 눌렀을 때.
    @IBAction func selectCatecory(_ sender: Any) {
        let actionSheet = UIAlertController()
        
        // ActionSheet에 카테고리 선택을 위한 Picker 추가
        let catecoryPicker = UIViewController()
        configPickerView()
        catecoryPicker.view = customPickerView
        catecoryPicker.preferredContentSize.height = Constant.catecoryPickerHeight
        actionSheet.setValue(catecoryPicker, forKey: "contentViewController")
        
        actionSheet.addAction(UIAlertAction(title: "저장", style: .default, handler: { [weak self] action in
            self?.catecoryField.setTitleColor(.darkGray, for: .normal)
            self?.catecoryField.setTitle(Catecory.shared.catecoryList[self?.selectedCatecoryIndex ?? 0], for: .normal)
            self?.disableField()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    // Save 버튼을 눌러, 입력한 정보들을 저장하고자 함.
    @IBAction func tappedSave(_ sender: Any) {
        
        guard isFilledImg, titleField.text?.lengthOfBytes(using: .utf8) != 0, dateField.titleLabel?.text != "날짜를 선택하세요", catecoryField.titleLabel?.text != "카테고리를 선택하세요" else {
            let alert = UIAlertController(title: "이미지, 제목, 날짜, 카테고리는 \r\n 필수 항목입니다!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            
            present(alert, animated: true)
            return
        }
        
        guard imageView.image != nil, let title = titleField.text, let date = dateField.titleLabel?.text, let catecory = catecoryField.titleLabel?.text else {//
            return
        }
        
        switch thumbnailState {
        case .web:
            guard let thumbnailInfo = thumbnail else {
                
                return
            }
            
            let newData = UserData(title: title, thumbnail: thumbnailInfo, date: date, memo: memoField.text)
            
            ref.child("UserData").child(catecory).child(title).setValue(newData.toDictionary)
            
        case .photo:
            // MARK: Firebase Storage 이용
            
            let identifier = String(describing: Date.init())
            
            
            let newData = UserData(title: title, thumbnail: "Photo_\(identifier)", date: date, memo: memoField.text)
            
            guard let savedImg = image!.jpegData(compressionQuality: 0.5) else { return }
            let imageName = "Photo_\(identifier)"
            
            let riversRef = Storage.storage().reference().child((catecoryField.titleLabel?.text)!).child(imageName)
            
            riversRef.putData(savedImg, metadata: nil) { (metadata, error) in
                if(error != nil){
                    print("Error 발생 \(error?.localizedDescription)")
                }else{
                    print("업로드 완료")
                }
            }
            ref.child("UserData").child(catecory).child(title).setValue(newData.toDictionary)
        default:
            return
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // 화면의 다른 곳을 선택하면, 키보드 내려가도록. (ViewController의 메소드)
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        disableField()
    }
    
    func disableField() {
        titleField.resignFirstResponder()
        memoField.resignFirstResponder()
        isTitle = false
        isMemo = false
    }
    
    // 키보드가 올라오면 받는 노티피케이션으로부터 호출됨.
    @objc func keyboardWillShow(_ noti: Notification){
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if isTitle {
                self.view.frame.origin.y = Constant.movingViewOrigin
            }else if isMemo {
                self.view.frame.origin.y = -keyboardHeight
            }
        }else{
            return
        }
    }
    
    @objc func keyboardWillHide(_ noti: Notification){
        self.view.frame.origin.y = 0
    }
    
}

// Textfield delegate
extension AddViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isTitle = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isTitle = false
        
        return true
    }
}

extension AddViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        isMemo = true
        
        return true
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
            
            // imagepicker에서 선택한 사진을 넣어주기
            image = selectedImage
            
            thumbnailState = .photo
        }
        
        imageAddButton.isHidden = true
        isFilledImg = true
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
        
        thumbnail = url
        thumbnailState = .web
        
        DispatchQueue.global().async {
            
            let imgData = requestImgData(url: url)
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imgData)
                self.imageAddButton.isHidden = true
                self.isFilledImg = true
            }
        }
    }
}

// Catecory Picker View 설정
extension AddViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func configPickerView() {
        customPickerView = UIPickerView()
        
        customPickerView?.dataSource = self
        customPickerView?.delegate = self
        
        // component에서 보여줄 초기값
        customPickerView?.selectRow(0, inComponent: 0, animated: true)
        
        selectedCatecoryIndex = 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Catecory.shared.catecoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Catecory.shared.catecoryList[row]
    }
    
    // 각 row의 높이 설정
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Constant.pickerRowHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCatecoryIndex = row
    }
}
