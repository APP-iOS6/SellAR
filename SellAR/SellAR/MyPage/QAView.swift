//
//  Q&AView.swift
//  SellAR
//
//  Created by 배문성 on 11/15/24.
//
import SwiftUI

struct QAView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: String? = nil
    @State private var isLoading = false
    
// 카테고리 미선택해도 전체 게시물 다 보이는 경우
    var filteredQA: [QA] {
        if let category = selectedCategory {
            return QADataManager.shared.qaData.filter { $0.category == category }
        } else {
            return QADataManager.shared.qaData
        }
    }
// 카테고리 미선택시 안보이게 하는경우
//        guard let category = selectedCategory else {
//            return []  // 카테고리가 선택안한 상황
//        }
//        return QADataManager.shared.qaData.filter { $0.category == category }
//    }
    
    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            // 다크모드 : 라이트모드 순서 검정:밝은회색
            
                VStack(spacing:0) {
                    Spacer()
                        .frame(height: 15)
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName:"chevron.left")
                                .resizable()
                                .frame(width: 11, height: 22)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰색:검정
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("자주묻는 질문")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰:검
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 10)
                
                VStack(alignment: .center, spacing: 20) {
                    HStack {
                        ForEach(["AR지원", "회원관리", "게시물", "등록"], id: \.self) { category in
                            Button(action: {
                                if selectedCategory == category {
                                    selectedCategory = nil  // 이미 선택된 카테고리를 다시 누르면 선택 해제
                                } else {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                            }
                            .frame(maxWidth : .infinity, alignment: .center)
                            .foregroundColor(selectedCategory == category ?
                                (colorScheme == .dark ? Color.black : Color.white) : (colorScheme == .dark ? Color.white : Color.black))
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ?
                                (colorScheme == .dark ? // 선택한 버튼 색상 ( 다크모드 : 라이트모드)
                                    Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255) : Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255)):
                                (colorScheme == .dark ? // 선택안한 버튼 색상 ( 다크모드 : 라이트모드)
                                        Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255))
                            )
                            .overlay(RoundedRectangle(cornerRadius: 26.5)
                                .stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                            .cornerRadius(26.5)
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    //카테고리 미선택시 게시물 안보이게하는기능 추가시 수정
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredQA) { qa in
                                    QAItem(question: qa.question, answer: qa.answer)
                                }
                            }
                        }
                    }
                    // 여기까지
                    
// 카테고리 미선택시 게시물대신 문구 출력하는 코드
//                    if selectedCategory != nil {
//                        ScrollView {
//                            VStack(spacing: 20) {
//                                ForEach(filteredQA) { qa in
//                                    QAItem(question: qa.question, answer: qa.answer)
//                                }
//                            }
//                            .padding(.horizontal, 10)
//                        }
//                    } else {
//                        Text("카테고리를 선택해주세요")
//                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .padding(.horizontal, 10)
            .navigationBarTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
    }
}
        
struct QAItem: View {
    @Environment(\.colorScheme) var colorScheme
    
    let question: String
    let answer: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Q. \(question)")
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 10)
            HStack {
                Text("A.")
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                Text("\(answer.joined(separator: "\n"))")
                    .lineSpacing(3)
            }
            .font(.system(size: 12, weight: .bold))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
        .overlay(Rectangle().stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
    }
}
