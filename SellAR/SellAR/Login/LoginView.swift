//
//  LoginView.swift
//  SellAR
//
//  Created by Mac on 11/1/24.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

struct LoginView: View {
    private var user = User()
    private var email = ""
    private var password = ""
    private var cofirmPassword = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text ("이메일")
                    .padding()
                TextField("이메일을 입력해 주세요", text: $email)
                    .padding()
                SecureField
                
            }
        }
    }
}
