//
//  InterestModel.swift
//  CarouselEffect
//
//  Created by NightOwl_Thinker on 2025/12/9.
//

import UIKit

class InterestModel {
    // Swift 默认存储属性需在初始化前全部赋值；这里用显式初始化保证安全
    var title: String = ""
    var description: String = ""
    var featuredImage: UIImage!
    var numberOfMembers = 0
    var numberofPosts = 0
    
    // 便利的指定初始化方法，参数使用外部参数名，便于可读性
    init(title: String, description: String, featuredImage: UIImage!) {
        self.title = title
        self.description = description
        self.featuredImage = featuredImage
        numberofPosts = 1
        numberOfMembers = 1
    }
    
    // MARK: - Static factory
    // 类方法创建假数据，便于演示；真实项目可替换为网络/本地数据源
    static func createInterests() -> [InterestModel] {
        return [
            InterestModel(title: "Hello there, i miss u.", description: "We love backpack and adventures! We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "hello")!),
            InterestModel(title: "🐳🐳🐳🐳🐳", description: "We love romantic stories. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "dudu")!),
            InterestModel(title: "Training like this, #bodyline", description: "Create beautiful apps. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "bodyline")!),
            InterestModel(title: "I'm hungry, indeed.", description: "Cars and aircrafts and boats and sky. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "wave")!),
            InterestModel(title: "Dark Varder, #emoji", description: "Meet life with full presence. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "darkvarder")!),
            InterestModel(title: "I have no idea, bitch", description: "Get up to date with breaking-news. We walked to Antartica yesterday, and camped with some cute pinguines, and talked about this wonderful app idea. 🐧⛺️✨", featuredImage: UIImage(named: "hhhhh")!),
        ]
    }
}
