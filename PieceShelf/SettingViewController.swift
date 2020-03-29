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
        
        readCatecory()
    }
    
    // firebase db에서 카테고리 종류 불러오기
    func readCatecory() {
//        let childCount = ref.child(fuid)
//        print("child 갯수 === \(childCount)")
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
