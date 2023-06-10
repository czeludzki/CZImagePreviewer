# CZImagePreviewer

[![CI Status](http://img.shields.io/travis/czeludzki/CZImagePreviewer.svg?style=flat)](https://travis-ci.org/czeludzki/CZImagePreviewer)
[![Version](https://img.shields.io/cocoapods/v/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![License](https://img.shields.io/cocoapods/l/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![Platform](https://img.shields.io/cocoapods/p/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Feature
✅ [Kingfisher](https://github.com/onevcat/Kingfisher) image loading and caching base  
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
### For shown off
``` swift
/// - Parameters:
///   - container: Tell Previewer which view component tirggers this display operation, all is for the display animation.
///   if nil, Previewer will provide a fade animate.
///   - fromSource: When displaying animate play, Previewer should known who is the animation acort.
///   Of course you can passing nil, then Previewer will get that from 'dataSource' by 'currentIndex'.
///   - index: Tell Previewer which resource you wanna show from the 'dataSource' at index
///   - controller: The controller which is presenting Previewer
public func display(fromImageContainer container: UIView? = nil, fromSource source: UIImage? = nil, presentingController: UIViewController? = nil, current index: Int = 0)
```

### Resource Provider: whcih is being the member of the `dataSource`
``` swift
public protocol ResourceProvider {}
```
#### ImageProvider
``` swift
public protocol ImageProvider: ResourceProvider, Kingfisher.ImageDataProvider {}
```
#### VideoProvider
``` swift
public protocol VideoProvider: ResourceProvider, AnyObject {
    
    /// Video Content View
    var videoView: CZImagePreviewer.VideoView? { get }
        
    // Previewer should lintening the video size's changing, returning the new size in this closure
    typealias VideoSizeProvider = (_ videoSize: CGSize) -> Void
    var videoSizeProvider: VideoSizeProvider? { get set }
    
    func play()
    func pause()
    
    func cellDidEndDisplay()
    
    // You can do some preparing opreation for the video resource right here
    func perload()
}
```

#### DataSource
``` swift
public protocol DataSource: AnyObject {
    
    func numberOfItems(in previewer: Previewer) -> Int
    
    func imagePreviewer(_ previewer: Previewer, resourceForItemAtIndex index: Int) -> ResourceProvider?
    
    func imagePreviewer(_ previewer: Previewer, imageLoadingStateDidChanged state: Previewer.ImageLoadingState, at index: Int, accessoryView: AccessoryView?)
    
    /// Provide the accessory view for Previewer, this accessory view is not a part of scrolling or zooming effect. 
    /// Will calling when the index changed.
    /// - imagePreviewer: Previewer
    /// - index: which index of item need accessory view
    func imagePreviewer(_ imagePreviewer: Previewer, consoleForItemAtIndex index: Int) -> AccessoryView?
    
    /// Provider the accessory view for Previewer on each cell item. this is not part of zooming effect, but scrolling is.
    /// This accessory view will cover on the cell.
    /// Will calling when the index changed.
    /// - imagePreviewer: Previewer
    /// - cell: which cell adding this AccessoryView as the subview.
    /// - index: which index of item need accessory view
    func imagePreviewer(_ imagePreviewer: Previewer, accessoryViewForCell cell: CollectionViewCell, at index: Int) -> AccessoryView?
    
}
```

#### PreviewerDelegate
``` swift
public protocol Delegate: AnyObject {
    
    func imagePreviewer(_ previewer: Previewer, willDisplayAtIndex index: Int)
    
    func imagePreviewer(_ previewer: Previewer, didDisplayAtIndex index: Int)
    
    func imagePreviewer(_ previewer: Previewer, indexDidChangedTo newIndex: Int, fromOldIndex oldIndex: Int)
    
    func imagePreviewer(_ previewer: Previewer, willDismissWithCell cell: CollectionViewCell, at index: Int) -> UIView?
    
    func imagePreviewerDidDismiss(_ previewer: Previewer)

    /// longPress gesture event happened with Previewer
    func imagePreviewer(_ previewer: Previewer, didLongPressAtIndex index: Int)
    
    /// By default, Previewer did add two kind of gesture for dismiss: UITapGesture and UIPanningGesture.
    /// Call when Tap or Panning gesture did happened. The returning Boolean value is deciding this dismiss should be happen.
    func imagePreviewer(_ previewer: Previewer, shouldDismissWithGesture gesture: UIGestureRecognizer, at index: Int) -> Bool
    
    /// Call after Previewer executed method: `deleteItems(at indexs: [Int])`
    func imagePreviewer(_ previewer: Previewer, didFinishDeletedItems indexs: [Int])   
}
```

## And more usage can view in demo. 

## Any kind of issues is welcome.

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
