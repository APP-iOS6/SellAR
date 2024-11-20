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
import UniformTypeIdentifiers
import SafariServices
import USDZScanner

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
    @State private var selectedImages: [UIImage] = [] // 선택된 이미지를 저장할 상태
    @State private var isImagePickerPresented: Bool = false // 이미지 선택기 표시 여부
    @State private var showEditItemView = false
    @State private var selectedUSDZFileURL: URL?
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
        
        .frame(maxWidth: .infinity, maxHeight: 25)
        .textFieldStyle(.plain)
        .focused($textFocused, equals: .location)
        .padding(.vertical, 5)
        .padding(.leading, 5)
    }
    
    
    private var descriptionTextEditor: some View {
        TextEditor(text: $description)
            
            .onChange(of: description) { newValue in
                selectedItem?.description = newValue
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            .focused($textFocused, equals: .textdescription)
            .overlay {
                if description.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
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
//                Task {
//                    do {
//                        try await vm.save(fileURL: selectedUSDZFileURL)
//                    } catch {
//                        print("저장 실패: \(error.localizedDescription)")
//                    }
//                }
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
            Button(action: {
                vm.showUSDZSource = true
                textFocused = nil
            }) {
                Text("촬영하기")
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Image(systemName: "camera")
                    .foregroundColor(Color.cyan)
            }
            .confirmationDialog("USDZ 추가 및 수정", isPresented: $vm.showUSDZSource, titleVisibility: .visible) {
                Button("파일 선택") {
                    vm.selectedUSDZSource = .fileImporter
                }
                Button("오브젝트 캡쳐") {
                    vm.selectedUSDZSource = .objectCapture
                }
                Button("취소", role: .cancel) {}
            }
            .fullScreenCover(isPresented: .init(get: {
                vm.selectedUSDZSource == .objectCapture
            }, set: { _ in
                vm.selectedUSDZSource = nil
            }), content: {
                USDZScanner { url in
                    Task { await vm.uploadUSDZ(fileURL: url) }
//                    Task {
//                        await vm.uploadUSDZ(fileURL: url)
//                        
//                        if let uploadedUSDZURL = vm.usdzURL?.absoluteString,
//                           let uploadedThumbnailURL = vm.thumbnailURL?.absoluteString {
//                            selectedItem?.usdzLink = uploadedUSDZURL
//                            selectedItem?.thumbnailLink = uploadedThumbnailURL
//                        }
//                        
//                        // 업로드 후 상태 초기화
//                        vm.selectedUSDZSource = nil
//                    }

                    // 업로드 후 상태 초기화
                    vm.selectedUSDZSource = nil
                }
            })
            .fileImporter(isPresented: .init(get: { vm.selectedUSDZSource == .fileImporter }, set: { _ in
                vm.selectedUSDZSource = nil
            }), allowedContentTypes: [UTType.usdz], onCompletion: { result in
                switch result {
                case .success(let url):
                    Task { await vm.uploadUSDZ(fileURL: url, isSecurityScopedResource: true) }
                case .failure(let error):
                    vm.error = error.localizedDescription
                }
            })

            
            Divider()
            
            Button(action: {
                textFocused = nil
            }) {
                Text("올리기")
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.cyan)
            }
            
            Divider()
            
            Button(action: {
                isImagePickerPresented = true
                textFocused = nil
            }) {
                Text("이미지")
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Image(systemName: "photo")
                    .foregroundColor(Color.cyan)
            }
            .sheet(isPresented: $isImagePickerPresented) {
                PhotoPickerView(selectedImages: $selectedImages)
//                PhotoPickerView(selectedImages: $vm.selectedImages)

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
        .background(Color(.systemGray6))
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        .cornerRadius(8).overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.top, 15)
    }
    
    
    var body: some View {
        NavigationStack {
        ZStack {
            Color(colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
            
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
                                        
                                        .font(.system(size: 20, weight: .bold))
                                        .padding(.leading, 5)
                                    
                                    titleTextField
                                    
                                    Text("위치")
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
                            .background(Color(.systemGray6))
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
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                })
            }
        }
    }
}
