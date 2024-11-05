//
//  ItemEditView.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//

import SwiftUI
import FirebaseFirestore

struct ItemEditView: View {
    @Binding var selectedItem: Item?
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var textFocused: Bool
    @State private var description: String = ""

    
    let placeholder: String = "글을 입력해 주세요."
    
    let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("게시글 수정")
                    .font(.title3)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                
                // 아이템의 썸네일 이미지 표시
                if let item = selectedItem {
                    AsyncImage(url: URL(string: item.thumbnailLink)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 150)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                        case .failure:
                            Image("placeholder")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        Button(action: {
                            
                        }) {
                            Text("촬영하기")
                            Image(systemName: "camera")
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 100, height: 45)
                        .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Text("올리기")
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 100, height: 45)
                        .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Text("이미지")
                            Image(systemName: "photo")
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 100, height: 45)
                        .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                    .padding(.top, 10)
                    
                    
                    HStack {
                        // 아이템의 제목, 설명, 가격을 수정할 수 있는 필드
                        TextField("제목을 입력해 주세요", text: Binding(
                            get: { item.title },
                            set: { selectedItem?.title = $0 }
                        ))
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .textFieldStyle(.plain)
                        .focused($textFocused)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        
                        Button(action: {
                            print("123")
                        }) {
                            Text("지역설정")
                            Image(systemName: "map")
                        }
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .frame(width: 100, height: 45)
                        .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                    .padding(.top, 10)
                    
                    
                    TextEditor(text: $description)
                        .onChange(of: description) { newValue in
                            selectedItem?.description = newValue
                        }
                    .frame(width: .infinity, height: 220)
                    .padding(.leading, 5)
                    .cornerRadius(10)
                    .focused($textFocused)
                    .overlay {
                        if description.isEmpty {
                            Text(placeholder)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    }
                    .padding(.top, 10)
                    
                    HStack {
                        TextField("가격을 입력해 주세요", text: Binding(
                            get: { String(item.price) },
                            set: { selectedItem?.price = Double($0) ?? item.price }
                        ))
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .focused($textFocused)
                        .textFieldStyle(.plain)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .keyboardType(.numberPad)
                        
                        
                        Button(action: {
                            if let item = selectedItem {
                                // Firestore 문서의 ID를 사용하여 업데이트
                                db.collection("items").document(item.id).updateData([
                                    "title": item.title,
                                    "description": item.description,
                                    "price": item.price,
                                    // 필요한 경우 다른 필드도 추가
                                ]) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        print("Document successfully updated")
                                        // 성공적으로 수정된 후 다른 행동 추가 (예: dismiss)
                                    }
                                }
                            }
                        }) {
                            Text("수정")
                                .foregroundColor(colorScheme == .dark ? Color.black : Color.black)
                        }
                        .frame(width: 100, height: 45)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                    }
                    .padding(.top, 10)
                    .onAppear {
                        description = item.description ?? ""
                    }
                }
                
                Spacer()
                
            }
            
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                textFocused = false
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("완료") {
                            textFocused = false
                        }
                    }
                }
            }
        }
    }
}
