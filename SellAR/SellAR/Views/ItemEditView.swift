//
//  ItemEditView.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//

import SwiftUI

struct ItemEditView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var titleTextField: String
    @State var textEditor: String
    @State var priceTextField: String
    @FocusState private var textFocused: Bool
    
    let placeholder: String = "글을 입력해 주세요."

    var body: some View {
        VStack{
            Text("게시글 수정")
                .font(.title3)
                .bold()
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

            
            Image("macbook")
                .resizable()
                .clipped()
                .frame(width: 250, height: 220)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                .padding(.top, 10)
                
            HStack {
                Button(action: {
                    
                }) {
                    Text("촬영하기")
                    Image(systemName: "camera")
                    
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 100, height: 45)
                .background(Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("올리기")
                    Image(systemName: "square.and.arrow.up")
                    
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 100, height: 45)
                .background(Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("이미지")
                    Image(systemName: "photo")
                    
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 100, height: 45)
                .background(Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .padding(.top, 10)
            
            HStack {
                TextField("제목을 입력해 주새요", text: $titleTextField)
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .textFieldStyle(.plain)
                    .focused($textFocused)
                    .padding(.vertical, 10)
                    .padding(.leading, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("지역설정")
                    Image(systemName: "map")
                    
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 100, height: 45)
                .background(Color.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .padding(.top, 10)
            
            TextEditor(text: $textEditor)
                .frame(width: .infinity, height: 220)
                .cornerRadius(10)
                .focused($textFocused)
                .overlay {
                    Text(placeholder)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                }
                .padding(.top, 10)
            
            
            HStack {
                TextField("가격을 입력해 주세요.", text: $priceTextField)
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .textFieldStyle(.plain)
                    .focused($textFocused)
                    .padding(.vertical, 10)
                    .padding(.leading, 10)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                
                Button(action: {
                    
                }) {
                    Text("등록")
                }
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .frame(width: 100, height: 45)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .padding(.top, 10)
                
            Spacer()
        }
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
        .padding(.horizontal, 16)
    }
}
