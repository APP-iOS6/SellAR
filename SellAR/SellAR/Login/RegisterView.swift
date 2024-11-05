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
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                GeometryReader{ geometry in
                    VStack (spacing: 20) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.16)
                            .foregroundColor(.white)
                            .padding(.top, 5)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                            TextField("이메일을 입력해 주세요", text: $email)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            Text("비밀번호")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                            SecureField("비밀번호를 입력해 주세요", text: $password)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            
                            Text("비밀번호 확인")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                            SecureField("비밀번호를 똑같이 입력해 주세요", text: $confinPassword)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            
                            Text("닉네임")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 20)
                            TextField("닉네임을 입력해 주세요", text: $userName)
                                .padding()
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.height / 20)
                                .background(.white)
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 40)
                            HStack {
                                Spacer()
                                Button(action: {
                                    if password == confinPassword { viewModel.registerWithEmailPassword(email: email, password: password, username: userName, profileImage: profileImage)
                                    } else {
                                        alertMessage = "비밀번호가 일치하지 않습니다."
                                        showAlert = true
                                    }
                                }){
                                    Text("가입완료")
                                }
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.height / 50)
                                .padding()
                                .foregroundColor(.white)
                                .background(.gray)
                                .cornerRadius(10)
                                
                                Spacer()
                            }
                            .padding(.bottom, 40)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("경고"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
                            }
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    RegisterView()
}
