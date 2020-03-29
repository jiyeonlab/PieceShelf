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
    
    let sections = ["카테고리 추가 및 삭제"]
    
    var ref: DatabaseReference!
    var catecory: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        // Firebase DB 참조
        ref = Database.database().reference()
        
        readCatecoryList()
    }
    
    // firebase db에서 카테고리 종류 불러오기
    func readCatecoryList() {
        ref.child("UserData").observeSingleEvent(of: .value) { (snapshot) in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.catecory.append(key)
            }
            print("카테고리 목록 === \(self.catecory)")
            self.tableView.reloadData()
        }
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
        let empty = UserData(thumbnail: "", date: "", memo: "")
        guard let newCatecory = catecory.last else { return }
        ref.child("UserData").child(newCatecory).updateChildValues(["Default": empty.toDictionary])
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
        
        catecoryCell.textLabel?.text = "\(catecory[indexPath.row])"
       
        return catecoryCell
    }
    
    
}
