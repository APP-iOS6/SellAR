//
//  ProfileFixView.swift
//  SellAR
//
//  Created by 배문성 on 11/1/24.
//
import SwiftUI
import PhotosUI

struct ProfileFixView: View {
    @ObservedObject var userDataManager: UserDataManager
    @State private var username: String = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var isSaving = false
    
    init(userDataManager: UserDataManager) {
        self._userDataManager = ObservedObject(wrappedValue: userDataManager)
    }
    
    var body: some View {
            ZStack {
                Color(colorScheme == .dark ? Color.black : Color(red: 219 / 255,green: 219 / 255, blue: 219 / 255)).edgesIgnoringSafeArea(.all)
                // 다크모드 : 라이트모드 순서 검정:밝은회색
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName:"chevron.left")
                                .resizable()
                                .frame(width: 11, height: 22)
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰색:검정
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("프로필 수정")
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰색:검정
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.bottom, 20)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                        .frame(height: 30)
                    
                    VStack(alignment: .center, spacing: 20) {
                        // 프로필 사진
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            profileImage
                        }
                        
                        // 닉네임 및 이메일
//                            Text("이름")
//                                .font(.headline)
//                                .foregroundColor(colorScheme == .dark ?
//                                    Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255) : Color(red: 16 / 255, green: 16 / 255, blue: 17 / 255))//흐린흰색:검정
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                                    .padding(.trailing, 6)
                                TextField("", text: $username)
                                    .fontWeight(.bold)
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                                    .frame(maxWidth:.infinity, alignment: .leading)
                            }
                            .padding(15) // 검정칸 크기
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255), lineWidth: (1)))
                        
                        Spacer()
                        
                        Button(action: saveChange) {
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint:.white))
                            } else {
                                Text("저장하기")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(Color(red: 243 / 255, green: 242 / 255, blue: 248 / 255)) // 흰색
                        .background(Color(red: 76 / 255, green: 127 / 255, blue: 200 / 255)) // 연파랑
                        .cornerRadius(26.5)
                        .disabled(isSaving)
                    }
                }
                .frame(maxHeight:.infinity , alignment: .leading)
                .padding(10)
            }
            .navigationBarBackButtonHidden(true) // 상단 네비게이션 바, 버튼 제거
            .navigationBarHidden(true)
        .onAppear {
            if let currentUser = userDataManager.currentUser {
                username = currentUser.username
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            imagePicker(image: $selectedImage)
        }
    }

    private var profileImage: some View {
        Group {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 135, height: 135)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .clipShape(Circle())
            } else if let imageUrl = userDataManager.currentUser?.profileImageUrl,
                      let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 135, height: 135)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135, height: 135)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 135, height: 135)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(40)
                    .frame(width: 135, height: 135)
                    .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 167 / 255, green: 167 / 255, blue: 167 / 255), lineWidth: (1)))
            }
        }
    }
    
    
    private func saveChange() {
        guard !isSaving else { return } // 이미 저장중일경우 함수 종료
        isSaving = true
        userDataManager.updateUserProfile(username: username, image: selectedImage) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("프로필 업데이트 성공")
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    print("프로필 업데이트 실패: \(error.localizedDescription)")
                }
                self.isSaving = false
            }
        }
    }
}

struct imagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: imagePicker
        
        init(_ parent: imagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.image = image as? UIImage
                    }
                }
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
                    


