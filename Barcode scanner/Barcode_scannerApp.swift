//
//  Barcode_scannerApp.swift
//  Barcode scanner
//
//  Created by Snehal Chavan on 3/23/25.
//

// Entry point for the app

import SwiftUI

@main
struct Barcode_scannerApp: App {
    
    // StateObject vm declaration
    @StateObject private
    
    // initialization of viewmodel
    var vm = Barcode_scanner_App_ViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // modifier declaration and passing the vm variable
                .environmentObject(vm)
            
            // When user launches the app first time this is invoked to fetch the status of the camera status
                .task {
                    await vm.requestDataScannerAcessStatus()
                }
        }
    }
}
