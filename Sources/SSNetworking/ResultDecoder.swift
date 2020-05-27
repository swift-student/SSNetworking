//
//  ResultDecoder.swift
//  Albums
//
//  Created by Shawn Gee on 4/13/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//


import Foundation

public protocol ResultDecoder {
    
    associatedtype ResultType
    
    var transform: (Data) throws -> ResultType { get }
    
    func decode(_ result: DataResult) -> Result<ResultType, NetworkError>
}

public extension ResultDecoder {
    func decode(_ result: DataResult) -> Result<ResultType, NetworkError> {
        result.flatMap { data -> Result<ResultType, NetworkError> in
            Result { try transform(data) }
                .mapError { NetworkError.decodingError($0) }
        }
    }
}

public extension ResultDecoder where ResultType: Decodable {
    var transform: (Data) throws -> ResultType {
        get {
            return { data in
                try JSONDecoder().decode(ResultType.self, from: data)
            }
        }
    }
}

#if !os(macOS)

import UIKit

public struct ImageResultDecoder: ResultDecoder {
    public typealias ResultType = UIImage
    
    public var transform: (Data) throws -> UIImage = { data in
        guard let image = UIImage(data: data) else {
            throw NetworkError.badData
        }
        
        return image
    }
    
    public init() {}
}

#endif
