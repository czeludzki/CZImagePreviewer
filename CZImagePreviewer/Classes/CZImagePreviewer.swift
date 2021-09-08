//
//  CZImagePreviewer.swift
//  CZImagePreviewer
//
//  Created by siuzeontou on 2021/9/8.
//

import UIKit

public class CZImagePreviewer<T>: UIViewController {
    
    var delegate: CZImagePreviewerDelegate?
    typealias ImageResource = T
    var dataSource: CZImagePreviewerDataSource?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func reloadData() {
        
    }
}
