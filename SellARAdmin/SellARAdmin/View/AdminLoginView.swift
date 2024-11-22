//
//  Untitled.swift
//  SellARAdmin
//
//  Created by 박범규 on 11/22/24.
//
import SwiftUI
import Firebase
import FirebaseAuth


struct AdminLoginView: View {
    @StateObject private var authViewModel = AdminAuthViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("관리자 로그인")
                    .font(.title)
                    .padding(.bottom, 30)
                
                TextField("이메일", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("비밀번호", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}
