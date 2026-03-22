//
//  NewsModel.swift
//  CekFakta
//
//  Created by Heical Chandra on 09/12/25.
//

import Foundation

struct News: Identifiable, Codable {
    let id: String?
    let claim: String?
    let url: String?
    let title: String?
    let content: String?
    let classification: Classification?
    let evidence_links: [String]?
    let evidence_scraped: [EvidenceScraped]?
    let explanation: String?
    let inserted_at: String? 
    let updated_at: String?
    let author: Author?  
    let error: String?
}

struct EvidenceScraped: Codable {
    let judul: String?
    let tanggal: String?
    let sumber: String?
    let link: String?
    let content: String?
    let featured_image: String?
}

struct Classification: Codable {
    let final_label: String?
    let final_confidence: Double?
}

struct Author: Codable {
    let id: String?
    let name: String?
    let avatar_url: String?
}
