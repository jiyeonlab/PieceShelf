//
//  GlobalConstant.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

struct Constant {
    static let imageViewHeightRatio: CGFloat = 2.5
    static let datePickerHeight: CGFloat = 200.0
    static let catecoryPickerHeight: CGFloat = 150.0
    static let pickerRowHeight: CGFloat = 40.0
    static let cellSpacing: CGFloat = 2
    static let itemsRatio: CGFloat = 1.5
}

// AddVC에서 저장할 이미지가 웹에서 가져온 것인지 카메라롤에서 가져온 것인지 구분
enum ThumbnailState {
    case web
    case photo
}

// DB로부터 카테고리 항목 리스트를 다 불러왔을 때 보내는 noti 이름
let LoadCatecoryListNotification = Notification.Name("LoadCatecoryList")
