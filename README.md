# CZImagePreviewer

[![CI Status](http://img.shields.io/travis/czeludzki/CZImagePreviewer.svg?style=flat)](https://travis-ci.org/czeludzki/CZImagePreviewer)
[![Version](https://img.shields.io/cocoapods/v/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![License](https://img.shields.io/cocoapods/l/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![Platform](https://img.shields.io/cocoapods/p/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

#### 自 1.1.0 起改造成100%的斯威夫特实现, 比起以前的OC实现兼容的使用场景更多, 旋转更流畅

## 介绍
#### 概览


#### 设计
我做的是一个很纯粹的图片浏览器, 但是也可以很强大, 类似于wechat上的图片浏览功能:  
1.图片放大和缩小;  
2.滑动 dismiss;
3.兼容系统级别的旋转触发且动画流畅;  
4.它可以兼顾不同的开发者使用场景, 例如图片浏览器上有不同的按钮, 有些按钮是跟随图片滑动而滑动的, 有些不需要. 所以, 我提供了相关的方法和视图供开发者自由设置.  
5.它没有集成视频播放器, 以免在项目中造成播放器冲突或其他不好的结果, 但是它也可以联动图片浏览器的交互方式播放视频. 因为我提供了相关的方法和视图, 开发者可以将不同的视频播放器 layer 添加到视图中, 既兼顾了交互, 也能保证高度自定义的目的.  

为了兼容图片浏览器上各种自定义的操作需求, 以及广泛的视频播放器支持, 我将 CZImagePreviewer 设计成以下视图层级:

```
> Controller.View  
    > CollectionView  
        > Cell  
            > Cell.ContentView  
                > ScrollViewForImageZooming  
                    > UIImageView  
                > AccessoryViewForCell  (add custom components here, like play, pause, loading indicator...)
                > Video View (the player layer add to here)
    > Custom console (the basic custom on Controller.view, front of the CollectionView)
```

#### 使用
``` swift
/// 展示
public func display(fromImageContainer container: UIView? = nil, current index: Int = 0)
```

``` swift
// MARK: PreviewerDataSource

func numberOfItems(in imagePreviewer: CZImagePreviewer) -> Int
/// 只要是 ResourceProtocol 的实例/结构体/枚举, 都可以作为数据源返回值
/// 而 String, URL, UIImage 三种类型实例, 可通过 .asImgRes 直接返回
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol?

/// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView?

/// 为每一个 Cell 提供自定义操作视图, 这个视图会覆盖在每个Cell的顶部
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel) -> CZImagePreviewer.AccessoryView?

/// 为每一个 Cell 提供视频播放容器, 你可以将你的视频播放器 Layer, 添加到 videoView.layer 中
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoLayerForCellWith viewModel: PreviewerCellViewModel) -> CALayer?

/// 通过此方法告知 Previewer 视频尺寸
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, videoSizeForItemWith viewModel: PreviewerCellViewModel, videoSizeSettingHandler: VideoSizeSettingHandler)
```

``` swift
// MARK: PreviewerDelegate

/// 当 imagePreviewer 即将要退出显示时调用
/// - Returns: 根据返回值决定返回动画: 退回到某个UIView视图的动画
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, willDismissWithCellViewModel viewModel: PreviewerCellViewModel) -> UIView?

/// 接收到长按事件
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, didLongPressAtIndex index: Int)
```

## 更具体的使用可参照项目中的 demo, 如有问题欢迎提 issues 或者 pull request

## Requirements
iOS 11+

## Dependence
snapkit  
kingfisher

## Installation

CZImagePreviewer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CZImagePreviewer'
```

## Author

czeludzki, czeludzki@gmail.com

## License

CZImagePreviewer is available under the MIT license. See the LICENSE file for more info.
