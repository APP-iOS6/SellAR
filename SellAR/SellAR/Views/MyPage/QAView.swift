//
//  Q&AView.swift
//  SellAR
//
//  Created by 배문성 on 11/15/24.
//

import SwiftUI
import WebKit

struct QAView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            LoadingWebView(urlString: "https://app-ios4.github.io/sellAR-qa.html")
                .navigationBarTitle("자주묻는 질문", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool

    class Coordinator: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
        var parent: WebView

        init(parent: WebView) {
            self.parent = parent
        }
        
        // UIScrollViewDelegate 메서드 추가
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return nil // 줌 뷰를 nil로 반환하여 확대/축소 비활성화
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        configuration.preferences = preferences
        configuration.websiteDataStore = .nonPersistent()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.delegate = context.coordinator // ScrollView 델리게이트 설정
        
        // 확대/축소 완전 비활성화
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.zoomScale = 1.0
        
        // 더블탭 제스처 비활성화
        webView.scrollView.gestureRecognizers?.forEach { gesture in
            gesture.isEnabled = false
            if let doubleTapGesture = gesture as? UITapGestureRecognizer,
               doubleTapGesture.numberOfTapsRequired == 2 {
                webView.scrollView.removeGestureRecognizer(doubleTapGesture)
            }
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            if uiView.url != url {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }
}

struct LoadingWebView: View {
    let urlString: String
    @State private var isLoading = true

    var body: some View {
        ZStack {
            WebView(urlString: urlString, isLoading: $isLoading)
            if isLoading {
                VStack {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

// 이전코드

//import SwiftUI
//
//struct QAView: View {
//    @Environment(\.colorScheme) var colorScheme
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedCategory: String? = nil
//    @State private var isLoading = false
//
//// 카테고리 미선택해도 전체 게시물 다 보이는 경우
//    var filteredQA: [QA] {
//        if let category = selectedCategory {
//            return QADataManager.shared.qaData.filter { $0.category == category }
//        } else {
//            return QADataManager.shared.qaData
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            Color(colorScheme == .dark ? Color.black : Color.white).edgesIgnoringSafeArea(.all)
//            // 다크모드 : 라이트모드 순서 검정:밝은회색
//
//                VStack(spacing:0) {
//                    Spacer()
//                        .frame(height: 15)
//                    HStack {
//                        Button(action: {
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName:"chevron.left")
//                                .resizable()
//                                .frame(width: 11, height: 22)
//                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰색:검정
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                        .frame(maxWidth: .infinity, alignment: .leading)
//
//
//                        Text("자주묻는 질문")
//                            .foregroundColor(colorScheme == .dark ? Color.white : Color.black) // 흰:검
//                            .font(.system(size: 20))
//                            .fontWeight(.bold)
//                            .lineLimit(1)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//
//                        Spacer()
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                    }
//                    .padding(.bottom, 20)
//                    .padding(.horizontal, 10)
//
//                VStack(alignment: .center, spacing: 20) {
//                    HStack {
//                        ForEach(["AR지원", "회원관리", "게시물", "등록"], id: \.self) { category in
//                            Button(action: {
//                                if selectedCategory == category {
//                                    selectedCategory = nil  // 이미 선택된 카테고리를 다시 누르면 선택 해제
//                                } else {
//                                    selectedCategory = category
//                                }
//                            }) {
//                                Text(category)
//                            }
//                            .frame(maxWidth : .infinity, alignment: .center)
//                            .foregroundColor(selectedCategory == category ?
//                                (colorScheme == .dark ? Color.black : Color.white) : (colorScheme == .dark ? Color.white : Color.black))
//                            .padding(.vertical, 10)
//                            .background(selectedCategory == category ?
//                                (colorScheme == .dark ? // 선택한 버튼 색상 ( 다크모드 : 라이트모드)
//                                    Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255) : Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255)):
//                                (colorScheme == .dark ? // 선택안한 버튼 색상 ( 다크모드 : 라이트모드)
//                                        Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255))
//                            )
//                            .overlay(RoundedRectangle(cornerRadius: 26.5)
//                                .stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
//                            .cornerRadius(26.5)
//                        }
//                    }
//                    .padding(.horizontal, 10)
//
//                    //카테고리 미선택시 게시물 안보이게하는기능 추가시 수정
//                    if isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                            .scaleEffect(1.5)
//                            .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    } else {
//                        ScrollView {
//                            VStack(spacing: 0) {
//                                ForEach(filteredQA) { qa in
//                                    QAItem(question: qa.question, answer: qa.answer)
//                                }
//                            }
//                        }
//                    }
//                }
//                .frame(maxHeight: .infinity, alignment: .top)
//            }
//            .padding(.horizontal, 10)
//            .navigationBarTitle("")
//            .navigationBarBackButtonHidden(true)
//            .navigationBarHidden(true)
//        }
//    }
//}
//
//struct QAItem: View {
//    @Environment(\.colorScheme) var colorScheme
//
//    let question: String
//    let answer: [String]
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Q. \(question)")
//                .font(.system(size: 18, weight: .bold))
//                .padding(.bottom, 10)
//            HStack {
//                Text("A.")
//                    .frame(maxHeight: .infinity, alignment: .topLeading)
//                Text("\(answer.joined(separator: "\n"))")
//                    .lineSpacing(3)
//            }
//            .font(.system(size: 15, weight: .bold))
//        }
//        .padding(20)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
//        .background(colorScheme == .dark ? Color(red: 53 / 255, green: 57 / 255, blue: 61 / 255) : Color.white)
//        .overlay(Rectangle().stroke(colorScheme == .dark ? Color(red: 91 / 255, green: 91 / 255, blue: 91 / 255) : Color(red: 219 / 255, green: 219 / 255, blue: 219 / 255), lineWidth: (1)))
//    }
//}
