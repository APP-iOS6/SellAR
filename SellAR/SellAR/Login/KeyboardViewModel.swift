//
//  KeyboardViewModel.swift
//  SellAR
//
//  Created by Mac on 11/6/24.
//

import Combine
import SwiftUI

// MARK: 키보드 뷰 모델 파일
final class KeyboardViewModel: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
}
// 키보드 띄우고 다른곳 누를시 내리게 하는 익스텐션
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
