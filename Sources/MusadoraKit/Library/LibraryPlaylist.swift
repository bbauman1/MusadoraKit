//
//  LibraryPlaylist.swift
//  LibraryPlaylist
//
//  Created by Rudrank Riyam on 14/08/21.
//

import MusicKit
import MediaPlayer

public extension MusadoraKit {
  /// Fetch a playlist from the user's library by using its identifier.
  /// - Parameters:
  ///   - id: The unique identifier for the playlist.
  /// - Returns: `Playlist` matching the given identifier.
  static func libraryPlaylist(id: MusicItemID) async throws -> Playlist {
    let request = MusicLibraryResourceRequest<Playlist>(matching: \.id, equalTo: id)
    let response = try await request.response()

    guard let playlist = response.items.first else {
      throw MusadoraKitError.notFound(for: id.rawValue)
    }
    return playlist
  }

  /// Fetch all playlists from the user's library in alphabetical order.
  /// - Parameters:
  ///   - limit: The number of playlists returned.
  /// - Returns: `Playlists` for the given limit.
  static func libraryPlaylists(limit: Int? = nil) async throws -> Playlists {
    var request = MusicLibraryResourceRequest<Playlist>()
    request.limit = limit
    let response = try await request.response()
    return response.items
  }

  /// Fetch multiple playlists from the user's library by using their identifiers.
  /// - Parameters:
  ///   - ids: The unique identifiers for the playlists.
  /// - Returns: `Playlists` matching the given identifiers.
  static func libraryPlaylists(ids: [MusicItemID]) async throws -> Playlists {
    let request = MusicLibraryResourceRequest<Playlist>(matching: \.id, memberOf: ids)
    let response = try await request.response()
    return response.items
  }

#if compiler(>=5.7)
  @available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
  @available(macOS, unavailable)
  @available(macCatalyst, unavailable)
  static var libraryPlaylistsCount: Int {
    get async throws {
      let request = MusicLibraryRequest<Playlist>()
      let response = try await request.response()
      return response.items.count
    }
  }
#else
  @available(macOS, unavailable)
  @available(macCatalyst, unavailable)
  @available(tvOS, unavailable)
  @available(watchOS, unavailable)
  static var libraryPlaylistsCount: Int {
    get async throws {
      if let items = MPMediaQuery.playlists().items {
        return items.count
      } else {
        throw MediaPlayError.notFound(for: "playlists")
      }
    }
  }
#endif

  /// Add a playlist to the user's library by using its identifier.
  ///
  /// - Parameters:
  ///   - id: The unique identifier for the playlist.
  /// - Returns: `Bool` indicating if the insert was successfull or not.
  static func addPlaylistToLibrary(id: MusicItemID) async throws -> Bool {
    let request = MusicAddResourcesRequest([(item: .playlists, value: [id])])
    let response = try await request.response()
    return response
  }

  /// Add multiple playlists to the user's library by using their identifiers.
  ///
  /// - Parameters:
  ///   - ids: The unique identifiers for the playlists.
  /// - Returns: `Bool` indicating if the insert was successfull or not.
  static func addPlaylistsToLibrary(ids: [MusicItemID]) async throws -> Bool {
    let request = MusicAddResourcesRequest([(item: .playlists, value: ids)])
    let response = try await request.response()
    return response
  }

}

#if compiler(>=5.7)
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
@available(macCatalyst, unavailable)
public extension MusadoraKit {
  /// Fetch recently added playlists from the user's library sorted by the date added.
  ///
  /// - Parameters:
  ///   - limit: The number of playlists returned.
  /// - Returns: `Playlists` for the given limit.
  static func recentlyAddedPlaylists(limit: Int = 10, offset: Int = 0) async throws -> Playlists {
    var request = MusicLibraryRequest<Playlist>()
    request.limit = limit
    request.offset = offset
    request.sort(by: \.libraryAddedDate, ascending: false)
    let response = try await request.response()
    return response.items
  }

  /// Fetch recently played playlists from the user's library sorted by the date added.
  ///
  /// - Parameters:
  ///   - limit: The number of playlists returned.
  /// - Returns: `Playlists` for the given limit.
  static func recentlyLibraryPlayedPlaylists(limit: Int = 0, offset: Int = 0) async throws -> Playlists {
    var request = MusicLibraryRequest<Playlist>()
    request.limit = limit
    request.offset = offset
    request.sort(by: \.lastPlayedDate, ascending: false)
    let response = try await request.response()
    return response.items
  }
}
#endif

// MARK: - Creating/Editing Playlists

struct LibraryPlaylistCreationRequest: Codable {
  /// (Required) A dictionary that includes strings for the name and description of the new playlist.
  var attributes: Attributes

#warning("TODO: ADD RELATIONSHIPS")

  struct Attributes: Codable {
    /// (Required) The name of the playlist.
    var name: String

    /// The description of the playlist.
    var description: String?
  }
}

public extension MusadoraKit {
#warning("TODO: OPTION TO ADD TRACKS")

  /// Creates a playlist in the user’s music library.
  ///
  /// - Parameters:
  ///   - name: The name of the playlist.
  ///   - description: An optional description of the playlist.
  /// - Returns: The newly created playlist.
  static func createPlaylist(name: String, description: String? = nil) async throws -> Playlist {
    let url = URL(string: "https://api.music.apple.com/v1/me/library/playlists")

    guard let url = url else { throw URLError(.badURL) }

    let creationRequest = LibraryPlaylistCreationRequest(attributes: .init(name: name, description: description))
    let data = try JSONEncoder().encode(creationRequest)

    let request = MusicDataPostRequest(url: url, data: data)
    let response = try await request.response()

    let playlists = try JSONDecoder().decode(Playlists.self, from: response.data)
    
    guard let playlist = playlists.first else {
      throw MusadoraKitError.notFound(for: name)
    }

    return playlist
  }
}
