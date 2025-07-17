//
//  Untitled.swift
//  PickUp
//
//  Created by YuCheng on 2025/5/19.
//

import UIKit
import Photos

class MainViewController: UIViewController {
    
    // MARK: - 屬性
    private var photos: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
            updateStartButtonState()
        }
    }
    
    private var selectedPhotoIndex: Int?
    
    // 動畫用的牌面圖片
    private var cardAnimationImages: [UIImage] = []
    private let animationDuration: TimeInterval = 1.5  // 動畫持續時間
    private var isAnimating = false  // 防止動畫過程中重複點擊
    
    // MARK: - UI元素
    private lazy var centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("拍照", for: .normal)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoLibraryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("相簿", for: .normal)
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(photoLibraryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("開始抽選", for: .normal)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private lazy var cleanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("清除", for: .normal)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cleanButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cameraButton, photoLibraryButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - 生命週期方法
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkCameraPermission()
        checkPhotoLibraryPermission()
        
        loadCardAnimationImages()
    }
    
    // MARK: - UI設置
    private func setupUI() {
        title = "隨機照片抽選器"
        view.backgroundColor = .systemBackground
        
        view.addSubview(centerImageView)
        view.addSubview(collectionView)
        view.addSubview(buttonStackView)
        view.addSubview(startButton)
        view.addSubview(cleanButton)
        
        NSLayoutConstraint.activate([
            centerImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            centerImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            centerImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            centerImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            
            collectionView.topAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.heightAnchor.constraint(equalToConstant: 70),
            
            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            startButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            cleanButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            cleanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cleanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cleanButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 添加點擊手勢到中心的圖片視圖
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(centerImageTapped))
        centerImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - 按鈕動作
    @objc private func cameraButtonTapped() {
        presentCamera()
    }
    
    @objc private func photoLibraryButtonTapped() {
        presentPhotoLibrary()
    }
    
    @objc private func startButtonTapped() {
        // 避免動畫運行中重複點擊
        if isAnimating { return }
        isAnimating = true
        
        // 播放洗牌動畫
        playCardShuffleAnimation()
    }
    
    @objc private func cleanButtonTapped() {
        cleanAllPhoho()
    }
    
    @objc private func centerImageTapped() {
        if let index = selectedPhotoIndex, index < photos.count {
            showDeleteAlert(for: index)
        }
    }
    
    
    private func loadCardAnimationImages() {
        // 加載三張撲克牌圖片
        if let image1 = UIImage(named: "card1"),
           let image2 = UIImage(named: "card2"),
           let image3 = UIImage(named: "card3") {
            cardAnimationImages = [image1, image2, image3]
        } else {
            print("無法加載動畫圖片")
        }
    }
    //MARK: - 清除照片
    private func cleanAllPhoho() {
        photos.removeAll()
        centerImageView.image = nil
    }
    // MARK: - 隨機選擇照片
    // 洗牌動畫
    private func playCardShuffleAnimation() {
        guard !photos.isEmpty else {
            isAnimating = false
            return
        }
        
        // 保存當前中心圖片，以便稍後恢復
        let currentCenterImage = centerImageView.image
        
        // 淡出當前圖片
        UIView.animate(withDuration: 0.2, animations: {
            self.centerImageView.alpha = 0
        }) { _ in
            // 開始播放卡片動畫序列
            self.startCardSequenceAnimation(currentImage: currentCenterImage)
        }
    }

    // 卡片動畫序列
    private func startCardSequenceAnimation(currentImage: UIImage?) {
        guard !cardAnimationImages.isEmpty else {
            // 如果沒有動畫圖片，直接顯示結果
            self.performRandomSelection()
            return
        }
        
        // 設置初始卡牌圖片
        self.centerImageView.image = cardAnimationImages[0]
        self.centerImageView.alpha = 1
        
        // 定義每張卡牌顯示的持續時間
        let singleCardDuration = animationDuration / Double(cardAnimationImages.count * 2)
        
        // 循環顯示每一張卡牌
        var delay: TimeInterval = 0
        
        // 第一階段：快速輪換卡牌
        for _ in 0..<3 { // 重複幾次使動畫更豐富
            for (index, cardImage) in cardAnimationImages.enumerated() {
                delay += singleCardDuration
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // 添加旋轉和縮放效果
                    let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromLeft]
                    
                    UIView.transition(with: self.centerImageView,
                                      duration: singleCardDuration * 0.8,
                                      options: transitionOptions,
                                      animations: {
                        self.centerImageView.image = cardImage
                        
                        // 交替縮放效果
                        let scale: CGFloat = index % 2 == 0 ? 1.05 : 0.95
                        self.centerImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
                    }, completion: nil)
                }
            }
        }
        
        // 第二階段：減慢並最終顯示隨機選擇的照片
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + singleCardDuration) {
            // 進行隨機選擇並顯示結果
            UIView.transition(with: self.centerImageView,
                              duration: 0.5,
                              options: .transitionFlipFromLeft,
                              animations: {
                self.centerImageView.transform = .identity  // 重置任何變換
            }) { _ in
                self.performRandomSelection()
            }
        }
    }

    // 執行隨機選擇並顯示結果
    private func performRandomSelection() {
        // 隨機選擇一個索引
        let randomIndex = Int.random(in: 0..<self.photos.count)
        self.selectedPhotoIndex = randomIndex
        
        // 使用翻轉動畫顯示最終選擇的照片
        UIView.transition(with: self.centerImageView,
                          duration: 0.5,
                          options: .transitionFlipFromLeft,
                          animations: {
            self.centerImageView.image = self.photos[randomIndex]
        }) { _ in
            // 動畫完成後重置狀態
            self.isAnimating = false
        }
    }
    
    // MARK: - 狀態更新
    private func updateStartButtonState() {
        let isEnabled = photos.count > 1
        startButton.isEnabled = isEnabled
        startButton.alpha = isEnabled ? 1.0 : 0.5
        
        cleanButton.isEnabled = isEnabled
        cleanButton.alpha = isEnabled ? 1.0 : 0.5
    }
    
    // MARK: - 權限檢查
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { _ in }
        default:
            break
        }
    }
    
    // MARK: - 相機和相簿呈現
    private func presentCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard status == .authorized else {
            if status == .denied {
                showPermissionAlert(for: "相機")
            } else {
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    DispatchQueue.main.async {
                        if granted {
                            self?.presentCamera()
                        }
                    }
                }
            }
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "錯誤", message: "相機無法使用")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    private func presentPhotoLibrary() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        guard status == .authorized else {
            if status == .denied {
                showPermissionAlert(for: "相簿")
            } else {
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self?.presentPhotoLibrary()
                        }
                    }
                }
            }
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    // MARK: - 警告展示
    private func showPermissionAlert(for type: String) {
        let alert = UIAlertController(
            title: "需要\(type)權限",
            message: "請在設置中允許應用訪問您的\(type)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "設置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    private func showDeleteAlert(for index: Int) {
        let alert = UIAlertController(title: "照片操作", message: "你想要做什麼？", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "刪除照片", style: .destructive) { [weak self] _ in
            self?.deletePhoto(at: index)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - 照片管理
    private func deletePhoto(at index: Int) {
        guard index < photos.count else { return }
        
        photos.remove(at: index)
        
        if photos.isEmpty {
            centerImageView.image = nil
            selectedPhotoIndex = nil
        } else if let selectedIndex = selectedPhotoIndex {
            if index == selectedIndex {
                // 如果刪除的是當前顯示的照片，則清空中心視圖
                centerImageView.image = nil
                selectedPhotoIndex = nil
            } else if index < selectedIndex {
                // 如果刪除的照片索引小於當前選中的照片，需要調整當前選中照片的索引
                selectedPhotoIndex = selectedIndex - 1
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            
            if self.photos.count < 5 {
                self.photos.append(image)
                
                // 如果是第一張照片，直接顯示在中心
                if self.photos.count == 1 {
                    self.centerImageView.image = image
                    self.selectedPhotoIndex = 0
                }
            } else {
                self.showAlert(title: "照片數量上限", message: "最多只能選擇5張照片")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.configure(with: photos[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        centerImageView.image = photos[indexPath.item]
        selectedPhotoIndex = indexPath.item
    }
}
