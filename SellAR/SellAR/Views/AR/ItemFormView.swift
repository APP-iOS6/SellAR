//
//  ItemFormView.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import SwiftUI
import UniformTypeIdentifiers
import SafariServices
import USDZScanner
import PhotosUI

struct ItemFormView: View {
    
    @StateObject var vm = ItemFormVM()
    @Environment(\.dismiss) var dismiss
    
    @State private var showImagePicker = false
    
    @State private var selectedUSDZFileURL: URL?
    
    var body: some View {
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
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("취소") {
                    dismiss()
                }
                .disabled(vm.loadingState != .none)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    Task {
                        do {
                            try await vm.save(fileURL: selectedUSDZFileURL)
                            dismiss()
                        } catch {
                            print("저장 실패: \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(vm.loadingState != .none || vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .confirmationDialog("USDZ 추가", isPresented: $vm.showUSDZSource, titleVisibility: .visible, actions: {
            Button("파일 선택") {
                vm.selectedUSDZSource = .fileImporter
            }
            Button("오브젝트 캡쳐") {
                vm.selectedUSDZSource = .objectCapture
            }
        })
        .sheet(isPresented: .init(get: {
            vm.selectedUSDZSource == .objectCapture
        }, set: { _ in
            vm.selectedUSDZSource = nil
        }), content: {
            USDZScanner { url in
                Task{ await vm.uploadUSDZ(fileURL: url) }
                vm.selectedUSDZSource = nil
            }
        })
        .fileImporter(isPresented: .init(get: { vm.selectedUSDZSource == .fileImporter }, set: { _ in
            vm.selectedUSDZSource = nil
        }), allowedContentTypes: [UTType.usdz], onCompletion: { result in
            switch result {
            case .success(let url):
               // selectedUSDZFileURL = url
                Task { await vm.uploadUSDZ(fileURL: url, isSecurityScopedResource: true)}
            case .failure(let error):
                vm.error = error.localizedDescription
            }
        })
        .navigationTitle(vm.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var inputSection: some View {
        Section {
            TextField("제목", text: $vm.itemName)
            TextField("가격", text: $vm.price)
                .keyboardType(.numberPad)
                .onChange(of: vm.price) { newValue in
                    vm.price = newValue.filter { $0.isNumber }
                }
            
            TextField("상품 설명", text: $vm.description)
            TextField("지역", text: $vm.location)
        }
        .disabled(vm.loadingState != .none)
    }
    
    //USDZ추가
    var arSection: some View {
        Section("AR 모델") {
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
                
                Button("USDZ 삭제", role:  .destructive) {
                    Task { await vm.deleteUSDZ() }
                }
                
            } else {
                Button {
                    vm.showUSDZSource = true
                } label: {
                    HStack {
                        Image(systemName: "arkit").imageScale(.large)
                        Text(selectedUSDZFileURL != nil ? "파일 변경" : "USDZ 추가")
                    }
                }
                
                // 선택된 파일 이름을 표시
                if let selectedURL = selectedUSDZFileURL {
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
    
    //이미지 추가
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
        .sheet(isPresented: $showImagePicker) {
            PhotoPickerView(selectedImages: $vm.selectedImages)  // `vm.selectedImages`에 바인딩
        }
    }

    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        vc?.present(safariVC, animated: true)
    }
}


struct PhotoPickerView: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0  // 여러 이미지 선택 가능, 필요 시 1로 설정하여 단일 선택으로 변경 가능
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPickerView
        
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            // 선택한 이미지가 없을 경우 종료
            guard !results.isEmpty else { return }
            
            // 선택된 이미지를 비동기로 배열에 추가
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                        if let image = image as? UIImage {
                            // 메인 스레드에서 배열에 추가
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
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
