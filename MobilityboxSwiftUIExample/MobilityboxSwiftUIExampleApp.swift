//
//  MobilityboxSwiftUIExampleApp.swift
//  MobilityboxSwiftUIExample
//
//  Created by Tim Krusch on 24.06.22.
//

import SwiftUI
import Mobilitybox

@main
struct MobilityboxSwiftUIExampleApp: App {
    
    init() {
        Mobilitybox.setup(apiConfig: MobilityboxAPI.Config(apiURL: "https://api.themobilitybox.com/v2"))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
