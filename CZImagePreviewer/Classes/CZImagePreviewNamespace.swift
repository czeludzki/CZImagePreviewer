//
//  CZImagePreviewNamespace.swift
//  CZImagePreviewNamespace
//
//  Created by siuzeontou on 2021/9/8.
//

import Foundation
import UIKit

public protocol ImgSourceNamespaceProtocol {
    associatedtype WrappedValueType
    var wrappedValue: WrappedValueType { get }
    init(wrappedValue: WrappedValueType)
}

/// 定义一个命名空间结构体, 该结构体有名为 wrappedValue 的属性, 该属性指向被包装对象
public struct ImgSourceNamespaceWrapper<T>: ImgSourceNamespaceProtocol{
    public let wrappedValue: T
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
}

public protocol ImgSourceNamespaceWrappable {
    associatedtype WrappedValueType
    var szt: ImgSourceNamespaceWrapper<WrappedValueType> { get }
}

extension ImgSourceNamespaceWrappable {
    public var szt: ImgSourceNamespaceWrapper<Self> {
        return ImgSourceNamespaceWrapper.init(wrappedValue: self)
    }
}
