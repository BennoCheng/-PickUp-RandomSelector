//
//  ViewController.swift
//  PickUp
//
//  Created by YuCheng on 2025/5/16.
//

import UIKit

class HomeViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView! // 上方縮圖列
    @IBOutlet weak var previewImageView: UIImageView!     // 中間主圖
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!              // 開始抽選（隱藏/顯示）

    private var pickedImages: [UIImage] = []
    private var previewImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


   
    
}

