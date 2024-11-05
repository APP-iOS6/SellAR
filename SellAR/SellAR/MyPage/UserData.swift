//
//  UserData.swift
//  SellAR
//
//  Created by 배문성 on 11/5/24.
//

import Foundation

struct UserData: Identifiable {
    var id: String
    var email: String
    var username: String
    var profileImageUrl: String?
    var userLocation: String
    var intro: String
    
}
// 충돌 대비하여 임시 데이터파일 생성 유저탭에서 수정이된다면 삭제되어도 무방함
