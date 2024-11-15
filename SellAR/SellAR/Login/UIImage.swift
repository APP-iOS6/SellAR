//
//  UIImage.swift
//  SellAR
//
//  Created by Mac on 11/15/24.
//

// MARK: 프로필 정사각형으로 만드는 익스텐션

import UIKit

extension UIImage {
    func croppedToSquare() -> UIImage? {
        let originalWidth = size.width
        let originalHeight = size.height
        let length = min(originalWidth, originalHeight)
        
        let cropRect = CGRect(
            x: (originalWidth - length) / 2,
            y: (originalHeight - length) / 2,
            width: length,
            height: length
        )
        
        guard let croppedCGImage = cgImage?.cropping(to: cropRect) else {
            return nil
        }
        
        return UIImage(cgImage: croppedCGImage)
    }
}
