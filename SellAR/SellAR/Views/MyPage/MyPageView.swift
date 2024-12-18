//
//  MyPageView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//

import SwiftUI
import FirebaseAuth

struct MyPageView: View {
    
    @ObservedObject var itemStore = ItemStore()
    @EnvironmentObject var loginViewModel: LoginViewModel

    @StateObject private var userDataManager = UserDataManager()
    @State private var isLoading = true // 프로필 사진 불러오는 중 프로그래스뷰
    @State private var isProcessing = false // 로그아웃,회원탈퇴 얼럿 작업중 프로그래스뷰 관련
    @Environment(\.colorScheme) var colorScheme // 다크모드:라이트모드 관련
    @State private var showingLogoutAlert = false // 로그아웃 얼럿
    @State private var showingToast = false // 로그아웃 얼럿 토스트메세지
    @State private var showingDeleteAlert = false // 계정삭제 얼럿
    @State private var showingDeleteToast = false // 계정삭제 토스트메세지
    @State private var showingDeleteFailToast = false // 계정삭제 실패 토스트메세지
    
    var body: some View {
        ZStack {
            // 다크모드 : 라이트모드 순서
            //            Color(colorScheme == .dark ? Color.black : Color(red: 219 / 255,green: 219 / 255, blue: 219 / 255)).edgesIgnoringSafeArea(.all)
            Color(colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            
            
            VStack(spacing: 0) {
                HStack {
                    //                Button(action: {
                    //                    //버튼기능 추가예정
                    //                }) {
                    //                    Image(systemName: "chevron.left")
                    //                        .resizable()
                    //                        .frame(width: 11, height: 22)
                    //                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                        .foregroundColor(.gray)
                    //                }
                    //                .buttonStyle(PlainButtonStyle())
                    
                    if userDataManager.currentUser != nil {
                        
                        Spacer()
                            .frame(maxWidth: .infinity, alignment: .leading) // 뒤로가기 버튼 대신한 여백생성으로 가운데 정렬
                        
                        Text("마이페이지")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰색:검정
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        //프로필 수정버튼
                        NavigationLink(destination: ProfileFixView(userDataManager: userDataManager)) {
                            Image(systemName: "square.and.pencil" )
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //연파랑
                                .padding(.leading, 3)
                                .padding(.bottom, 3)
                                .frame(width: 33, height: 33)
                                .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                                .overlay(Circle().stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255)))
                                .clipShape(Circle())
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Spacer()
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 5)
                
                if isLoading {
                    ProgressView()
                } else if let user = userDataManager.currentUser {
                    loggedInView(user: user)
                } else {
                    loggedOutView
                }
            }
            .padding(10)
            
            if showingToast {
                ToastView(message: "로그아웃 되었습니다.", isShowing: $showingToast)
            }
            
            if showingDeleteToast {
                ToastView(message: "회원탈퇴신청이 정상적으로 접수되었습니다.", isShowing: $showingDeleteToast)
            }
            
            if showingDeleteFailToast {
                ToastView(message: "회원탈퇴 중 오류가 발생했습니다.", isShowing: $showingDeleteFailToast)
            }
            
            if isProcessing {
                Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
            .navigationTitle("")
            .navigationBarHidden(true) // 상단여백제거
            .navigationBarBackButtonHidden(true) //네비게이션 시스템 백 버튼 젝
            .onAppear {
                userDataManager.fetchCurrentUser { _ in
                    isLoading = false
                }
            }
        }
    @ViewBuilder
    func loggedInView(user: User) -> some View {
        ScrollView {
            Spacer()
                .frame(height: 30)
            VStack(alignment: .center, spacing: 20) {
                // 프로필 사진
                if let imageUrl = user.profileImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 135, height: 135)
                                .clipShape(Circle())
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 135, height: 135)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 135, height: 135)
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //연파랑
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(40)
                        .frame(width: 135, height: 135)
                        .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                    
                }
                // 닉네임 및 이메일
                //                VStack(alignment: .center, spacing: 10) {
                //                    Text("이름")
                //                        .font(.headline)
                //                        .foregroundColor(colorScheme == .dark ?
                //                        Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255)) // 흐린흰색:검정
                //                        .frame(maxWidth: .infinity, alignment: .leading)
                // 이름
                HStack {
                    Image(systemName: "person.text.rectangle")
                        .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                        .padding(.trailing, 6)
                    Text(user.username)
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .frame(maxWidth:.infinity, alignment: .leading)
                }
                .padding(10) // 검정칸 크기
                .frame(maxWidth: 130, alignment: .leading)
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                
                
                // 게시물 및 계정 관리 버튼들
                VStack(spacing: 0) {
                    Text("글")
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                    
                    NavigationLink(destination: ItemListView(itemStore: itemStore)) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                            Spacer()
                                .frame(width: 10)
                            Text("내 글 목록")
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                    
                    Text("계정")
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                    
                    Button(action: {
                        showingLogoutAlert = true
                        //                        loginViewModel.logout()
                        //                        userDataManager.currentUser = nil
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                            Spacer()
                                .frame(width: 10)
                            Text("로그아웃")
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                                .padding(.leading, 1)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                        .cornerRadius(10)
                    }
                    .alert(isPresented: $showingLogoutAlert) {
                        Alert(
                            title: Text("로그아웃"),
                            message: Text("로그아웃 하시겠습니까?"),
                            primaryButton: .destructive(Text("예")) {
                                isProcessing = true // 프로그래스뷰 표기
                                loginViewModel.logout()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //1초지연
                                    isProcessing = false
                                    userDataManager.currentUser = nil
                                    showingToast = true
                                }
                            },
                            secondaryButton: .cancel(Text("아니오"))
                        )
                    }
                    NavigationLink(destination: ContentView(viewModel: loginViewModel).navigationBarBackButtonHidden(true), isActive: $loginViewModel.isMainViewActive) {
                        EmptyView()
                    }
                    
                    Spacer()
                        .frame(height: 8) // 버튼사이간격
                    
                    Button(action: {
                        // 회원 탈퇴 액션
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "person.fill.xmark")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                            Spacer()
                                .frame(width: 7)
                            Text("회원 탈퇴")
                                .foregroundColor(Color.red)
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                        .cornerRadius(10)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("회원탈퇴"),
                            message: Text("회원탈퇴시 번복 할 수 없습니다.\n정말로 진행하시겠습니까?"),
                            primaryButton: .destructive(Text("예")){
                                loginViewModel.deleteAccount { success, message in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isProcessing = false
                                        if success {
                                            userDataManager.currentUser = nil
                                            showingDeleteToast = true
                                        } else {
                                            showingDeleteFailToast = true
                                        }
                                    }
                                }
                            },
                            secondaryButton: .cancel(Text("아니오"))
                        )
                    }
                    .padding(.bottom, 20)
                    
                    Text("지원")
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 5)
                    
