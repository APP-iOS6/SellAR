//
//  ItemEditView.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//
// 내 상품 게시글을 수정하는 뷰
import SwiftUI
import FirebaseFirestore

struct ItemEditView: View {
    enum KeyboardDone: Hashable {
        case text
    }
    
    @Binding var selectedItem: Item?
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var textFocused: KeyboardDone?
    @State private var description: String = ""
    
    let placeholder: String = "내용을 입력해 주세요."
    
    let db = Firestore.firestore()
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ScrollView {
            VStack {
                Text("게시글 수정")
                    .font(.title3)
                    .bold()
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                HStack {
                    Button(action: {
                        // Dismiss the view
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                    Spacer()
                }
                .padding(.top, 10)
                
                // 아이템의 썸네일 이미지 표시
                if let item = selectedItem {
                    AsyncImage(url: URL(string: item.thumbnailLink ?? "")) { phase in
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
                            textFocused = nil
                        }) {
                            Text("촬영하기")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(systemName: "camera")
                                .foregroundColor(Color.cyan)
                        }
                        
                        
                        Divider()
                        
                        Button(action: {
                            textFocused = nil
                        }) {
                            Text("올리기")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(Color.cyan)

                        }
                       
                        
                        Divider()

                        Button(action: {
                            textFocused = nil
                        }) {
                            Text("이미지")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(systemName: "photo")
                                .foregroundColor(Color.cyan)
                        }
                        
                        
                        Divider()

                        Button(action: {
                            print("123")
                        }) {
                            Text("지역설정")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Image(systemName: "map")
                                .foregroundColor(Color.cyan)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                    .cornerRadius(8)
                    .padding(.top, 10)
//                    .padding(.horizontal, 16)
                    
                    VStack {
                    HStack {
                        Text("제목")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.leading, 5)
                        
                        // 아이템의 제목, 설명, 가격을 수정할 수 있는 필드
                        TextField("제목을 입력해 주세요", text: Binding(
                            get: { item.title },
                            set: { selectedItem?.title = $0 }
                        ))
                        .frame(maxWidth: .infinity, maxHeight: 25)
                        .textFieldStyle(.plain)
                        .focused($textFocused, equals: .text)
                        .padding(.vertical, 5)
                        .padding(.leading, 10)
                        .cornerRadius(10)
                        

                    }
                    .padding(.top, 10)
                    
                        Divider()
                    
                    TextEditor(text: $description)
                        .onChange(of: description) { newValue in
                            selectedItem?.description = newValue
                        }
                        .frame(width: .infinity, height: 220)
                        .focused($textFocused, equals: .text)
                        .overlay {
                            if description.isEmpty {
                                Text(placeholder)
                                    .foregroundColor(Color(.systemGray4))
                            }
                        }
                        .scrollContentBackground(.hidden)
                        
                        Divider()
                        
                        HStack {
                            HStack {
                                Text("가격")
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.leading, 5)
                                
                                TextField("가격을 입력해 주세요", text: Binding(
                                    get: { String(item.price) },
                                    set: { selectedItem?.price = ($0) }
                                ))
                                
                                
                                Text("원")
                                    .padding(.trailing, 5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: 25)
                            .focused($textFocused, equals: .text)
                            .textFieldStyle(.plain)
                            .padding(.vertical, 10)
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
                            .background(Color.cyan)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color.gray : Color.white) // 배경색을 다르게 설정
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .padding(.top, 10)
                    
                    .onAppear {
                        description = item.description
                    }
                }
                
                Spacer()
                
            }
            
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                textFocused = nil
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("완료") {
                            textFocused = nil
                        }
                    }
                }
            }
        }
    }
}
