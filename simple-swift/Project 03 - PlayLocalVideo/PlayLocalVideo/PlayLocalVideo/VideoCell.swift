//
//  VideoCell.swift
//  PlayLocalVideo
//
//  Created by NightOwl_Thinker on 2025/12/8.
//

import UIKit

/// 轻量数据模型，值类型可拷贝，线程安全性更高
struct Video {
    let image: String
    let title: String
    let source: String
}

final class VideoCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var videoSourceLabel: UILabel!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoScreenshot: UIImageView!

    // MARK: - Identifier
    static let reuseIdentifier = "VideoCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // 可在此做一次性 UI 配置
        selectionStyle = .none
    }

    /// 统一配置入口，避免在控制器里散落赋值逻辑
    func configure(with video: Video) {
        videoScreenshot.image = UIImage(named: video.image)
        videoSourceLabel.text = video.source
        videoTitleLabel.text = video.title
    }
}
