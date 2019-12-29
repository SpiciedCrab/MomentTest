//
//  Tweets.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/27.
//  Copyright © 2019 Harly. All rights reserved.
//

import Foundation

struct Tweets: MomentCodable {
    var list: [Tweet] = []
}

struct Tweet: MomentCodable {
    var uniqueId: String = UUID().uuidString
    var content: String = ""
    var sender: Sender?
    var images: [ImageInfo] = []
    var comments: [Comment] = []
}

struct Sender: MomentCodable {
    var username: String = ""
    var nick: String = ""
    var avatar: String?
    var profileImage: String?
    
    enum CodingKeys : String, CodingKey {
        case username = "username"
        case nick
        case avatar
        case profileImage = "profile-image"
    }
    
    static func buildDefault() -> Sender {
        return Sender(username: "正在载入...", nick: "正在载入...", avatar: nil, profileImage: nil)
    }
}

struct Comment: MomentCodable {
    var content: String = ""
    var sender: Sender?
}

struct ImageInfo: MomentCodable {
    var url: String = ""
}
