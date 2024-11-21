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
import ARKit

struct ItemEditView: View {
    enum KeyboardDone: Hashable {
        case textName
        case textdescription
        case textPrice
        case location
    }
    
    @Binding var selectedItem: Items?
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var textFocused: KeyboardDone?
    @State private var description: String = ""
    @State private var isImagePickerPresented: Bool = false // 이미지 선택기 표시 여부
    @State private var showEditItemView = false
    @ObservedObject var vm = ItemFormVM()
    
    let placeholder: String = "내용을 입력해 주세요."
    @ObservedObject var itemStore = ItemStore()
    
    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.dismiss) var dismiss
    
    @State private var showImagePicker = false
    @State private var selectUSDZFileURL: URL?
    @State private var formattedPrice: String = "0"
    @State private var isScannerLoading = false
    @State private var isLiDARAvailable: Bool = ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh)
    @State private var showLiDARAlert = false // LiDAR 지원 경고창 표시 여부
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    List {
                        inputSection
                        arSection
                        imageSection
                        
                        if case .deleting(let type) = vm.loadingState {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    ProgressView()
                                    Text("삭제중 \(type == .usdzWithThumbnail ? "USDZ file" : "Item") ")
                                        .foregroundStyle(.red)
                                }
                                Spacer()
                            }
                        }
                        
                        if case .edit = vm.formType {
                            Button("삭제", role: .destructive) {
                                Task {
                                    do {
                                        try await vm.deleteItem()
                                        dismiss()
                                    } catch {
                                        vm.error = error.localizedDescription
                                    }
                                }
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .navigationTitle("상품 수정")
                
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(vm.loadingState != .none)
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            textFocused = nil
                            print("현재 선택된 이미지: \(vm.selectedImages)")
                            
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
                                Task {
                                    do {
                                        try await vm.save(fileURL: selectUSDZFileURL)
                                    } catch {
                                        print("저장 실패: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }) {
                            Text("저장")
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        }
                    }
                    
                }
                .confirmationDialog("USDZ 추가", isPresented: $vm.showUSDZSource, titleVisibility: .visible, actions: {
                    Button("파일 선택") {
                        vm.selectedUSDZSource = .fileImporter
                    }
                    Button("오브젝트 캡쳐") {
                        if isLiDARAvailable {
                            vm.selectedUSDZSource = .objectCapture
                        } else {
                            showLiDARAlert = true
                        }
                    }
                })
                .alert("LiDAR 지원 없음", isPresented: $showLiDARAlert) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text("이 기기에서는 지원하지 않는 기능입니다.")
                }
                .fullScreenCover(isPresented: .init(get: {
                    vm.selectedUSDZSource == .objectCapture && !isScannerLoading
                }, set: { _ in
                    vm.selectedUSDZSource = nil
                }), content: {
                    USDZScanner { url in
                        Task {
                            isScannerLoading = false
                            await vm.uploadUSDZ(fileURL: url)
                        }
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
                .sheet(isPresented: $showImagePicker) {
                    PhotoPickerView(selectedImages: $vm.selectedImages)
                }
                .navigationTitle(vm.navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
                .background(
                    Color(UIColor { traitCollection in
                        traitCollection.userInterfaceStyle == .dark
                        ? UIColor.black
                        : UIColor.white
                    }).ignoresSafeArea()
                )
                
                if isScannerLoading {
                    VStack {
                        ProgressView("스캐너 로드 중...")
                            .padding()
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(10)
                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
        }
    }
    
    var inputSection: some View {
        Section {
            TextField("제목", text: Binding(
                get: { selectedItem?.itemName ?? "" },
                set: { selectedItem?.itemName = $0 }
            ))
            .focused($textFocused, equals: .textName)
            
            Divider()
            
            TextField("가격 (원)", text: Binding(
                get: { selectedItem?.price ?? "" },
                set: { selectedItem?.price = $0 }
            ))
            .keyboardType(.numberPad)
            .focused($textFocused, equals: .textPrice)
            .onChange(of: selectedItem?.price ?? "0") { newValue in
                selectedItem?.price = newValue.filter { $0.isNumber }
                formatPrice()
            }
            .onChange(of: selectedItem?.price ?? "0") { newValue in
                if newValue.isEmpty {
                    formattedPrice = "0"
                }
            }
            
            Text("가격: \(formattedPriceInTenThousandWon)")
                .font(.footnote)
                .foregroundColor(.gray)
            
            Divider()
            
            TextEditor(text: Binding(
                get: { selectedItem?.description ?? "" }, // selectedItem의 description을 가져옴
                set: { selectedItem?.description = $0 }   // description 변경 시 selectedItem의 description을 업데이트
            ))
            .focused($textFocused, equals: .textdescription)
            .onChange(of: selectedItem?.description ?? "") { newValue in
                // description이 변경될 때 선택된 아이템의 설명을 업데이트
                selectedItem?.description = newValue
            }
            .focused($textFocused, equals: .textdescription)
            .overlay {
                if (selectedItem?.description.isEmpty ?? true) {
                    Text("상품 설명을 입력하세요") // placeholder 텍스트
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
            }
            .scrollContentBackground(.hidden)
            
            Divider()
            
            TextField("위치를 입력해 주세요", text: Binding(
                get: { selectedItem?.location ?? "" },
                set: { selectedItem?.location = $0 }
            ))
            .focused($textFocused, equals: .location)
        }
        .disabled(vm.loadingState != .none)
    }
    
    var arSection: some View {
        Section("AR 모델") {
            if let item = selectedItem {
                if let thumbnailURL = item.thumbnailURL {
                    AsyncImage(url: thumbnailURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        case .failure(_):
                            Color.white
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if let firstImageURL = item.images.first, let url = URL(string: firstImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 300)
                        case .failure:
                            Color.white
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    Text("이미지 없음")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16, weight: .bold))
                                )
                        }
                    }
                }
            }
            if let thumbnailURL = vm.thumbnailURL {
                AsyncImage(url: thumbnailURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .failure:
                        Text("Failed to fetch thumbnail")
                    default:
                        ProgressView()
                    }
                }
                .onTapGesture {
                    guard let usdzURL = vm.usdzURL else { return }
                    viewAR(url: usdzURL)
                }
            }
            
            if let usdzURL = vm.usdzURL {
                Button {
                    viewAR(url: usdzURL)
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text("보기")
                    }
                }
                
                Button("USDZ 삭제", role: .destructive) {
                    Task { await vm.deleteUSDZ() }
                }
                
            } else {
                Button {
                    vm.showUSDZSource = true
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text(selectUSDZFileURL != nil ? "파일 변경" : "USDZ 추가")
                    }
                }
                
                if let selectedURL = selectUSDZFileURL {
                    Text("선택된 파일: \(selectedURL.lastPathComponent)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
            
            if let progress = vm.uploadProgress, case let .uploading(type) = vm.loadingState, progress.totalUnitCount > 0 {
                VStack {
                    ProgressView(value: progress.fractionCompleted) {
                        Text("업로드 중 \(type == .usdz ? "USDZ" : "Thumbnail") 파일 \(Int(progress.fractionCompleted * 100))%")
                    }
                    Text("\(vm.byteCountFormatter.string(fromByteCount: progress.completedUnitCount)) / \(vm.byteCountFormatter.string(fromByteCount: progress.totalUnitCount))")
                }
            }
        }
        .disabled(vm.loadingState != .none)
    }
    
    var imageSection: some View {
        Section("이미지") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                   
                    ForEach(vm.selectedImages.indices, id: \.self) { index in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: vm.selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Button(action: {
                                vm.selectedImages.remove(at: index)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .offset(x: -5, y: 5)
                        }
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("이미지 추가")
                                .font(.footnote)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
    
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindows?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindows?.rootViewController
        vc?.present(safariVC, animated: true)
    }
    
    func formatPrice() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let priceNumber = Int(vm.price) {
            formattedPrice = numberFormatter.string(from: NSNumber(value: priceNumber)) ?? "0"
        } else {
            formattedPrice = "0"
        }
    }
    
    private var formattedPriceInTenThousandWon: String {
        let priceNumber = Int(selectedItem?.price ?? "0") ?? 0
        let tenThousandUnit = priceNumber / 10000
        let remaining = priceNumber % 10000
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if tenThousandUnit > 0 {
            if remaining == 0 {
                return "\(tenThousandUnit)만원"
            } else {
                let remainingStr = formatter.string(from: NSNumber(value: remaining)) ?? "0"
                return "\(tenThousandUnit)만 \(remainingStr)원"
            }
        } else {
            return formatter.string(from: NSNumber(value: remaining)) ?? "0원"
        }
    }
}

struct EditPhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: EditPhotoPickerView
        
        init(_ parent: EditPhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard !results.isEmpty else { return }
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self?.parent.selectedImages.append(image)
                            }
                        } else if let error = error {
                            print("이미지를 로드할 수 없습니다: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

extension UIApplication {
    var firstKeyWindows: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
