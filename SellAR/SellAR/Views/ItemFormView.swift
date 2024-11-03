//
//  ItemFormView.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import SwiftUI

struct ItemFormView: View {
    
    @StateObject var vm = ItemFormVM()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            List {
                inputSection
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
                    do {
                        try vm.save()
                        dismiss()
                    } catch {}
                }
                .disabled(vm.loadingState != .none || vm.itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert(isPresented: .init(get: {vm.error !=  nil}, set:{ _ in vm.error = nil}), error: "오류가 발생했습니다", actions:{ _ in}, message: { _ in
            Text(vm.error ?? "")
        })
        .navigationTitle(vm.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var inputSection: some View {
        Section {
            TextField("제목", text: $vm.itemName)
            TextField("가격", text: $vm.price)
                .keyboardType(.numberPad)
                .onChange(of: vm.price) { newValue, _ in
                    
                    vm.price = newValue.filter { $0.isNumber }
                }


            TextField("상품 설명", text: $vm.description)
            TextField("지역" ,text: $vm.location)
        }
        .disabled(vm.loadingState != .none)
    }
}

#Preview {
    NavigationStack {
        ItemFormView()
    }
}
