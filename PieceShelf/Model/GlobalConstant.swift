//
//  GlobalConstant.swift
//  PieceShelf
//
//  Created by JiyeonKim on 2020/03/28.
//  Copyright © 2020 jiyeonlab. All rights reserved.
//

import UIKit

struct Constant {
    /// AddVC의 imageView 높이 조정 변수
    static let imageViewHeightRatio: CGFloat = 2.5
    
    /// ItemVC의 imageView 높이
    static let itemHeightRatio: CGFloat = 1.6
    
    /// AddVC의 + 버튼의 높이 조정 변수
    static let plusButtonHeightRatio: CGFloat = 2
    static let datePickerHeight: CGFloat = 200.0
    static let catecoryPickerHeight: CGFloat = 150.0
    static let pickerRowHeight: CGFloat = 40.0
    static let cellSpacing: CGFloat = 2
    static let itemsRatio: CGFloat = 1.5
    
    /// Keyboard 올라왔을 때, view의 높이조정
    static let movingViewOrigin: CGFloat = -10
    
    /// 한 row에 보여줄 CollectionCell의 갯수
    static let itemsPerRows: CGFloat = 3
    
    /// DetailVC에서 collection cell의 width
    static let detailCellWidth: CGFloat = Constant.cellSpacing * 2
}

// AddVC에서 저장할 이미지가 웹에서 가져온 것인지 카메라롤에서 가져온 것인지 구분
enum ThumbnailState {
    case web
    case photo
}

// DB로부터 카테고리 항목 리스트를 다 불러왔을 때 보내는 noti 이름
let LoadCatecoryListNotification = Notification.Name("LoadCatecoryList")
