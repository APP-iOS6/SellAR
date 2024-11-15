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
            Color(colorScheme == .dark ?
                  Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255) : Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255))
            .edgesIgnoringSafeArea(.all)
            
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
                                .foregroundColor(colorScheme == .dark ? Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255) : Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("자주묻는 질문")
                            .foregroundColor(colorScheme == .dark ?
                                             Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흰색:검정
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
                                    .foregroundColor(Color.black)
                            }
                            .frame(maxWidth : .infinity, alignment: .center)
                            .padding(.vertical, 10)
                            .background(selectedCategory == category ?
                                Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255) : // 선택한 버튼 색상
                                Color(red:243 / 255, green: 242 / 255, blue: 248 / 255)   // 선택안한 버튼 색상
                            )
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
                            VStack(spacing: 20) {
                                ForEach(filteredQA) { qa in
                                    QAItem(question: qa.question, answer: qa.answer)
                                }
                            }
                            .padding(.horizontal, 10)
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
            let question: String
            let answer: String
            
            var body: some View {
                VStack(alignment: .leading) {
                    Text("Q. \(question)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.black)
                        .padding(.bottom, 10)
                    
                    Text("A. \(answer)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.black)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255))
                .cornerRadius(10)
            }
        }
