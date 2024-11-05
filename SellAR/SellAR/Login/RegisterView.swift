//
//  RegisterView.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confinPassword = ""
    @State private var userName = ""
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                GeometryReader{ geometry in
                    /// 이메일 비밀번호 로그인
                    VStack (spacing: 20) {
                        Text("이메일")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("이메일을 입력해 주세요", text: $email)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        Text("비밀번호")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        SecureField("비밀번호를 입력해 주세요", text: $password)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        Text("비밀번호 확인")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        SecureField("비밀번호를 똑같이 입력해 주세요", text: $password)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                        Text("닉네임")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("닉네임을 입력해 주세요", text: $userName)
                            .padding()
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                            .padding(.bottom,20 )
                        
                        // 로그인 회원가입 버튼
                            Button(action: {
                                viewModel.registerWithEmailPassword(email: email, password: password, username: userName, profileImage: profileImage)
                            }){
                                Text("가입완료")
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height / 50)
                            .padding()
                            .foregroundColor(.white)
                            .background(.gray)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
