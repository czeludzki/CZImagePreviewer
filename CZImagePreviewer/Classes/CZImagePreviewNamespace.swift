//
//  CZImagePreviewNamespace.swift
//  CZImagePreviewNamespace
//
//  Created by siuzeontou on 2021/9/8.
//

/*
 为了使 String, URL, UIImage 可以快速访问到 数据源协议ImageResourceProtocol 的方法, 但又不想直接通过 extension String: ImageResourceProtocol 实现, 避免污染到命名空间, 影响开发中方法命名冲突
 所以设计以下 ImgSourceNamespaceWrapper 结构体, ImgSourceNamespaceWrappable 协议, 让 String, URL, UIImage 遵循 ImgSourceNamespaceWrappable 协议, 通过 String, URL, UIImage 的实例的 .szt 属性 直接访问到 ImageResourceProtocol协议的方法
 */

import Foundation
import UIKit

/// 定义一个命名空间结构体, 该结构体有名为 wrappedValue 的属性, 该属性指向被包装对象
public struct ImgSourceNamespaceWrapper<WrappedValueType> {
    public let wrappedValue: WrappedValueType
    public init(wrappedValue: WrappedValueType) {
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
