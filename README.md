# CZImagePreviewer

[![CI Status](http://img.shields.io/travis/czeludzki/CZImagePreviewer.svg?style=flat)](https://travis-ci.org/czeludzki/CZImagePreviewer)
[![Version](https://img.shields.io/cocoapods/v/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![License](https://img.shields.io/cocoapods/l/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)
[![Platform](https://img.shields.io/cocoapods/p/CZImagePreviewer.svg?style=flat)](http://cocoapods.org/pods/CZImagePreviewer)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Create and show
```
CZImagePreviewer *imagePreview = [CZImagePreviewer imagePreViewWithImages:(NSArray <CZImagePreviewerItem>*)items displayingIndex:indexPath.item];
// when the previewer show(previewer is a subclass of UIViewController), tell previewer where is the image's container.
[imagePreview showWithImageContainer:[collectionView cellForItemAtIndexPath:indexPath] andPresentedController:self];
```

delegate
```
// when previewer will dismiss, tells it where to return the image's container.
- (UIView *)imagePreviewWillDismissWithDisplayingImage:(CZImagePreviewImageItem *)imageItem andDisplayIndex:(NSInteger)index;
```

## Requirements

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
