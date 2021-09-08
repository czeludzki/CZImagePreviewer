//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit
import SnapKit

public class CZImagePreviewer: UIViewController {
    
    public var delegate: CZImagePreviewerDelegate?
    public var dataSource: CZImagePreviewerDataSource?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func display(fromImageContainer container: UIView?, current index: Int = 0, presented controller: UIViewController?) {
        
    }
    
    public func reloadData() {
        
    }
    
    
}
