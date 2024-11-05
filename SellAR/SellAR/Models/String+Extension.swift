//
//  String+Extension.swift
//  SellAR
//
//  Created by Juno Lee on 11/4/24.
//

import Foundation

extension String: @retroactive Error, @retroactive LocalizedError {
    
    public var errorDescription: String? { self }
}
