//
//  SettingViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/29.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let sections = ["카테고리 추가 및 삭제"]
    
    var ref: DatabaseReference!
    var catecory: [String] = []
    
    var editingMode = false
    
    override func viewDidLoad() {
        print("셋팅 뷰 did load")
        super.viewDidLoad()

        tableView.dataSource = self
        
        // Firebase DB 참조
        ref = Database.database().reference()
        
        readCatecoryList()
        
        // 혹시, load 된 후에 Catecory List가 다 받아지면 노티 받기 위함.
        NotificationCenter.default.addObserver(self, selector: #selector(showCatecory(_:)), name: LoadCatecoryListNotification, object: nil)
    }
    
    @objc func showCatecory(_ noti: Notification) {
        readCatecoryList()
    }

    // firebase db에서 카테고리 종류 불러오기
    func readCatecoryList() {
        catecory = Catecory.shared.catecoryList
        self.tableView.reloadData()
    }
    
    // 카테고리 추가하기 버튼
    @IBAction func addCatecory(_ sender: Any) {
        let alert = UIAlertController(title: "카테고리 추가", message: "추가하고 싶은 항목을 입력하세요 :)", preferredStyle: .alert)
        
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "완료", style: .default, handler: { ok in
            guard let newCatecory = alert.textFields?.first?.text else {
                return
            }
            
            if !self.catecory.contains(newCatecory) {
                // 새로 추가한 카테고리 띄우기
                self.catecory.append(newCatecory)
                self.tableView.reloadData()
                self.uploadCatecory()
            }else{
                // 이미 있는 항목이라 추가할 수 없다는 메시지 띄우기
                let alert = UIAlertController(title: "이미 있는 카테고리입니다!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        }))
        
        present(alert, animated: true)
    }
    
    // 새롭게 추가한 카테고리 항목을 Firebase에 업데이트
    func uploadCatecory(){
        // TODO: 빈 딕셔너리를 추가하는게 맞는걸까?
//        let empty = UserData(thumbnail: "", date: "", memo: "")
        let empty = UserData(title: "Default", thumbnail: "", date: "", memo: "")
        guard let newCatecory = catecory.last else { return }
        ref.child("UserData").child(newCatecory).child("Default").updateChildValues(empty.toDictionary)
    }
    
    // Firebase에서 해당 카테고리 삭제하기
    func deleteCatecory(what catecory: String) {
        ref.child("UserData").child(catecory).removeValue()
        readCatecoryList()
    }
    
    // 카테고리 편집하기
    @IBAction func editCatecory(_ sender: Any) {
        if !editingMode {
            editingMode = !editingMode
            addButton.isEnabled = false
            editButton.title = "완료"
            tableView.setEditing(true, animated: true)
        }else{
            editingMode = !editingMode
            addButton.isEnabled = true
            editButton.title = "편집"
            tableView.setEditing(false, animated: true)
        }
       
    }
}

extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catecory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let catecoryCell = tableView.dequeueReusableCell(withIdentifier: CatecoryTableViewCell.identifier, for: indexPath)
        
        print("!!!!!!!! \(indexPath.row)")
        catecoryCell.textLabel?.text = "\(catecory[indexPath.row])"
       
        return catecoryCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // 편집 모드에서 왼쪽 버튼을 누를 경우, 테이블에서 삭제하고, 애니메이션까지 보여줌.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteCatecory(what: catecory[indexPath.row])
            catecory.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}
