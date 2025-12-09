//
//  InterestCollecitonViewCell.swift
//  CarouselEffect
//
//  Created by NightOwl_Thinker on 2025/12/9.
//

import UIKit

class InterestCollecitonViewCell: UICollectionViewCell {
    // Storyboard/XIB 初始化路径必须实现 init?(coder:)，required 代表子类也必须实现
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBOutlet weak var Titlelabel: UILabel!   // IBOutlet 默认隐式解包，依赖 Storyboard 连接保证非 nil
    @IBOutlet weak var image: UIImageView!
    
    // 使用 didSet 在数据变更时自动刷新 UI，Swift 属性观察者示例
    var interestModel : InterestModel?{
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        guard let model = interestModel else {
            // 模型为 nil 时重置 UI，避免复用时出现脏数据
            image.image = nil
            Titlelabel.text = nil
            return
        }
        image.image = model.featuredImage
        Titlelabel.text = model.title
    }
    
    private func commonInit() {
        // 代码 & XIB 初始化共用的外观配置
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // layoutSubviews 可能频繁调用，尽量保持轻量
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
    
    // Cell 复用时重置内容，避免显示上一个 Cell 的残留数据
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
        Titlelabel.text = nil
    }
}
