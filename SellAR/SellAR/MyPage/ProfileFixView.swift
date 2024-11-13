//
//  ProfileFixView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//
import SwiftUI

struct ProfileFixView: View {
    
//    @State private var id: String = UUID().uuidString
//    @State private var email: String = "aaaaaa@gmail.com"
//    @State private var username: String = "가나다"
//    @State private var profileImageUrl: String = "image"
//    @State private var intro: String = "자신을 소개해주세요."
//    @State private var userLocation: String = "서울시 강남구"
    @State private var isLoggedIn: Bool = false //로그인상태 확인변수,예정
    @State private var selectedImage: UIImage? // 이미지 선택
    
    //let userdata: UserData
    private func showPhotoPicker() {
    }

    private func saveChange() {
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("프로필 수정")
                        .font(.headline)
                        .padding(.bottom ,15)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center, spacing: 20) {
                        // 프로필 사진
                        Image(systemName: "camera.fill")
                        //Image("userdata.profileImageUrl")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(30)
                            .frame(width: 135, height: 135)
                            .foregroundColor(.gray)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                        
                        // 닉네임 및 이메일
                        VStack(alignment: .leading, spacing: 10) {
                            Text("이름")
                                .font(.system(size: 20))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                TextField("", text: username)
                            }
                            .padding(10)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .padding(.bottom, 20)
                        Spacer()
                        
                        Button(action: saveChange) {
                            Text("저장하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.white)
                                .cornerRadius(10)
                            
                        }
                        //Spacer()
                    }
                }
                .padding(10)
            }
        }
    }
}
                    //                    VStack(alignment: .leading, spacing: 10) {
                    //                        VStack(alignment: .center, spacing: 20) {
                    //                            // 프로필 사진
                    //                            VStack(spacing: 10) {
                    //                                if let selectedImage = selectedImage {
                    //                                    Image(uiImage: selectedImage)
                    //                                        .resizable()
                    //                                        .aspectRatio(contentMode: .fill)
                    //                                        .frame(width: 120, height: 120)
                    //                                        .clipShape(Circle())
                    //                                        .onTapGesture { showPhotoPicker() }
                    //                                } else {
                    //                                    Image(systemName: "camera.fill")
                    //                                    //Image("userdata.profileImageUrl")
                    //                                        .resizable()
                    //                                        .aspectRatio(contentMode: .fit)
                    //                                        .padding(30)
                    //                                        .frame(width: 120, height: 120)
                    //                                        .foregroundColor(.gray)
                    //                                        .background(Color.white.opacity(0.1))
                    //                                        .clipShape(Circle())
                    //                                        .onTapGesture { showPhotoPicker() }
                    //                                }
                    //                            }
                    //
                    //                            // 닉네임 및 이메일
                    //                            VStack(alignment: .leading, spacing: 10) {
                    //                                HStack {
                    //                                    Text("닉네임")
                    //                                        .font(.system(size: 15))
                    //                                        .foregroundColor(.white)
                    //                                    Spacer()
                    //                                    TextField("", text: $username)
                    //                                        .background(Color.gray.opacity(0.01))
                    //                                        .foregroundColor(.white)
                    //                                        .cornerRadius(10)
                    //                                        .lineLimit(1)
                    //                                        .font(.system(size: 14))
                    //                                }
                    //                                .padding(10)
                    //                                .background(Color.gray.opacity(0.2))
                    //                                .cornerRadius(10)
                    //
                    //
                    //                            }
                    //                        }
                    //                        .padding()
                    //
                    //                        VStack {
                    //
                    //                            // 자기소개 구문 (텍스트만 출력하는 형태로 변경)
                    //                            TextField("",text: $intro)
                    //                                .frame(maxWidth: .infinity, maxHeight: 150, alignment: .topLeading)  // 좌측 정렬
                    //                                .padding()
                    //                                .background(Color.gray.opacity(0.2))
                    //                                .cornerRadius(10)
                    //                                .foregroundColor(.white)
                    //                        }
                    //                        .padding(.bottom, 20)
                    //
                    //                        Button(action: saveChange) {
                    //                            Text("저장하기")
                    //                                .frame(maxWidth: .infinity)
                    //                                .padding()
                    //                                .foregroundColor(.black)
                    //                                .background(Color.white)
                    //                                .cornerRadius(10)
                    


