//
//  CZImagePreviewer.swift
//  Pods-CZImagePreviewer_Example
//
//  Created by siuzeontou on 2021/9/14.
//

import Foundation

extension CZImagePreviewer {
    
    public enum ImageLoadingState {
        case `default`  // 正常可预览状态
        case loading(receivedSize: Int, expectedSize: Int)  // 加载中
        case loadingFaiure  // 加载失败
        case processing     // 图片解码中
    }
    
    /// DateSource 方法要求返回的辅助视图类
    open class AccessoryView: UIView {
        
        /// 辅助视图类型
        public enum ViewType {
            /// 放在 Previewer 顶部的控制面板
            case console
            /// 放在 Cell 上的辅助视图
            case accessoryView
            /// Cell 上的视频容器视图
            case videoView
        }
        
        var _viewType: ViewType = .console
        public var viewType: ViewType { _viewType }
        
        /// 对 hitTest 方法进行处理, 防止 AccessoryView 参与事件处理
        open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let ret = super.hitTest(point, with: event) else {
                return nil
            }
            // 当找到的响应者是自己, 就返回 nil, 不参与事件响应
            if ret == self {
                return nil
            }
            return ret
        }
    }
    
}