                    //                    NavigationLink(destination: ProvisionView()) {
                    //                        HStack {
                    //                            Image(systemName: "text.document")
                    //                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                    //                            Spacer()
                    //                                .frame(width: 10)
                    //                            Text("약관")
                    //                                .font(.system(size: 14))
                    //                                .fontWeight(.bold)
                    //                            Spacer()
                    //                            Image(systemName: "chevron.right")
                    //                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                    //                        }
                    //                        .padding(15)
                    //                        .foregroundColor(Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255))
                    //                        .background(.white)
                    //                        .cornerRadius(10)
                    //                    }
                    //                    .padding(.bottom, 6)
                    //
                    NavigationLink(destination: QAView()) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                            Spacer()
                                .frame(width: 10)
                            Text("자주묻는 질문")
                                .font(.system(size: 15))
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding(15) //검정칸 크기
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10) // 좌우 리스트값 변경시도
            .navigationTitle("")
            .navigationBarHidden(true) // 상단여백제거
        }
    }
//로그아웃되었을때 보여주는 뷰
    var loggedOutView: some View {
        ZStack {
            VStack(alignment: .center, spacing: 20) {
                
                Image(colorScheme == .dark ? "SellarLogoDark" : "SellarLogoWhite")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .padding()
                    .padding(.bottom,10)
                
                Text("로그인이 필요합니다.")
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흐린흰색:검정
                    .padding(.bottom,30)
                    .bold()
                
                NavigationLink(destination: LoginView()) {
                    Text("로그인하기")
                        .frame(width: 150, height: 50)
                        .padding(2)
                        .foregroundColor(Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) // 흐린흰색
                        .background(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) //진파랑
                        .cornerRadius(10)
                        .bold()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

//토스트 메세지

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red : 219 / 255, green: 219 / 255, blue: 219 / 255))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .cornerRadius(10)
                .transition(.move(edge: .bottom))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
        }
        .padding(.bottom, 20)
        .animation(.easeInOut)
        .transition(.move(edge: .bottom))
    }
}
