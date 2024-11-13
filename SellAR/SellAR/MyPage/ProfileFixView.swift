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
    
    init(userDataManager: UserDataManager) {
        self._userDataManager = ObservedObject(wrappedValue: userDataManager)
    }
    
    var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName:"chevron.left")
                            .resizable()
                            .frame(width: 11, height: 22)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 20)
                    
                    Text("프로필 수정")
                        .font(.headline)
                        .padding(.bottom, 15)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .center, spacing: 20) {
                        // 프로필 사진
                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            profileImage
                        }
                        
                        // 닉네임 및 이메일
                        VStack(alignment: .leading, spacing: 10) {
                            Text("이름")
                                .font(.system(size: 20))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                TextField("", text: $username)
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
                    }
                }
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
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "camera")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .padding(30)
                    .frame(width: 135, height: 135)
                    .foregroundColor(.gray)
                    .background(Color.white.opacity(0.1))
            }
        }
    }
    
    private func saveChange() {
        userDataManager.updateUserProfile(username: username, image: selectedImage) { result in
            switch result {
            case .success:
                print("프로필 업데이트 성공")
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("프로필 업데이트 실패: \(error.localizedDescription)")
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
                    


