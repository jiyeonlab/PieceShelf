//
//  Info.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

// Firebase DB에 저장할 데이터 타입
struct UserData {
    let thumbnail: String
    let date: String
    let memo: String
    
    var toDictionary: [String: Any] {
        let dict = ["Thumbnail": thumbnail, "Date": date, "Memo": memo]
        
        return dict
    }
}
