# PickUp-RandomSelector
A photo-based random picker for daily decisions. Built with Swift.

# PickUp - 隨機圖片抽選 App 🎴

PickUp 是一款簡單有趣的隨機選圖 App，讓你從相簿或拍照中選擇多張圖片，隨機挑選其中一張作為「命運結果」🎯  
適合用於塔羅選牌、午餐決定、情境抽籤、創作遊戲等。

---

## 📱 功能介紹

- 從相機或相簿匯入多張圖片
- 顯示縮圖列表，可預覽與刪除
- 達兩張以上即可進行抽選
- 動畫方式展示抽選結果
- 支援橫式排版與動態更新 UI

---

## 🧑‍💻 技術重點

- UIKit 純程式碼開發（未使用 Storyboard）
- 使用 `UIImagePickerController` 製作照片／相簿選取邏輯
- 透過 `UICollectionView` 動態呈現選取圖片縮圖
- 自訂 Cell `PhotoCell.swift` 實作圖像與樣式
- 完整控制 VC 切換、畫面更新、資料流
- 全畫面程式配置 Layout、事件與 UI 狀態管理

---

## 🎯 使用場景

- 塔羅選牌輔助工具
- 晚餐不知道吃什麼時候的選擇器
- 團體活動的決策遊戲
- 創作者靈感圖像抽卡工具

---

## 📸 畫面預覽（建議加圖）

> 你可加入抽選前、縮圖清單、抽出結果等 3 張圖放在這

---

## 🤖 創作背景

本 App 為作者個人構思，並透過與 AI 協作完成初版 MVP。  
過程中由作者提出使用場景、操作流程與互動需求，結合 UIKit 功能與 AI 引導協作，實作成一款輕量化但實用的選擇工具。

---

## 📌 後續可優化項目（可列出 TODO）


---

## 📂 專案架構（主要檔案）
|- AppDelegate.swift
|- SceneDelegate.swift
|- MainViewController.swift  // 主邏輯
|- HomeViewController.swift // 初始畫面
|- PhotoCell.swift          // 自訂圖片 cell
|- Info.plist
