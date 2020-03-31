//
//  Catecory.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/29.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation
import Firebase

class Catecory {
    static let shared = Catecory()
    
    var catecoryList: [String] = []
    
    func observeCatecory() {
        
        Database.database().reference().child("UserData").observe(.value) { snapshot in
            
            self.catecoryList.removeAll()
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.catecoryList.append(key)
            }
            self.catecoryList = self.removeDuplication(in: self.catecoryList)
            print("리스트에 변화가 있음 \(self.catecoryList)")
            NotificationCenter.default.post(name: LoadCatecoryListNotification, object: self)
        }
    }
    
    // 혹시 중복되는 값을 제거하기 위함
    func removeDuplication(in array: [String]) -> [String] {
        let set = Set(array)
        var newArray = Array(set)
        
        newArray.sort(by: < )
        
        return newArray
    }
    
    private init() {}
}


