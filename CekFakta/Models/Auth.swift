//
//  Auth.swift
//  CekFakta
//
//  Created by Heical Chandra on 18/12/25.
//

struct AuthResponse: Codable {
    let access_token: String
    let refresh_token: String
    let user: User
}

struct User: Codable {
    let id: String
    let email: String
    let name: String?
    let avatar_url: String?
    let role: String?
}


struct RefreshResponse: Decodable {
    let access_token: String
}

struct SignUpResponse: Decodable {
    let user_id: String
    let email: String
    let name: String?
}

struct UpdateProfileRequest: Encodable {
    let name: String?
    let avatar_url: String?
    let email: String?
    let password: String?
}

struct UploadResponse: Codable {
    let avatar_url: String
}
