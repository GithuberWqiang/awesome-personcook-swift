//
//  ViewController.swift
//  PlayLocalVideo
//
//  Created by NightOwl_Thinker on 2025/12/8.
//

import UIKit
import AVKit

// final 可避免被继承，略减动态派发开销
final class ViewController: UIViewController {

    // MARK: - IBOutlet
    // 使用 weak 避免循环引用，典型的 UIKit 连接写法
    @IBOutlet weak var videoTableView: UITableView!

    // MARK: - Properties
    // lazy 能按需创建播放控制器，避免过早初始化
    private lazy var playerViewController = AVPlayerViewController()
    // 可重用的播放器实例，便于后续扩展（如暂停/恢复）
    private var player: AVPlayer?

    // 使用 let 保持数据不可变，降低被外部修改的风险
    private let videos: [Video] = [
        // 同一 target 下无需 import 即可直接使用 Video
        Video(image: "videoScreenshot01",
              title: "Introduce 3DS Mario",
              source: "Youtube - 06:32"),
        Video(image: "videoScreenshot02",
              title: "Emoji Among Us",
              source: "Vimeo - 3:34"),
        Video(image: "videoScreenshot03",
              title: "Seals Documentary",
              source: "Vine - 00:06"),
        Video(image: "videoScreenshot04",
              title: "Adventure Time",
              source: "Youtube - 02:39"),
        Video(image: "videoScreenshot05",
              title: "Facebook HQ",
              source: "Facebook - 10:20"),
        Video(image: "videoScreenshot06",
              title: "Lijiang Lugu Lake",
              source: "Allen - 20:30")
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.delegate = self
        videoTableView.dataSource = self
    }

    // MARK: - Actions
    @IBAction func palyButtonClicked(_ sender: UIButton) {
        // guard + URL API 避免强制解包，提升健壮性
        guard let url = Bundle.main.url(forResource: "emoji zone", withExtension: "mp4") else {
            assertionFailure("本地视频资源不存在")
            return
        }

        let player = AVPlayer(url: url)
        self.player = player
        playerViewController.player = player

        present(playerViewController, animated: true) {
            player.play()
        }
    }

}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        // 单列表仅需一个 section，避免多余空区
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: VideoCell.reuseIdentifier, for: indexPath) as? VideoCell else {
            fatalError("无法创建 VideoCell")
            
        }

        let video = videos[indexPath.row]
        cell.configure(with: video)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        220
    }

}
