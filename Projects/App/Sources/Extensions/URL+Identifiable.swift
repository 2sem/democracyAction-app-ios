//
//  URL+Identifiable.swift
//  democracyaction
//
//  Makes URL conform to Identifiable for use with .sheet(item:)
//

import Foundation

extension URL: Identifiable {
    public var id: String {
        absoluteString
    }
}
