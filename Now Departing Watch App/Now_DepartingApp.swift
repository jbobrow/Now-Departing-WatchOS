//
//  Now_DepartingApp.swift
//  Now Departing WatchOS App
//
//  Created by Jonathan Bobrow on 12/29/24.
//

import SwiftUI

@main
struct NowDepartingWatchApp: App {
    @StateObject private var stationDataManager = StationDataManager()
    @StateObject private var favoritesManager = FavoritesManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(stationDataManager)
                .environmentObject(favoritesManager)
        }
        .windowToolbarLabelStyle(fixed: .automatic)
    }
}
