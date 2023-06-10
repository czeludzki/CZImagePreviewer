# CZImagePreviewer

[![CI Status](http://img.shields.io/travis/czeludzki/CZImagePreviewer.svg?style=flat)](https://travis-ci.org/czeludzki/CZImagePreviewer)
[![Version](https://img.shields.io/cocoapods/v/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![License](https://img.shields.io/cocoapods/l/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![Platform](https://img.shields.io/cocoapods/p/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Feature
✅ Kingfisher image loading and caching base  
✅ Large Image(Testing with 100 million pixel image) Display Supported, Steady Memory Consumption  
✅ Gif Supported  
✅ Zooming by double tap and pinch gesture  
✅ Display and dismiss animation customizable  
✅ Screen rotate supported  
✅ Customizable accessory view cover on each cell  
✅ Customizable accessory view fulltime cover  
✅ Customizable video view as your provide  

## Views Struct
- Controller.View  
    - CollectionView  
        - ImageCell  
            - Cell.ContentView  
                - ScrollViewForImageZooming  
                    - UIImageView  
                - ScrollViewForImageZooming(Only appear when large image displaying)  
                    - TiledImageView  
                - AccessoryView(As your provide)  
        - VideoCell  
            - Cell.ContentView  
                - VideoView (As your provide)  
                - AccessoryView(As your provide)  
    - Custom console (the basic custom on Controller.view, front of the CollectionView)

## Screen Record
**Large Image Displaying**  
![巨图显示](introduction/largeImage.gif)  
**Zooming**  
![放大缩小](introduction/zooming.gif)  
**Dismiss on drag**  
![滑动dismiss](introduction/dismiss.gif)  
**Screen Rotate**  
![旋转](introduction/rotate.gif)  
**Video Playing**  
![视频播放](introduction/videoplay.gif)  

## Usage
``` swift
/// 展示
public func display(fromImageContainer container: UIView? = nil, current index: Int = 0)
```

``` swift
// MARK: PreviewerDataSource

/// 只要是 ResourceProtocol 的实例/结构体/枚举, 都可以作为数据源返回值
/// 而 String, URL, UIImage 三种类型实例, 可通过 .asImgRes 直接返回
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, imageResourceForItemAtIndex index: Int) -> ResourceProtocol?

/// 为图片浏览器提供自定义操作视图, 该视图会平铺在图片浏览器子视图集顶部, 不参与缩放, 不受滑动交互影响
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, consoleForItemAtIndex index: Int) -> CZImagePreviewer.AccessoryView?

/// 为每一个 Cell 提供自定义操作视图, 这个视图会覆盖在每个Cell的顶部, 参与滚动
func imagePreviewer(_ imagePreviewer: CZImagePreviewer, accessoryViewForCellWith viewModel: PreviewerCellViewModel) -> CZImagePreviewer.AccessoryView?

/// 为每一个 Cell 提供视频播放容器, 返回的播放器layer, 会被添加到 视频容器视图 中
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

#### 更具体的使用可参照项目中的 demo, demo中提供了比较基本的使用方法以及配合AVPlayer做了一个比较简单的视频播放例子

## 如有问题欢迎提 issues 或者 pull request

## Requirements

iOS 12+

## Dependence
[SnapKit](https://github.com/SnapKit/SnapKit)  
[Kingfisher](https://github.com/onevcat/Kingfisher)  

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
