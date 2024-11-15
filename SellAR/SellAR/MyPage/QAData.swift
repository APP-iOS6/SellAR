//
//  QAData.swift
//  SellAR
//
//  Created by 배문성 on 11/15/24.
//

import Foundation

struct QA: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
    let category: String
}
// QA 데이터 양식
//QA(question: "",
//   answer: "",
//   category: "AR지원", "회원관리", "게시물", "등록")


class QADataManager {
    static let shared = QADataManager()
    
    let qaData: [QA] = [
        QA(question: "안드로이드 단말기로 사용이 가능한가요?",
           answer: "iPhone, iPad의 스캐너 기능을 사용하기 때문에 안드로이드는 SellAR에서 지원이 불가능합니다. USDZ를 다른 방법으로 만드신 뒤에 올리는 것은 가능합니다.",
           category: "AR지원"),
        
        QA(question: "아이폰을 사용하는데 USDZ캡처가 안되요.",
           answer: "SellAR의 USDZ 캡쳐는 LIDAR센서가 탑재된 기종에서만 동작합니다. (iPhone 13 이상의 Pro 기종, iPad Pro 11, 12.9) 단 캡쳐된 USDZ를 배치해보는 기능은 모든 기종에서 가능합니다.",
           category: "AR지원"),
        
        QA(question: "회원 탈퇴는 어떻게 하나요?",
           answer: "현재 준비중인 기능입니다.",
           category: "회원관리"),
        
        QA(question: "닉네임과 프로필사진 수정은 어떻게하나요?",
           answer: "프로필수정 탭에서 변경가능합니다 마이페이지 > 우측상단 수정버튼 > 프로필수정 > 저장하기",
           category: "회원관리"),
        
        QA(question: "게시물에는 어떤 기능이 있나요?",
           answer: "USDZ파일이 있는 게시물의 경우 우측하단 AR마크가 있습니다 이 외에도 일반사진, 상품설명, 판매자에게 채팅, 부적절한 게시물 신고기능 등이 있습니다.",
           category: "게시물"),
        
        QA(question: "AR을 지원하는 게시물을 이용하는 방법이 어떻게 되나요?",
           answer: "게시물을 최하단으로 내리면 'AR로 보기'버튼이 있습니다. 이 버튼을 누르시면 이용가능합니다.",
           category: "게시물"),
        
        QA(question: "AR캡쳐 기능을 이용해서 게시물을 등록하려는데 캡쳐가 잘 안되요",
           answer: "AR캡처 기능은 넓은 공간에서 진행해주세요. 좁은 공간에서 진행하실경우 공간이 부족하여 캡처진행에 어려움이 있습니다.",
           category: "등록"),
        
        QA(question: "등록한 USDZ파일은 어디에있나요?",
           answer: "사용하시는 단말기의 파일탭에서 찾으실 수 있습니다.",
           category: "등록")
    ]
    
    private init() {}
}
