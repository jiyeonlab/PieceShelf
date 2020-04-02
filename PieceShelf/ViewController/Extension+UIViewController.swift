//
//  Extension+UIViewController.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/04/03.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import Foundation

/// url값을 받아, Data형태로 넘기는 메소드
func requestImgData(url: String) -> Data {
    guard let thumbnailURL = URL(string: url) else {
        return Data()
    }
    guard let thumbnail = try? Data(contentsOf: thumbnailURL) else {
        return Data()
    }
    
    return thumbnail
}
