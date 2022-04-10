//
//  MusicLibrarySearchEndpoint.swift
//  MusicLibrarySearchEndpoint
//
//  Created by Rudrank Riyam on 08/09/21.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension AppleMusicEndpoint {
    static func librarySearch(with queryItems: [URLQueryItem]) -> Self {
        AppleMusicEndpoint(library: .user, "library/search", queryItems: queryItems)
    }
}

