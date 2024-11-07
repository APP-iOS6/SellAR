//
//  KeyboardViewModel.swift
//  SellAR
//
//  Created by Mac on 11/6/24.
//

import Combine
import SwiftUI

// MARK: 키보드 레이아웃이 지오메트리 안밀게 하는 클래스
final class KeyboardViewModel: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupKeyboardHeightListener()
    }
    
    private func setupKeyboardHeightListener() {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return keyboardFrame.height
                }
                return 0
            }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        Publishers.Merge(willShow, willHide)
            .assign(to: \.keyboardHeight, on: self)
            .store(in: &cancellables)
    }
}
// 키보드 띄우고 다른곳 누를시 내리게 하는 익스텐션
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
