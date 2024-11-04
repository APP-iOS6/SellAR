//
//  ItemFormView.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import SwiftUI
import UniformTypeIdentifiers
import SafariServices

struct ItemFormView: View {
    
    @StateObject var vm = ItemFormVM()
    @Environment(\.dismiss) var dismiss
    
    
    @State private var selectedUSDZFileURL: URL?
    
    var body: some View {
        Form {
            List {
                inputSection
                arSection
                
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
        .fileImporter(isPresented: .init(get: { vm.selectedUSDZSource == .fileImporter }, set: { _ in
            vm.selectedUSDZSource = nil
        }), allowedContentTypes: [UTType.usdz], onCompletion: { result in
            switch result {
            case .success(let url):
                selectedUSDZFileURL = url  
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
    
    func viewAR(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        let vc = UIApplication.shared.firstKeyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.firstKeyWindow?.rootViewController
        
        vc?.present(safariVC, animated: true)
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
