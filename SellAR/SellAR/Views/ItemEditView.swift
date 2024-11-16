//
//  ItemEditView.swift
//  SellAR
//
//  Created by Min on 11/4/24.
//
// 내 상품 게시글을 수정하는 뷰
import SwiftUI
import FirebaseFirestore
import PhotosUI

struct ItemEditView: View {
    enum KeyboardDone: Hashable {
        case textTitle
        case textdescription
        case textPrice
        case location
    }
    
    @Binding var selectedItem: Item?
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var textFocused: KeyboardDone?
    @State private var description: String = ""
    @State private var selectedImage: UIImage? = nil // 선택된 이미지를 저장할 상태
    @State private var isImagePickerPresented: Bool = false // 이미지 선택기 표시 여부
    @State private var showEditItemView = false
    @ObservedObject var vm = ItemFormVM()

    
    
    let placeholder: String = "내용을 입력해 주세요."
    @ObservedObject var itemStore = ItemStore()
    
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Helper Views
    private var titleTextField: some View {
        TextField("제목을 입력해 주세요", text: Binding(
            get: { selectedItem?.itemName ?? "" },
            set: { selectedItem?.itemName = $0 }
        ))
        .foregroundStyle(Color.black)
        .frame(maxWidth: .infinity, maxHeight: 25)
        .textFieldStyle(.plain)
        .focused($textFocused, equals: .textTitle)
        .padding(.vertical, 5)
        .padding(.leading, 10)
    }
    
    private var locationTextField: some View {
        TextField("위치를 입력해 주세요", text: Binding(
            get: { selectedItem?.location ?? "" },
            set: { selectedItem?.location = $0 }
        ))
        .foregroundStyle(Color.black)
        .frame(maxWidth: .infinity, maxHeight: 25)
        .textFieldStyle(.plain)
        .focused($textFocused, equals: .location)
        .padding(.vertical, 5)
        .padding(.leading, 5)
    }
    
    
    private var descriptionTextEditor: some View {
        TextEditor(text: $description)
            .foregroundStyle(Color.black)
            .onChange(of: description) { newValue in
                selectedItem?.description = newValue
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            .focused($textFocused, equals: .textdescription)
            .overlay {
                if description.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color(.systemGray4))
                }
            }
            .scrollContentBackground(.hidden)
    }
    
    private var priceTextField: some View {
        HStack {
            HStack {
                Text("가격")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.leading, 5)
                
                TextField("가격을 입력해 주세요", text: Binding(
                    get: { selectedItem?.price ?? "0" },
                    set: { selectedItem?.price = ($0) }
                ))
                
                
                Text("원")
                    .padding(.trailing, 5)
            }
            .frame(maxWidth: .infinity, maxHeight: 25)
            .foregroundStyle(Color.black)
            .focused($textFocused, equals: .textPrice)
            .textFieldStyle(.plain)
            .padding(.vertical, 10)
            .keyboardType(.numberPad)
            
            Button(action: {
                textFocused = nil
                presentationMode.wrappedValue.dismiss()
                if let item = selectedItem {
                    // Firestore 문서의 ID를 사용하여 업데이트
                    itemStore.updateItem(item) { error in
                        if let error {
                            print("Error updating item: \(error)")
                        } else {
                            print("Document successfully updated")
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
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        
    }
    
    
    
    private var actionButtons: some View {
        HStack {
//            NavigationLink(
//                       destination: ItemFormView(vm: ItemFormVM()), // ItemFormView로 이동
//                       isActive: $showEditItemView
//                   ) {
//                       EmptyView() // 빈 뷰로 상태 연결
//                   }
//                   .hidden() // UI에 표시되지 않게 숨김
            
            Button(action: {
                textFocused = nil
//                showEditItemView = true
            }) {
                Text("촬영하기")
                    .foregroundStyle(Color.black)
//                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                Image(systemName: "camera")
                    .foregroundColor(Color.cyan)
            }
            
            Divider()
            
            Button(action: {
                textFocused = nil
            }) {
                Text("올리기")
                    .foregroundStyle(Color.black)
//                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.cyan)
            }
            
            Divider()
            
            Button(action: {
                isImagePickerPresented = true
                textFocused = nil
            }) {
                Text("이미지")
                    .foregroundStyle(Color.black)
//                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                Image(systemName: "photo")
                    .foregroundColor(Color.cyan)
            }
            
//            Divider()
            
//            Button(action: { print("지역설정") }) {
//                Text("지역설정")
//                    .foregroundStyle(Color.black)
////                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//                Image(systemName: "map")
//                    .foregroundColor(Color.cyan)
//            }
        }
        .frame(width: .infinity)
        .padding()
        .background(Color.white)
//        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(8).overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top, 15)
    }
    
    
    var body: some View {
        NavigationStack {
        ZStack {
                Color(colorScheme == .dark ?
                      Color(red: 23 / 255, green: 34 / 255, blue: 67 / 255) : Color(red: 203 / 255, green: 217 / 255, blue: 238 / 255))
                    .edgesIgnoringSafeArea(.all)
            
                ScrollView {
                    VStack {
                        // 아이템의 썸네일 이미지 표시
                        if let item = selectedItem {
                            // thumbnailLink가 없을 경우, item.images.first 사용
                            let imageURLString = item.thumbnailLink?.isEmpty ?? true ? item.images.first : item.thumbnailLink
                            
                            if let imageURL = URL(string: imageURLString ?? "") {
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                    case .empty:
                                        // 이미지 로딩 중
                                        ProgressView()
                                            .frame(width: 150, height: 150)
                                            .background(Color.gray)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
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
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    case .failure:
                                        // 이미지 불러오기 실패 시 placeholder 이미지 표시
                                        Image("placeholder")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .padding(.top, 15)
                            } else {
                                // 이미지 URL이 비어있으면 "없음" 텍스트 표시
                                Color.white
                                    .frame(width: 150, height: 150)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                    .overlay(
                                        Text("없음")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16, weight: .bold))
                                    )
                            }
                            
                            
                            
                            
                            actionButtons
                            
                            VStack {
                                HStack {
                                    Text("제목")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.leading, 5)
                                    
                                    titleTextField
                                    
                                    Text("위치")
                                        .foregroundStyle(Color.black)
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.leading, 5)
                                    
                                    locationTextField
                                }
                                
                                Divider()
                                
                                descriptionTextEditor
                                
                                Divider()
                                
                                priceTextField
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
//                            .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.top, 15)
                            
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
                .navigationTitle("상품 수정")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.white)
                })
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage, isPresented: $isImagePickerPresented)
                }
            }
        }
    }
}


// PHPickerViewController를 SwiftUI에서 사용하기 위한 래퍼
struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 선택된 이미지가 있을 경우
            if let selectedItem = results.first {
                selectedItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        // 부모 뷰로 이미지를 전달
                        DispatchQueue.main.async {
                            self.parent.selectedImage = image
                        }
                    }
                }
            }
            
            picker.dismiss(animated: true)
        }
    }
    
    @Binding var selectedImage: UIImage?  // 선택된 이미지를 바인딩
    var isPresented: Binding<Bool>          // 선택기가 표시될지 여부
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 여러 이미지 선택을 허용하려면 이 값을 변경
        configuration.filter = .images // 이미지만 필터링
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
