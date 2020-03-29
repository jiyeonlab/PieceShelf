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
}

// AddVC에서 저장할 이미지가 웹에서 가져온 것인지 카메라롤에서 가져온 것인지 구분
enum ThumbnailState {
    case web
    case photo
}
