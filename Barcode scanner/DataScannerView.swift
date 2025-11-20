//
//  DataScannerView.swift
//  Barcode scanner
//
//  Created by Snehal Chavan on 3/24/25.
//

import Foundation
import SwiftUI
import VisionKit


// struct declaration
struct DataScannerView: UIViewControllerRepresentable {
    
    
    // Binding to pass array of items that are recognized after scanning
    @Binding var recognizedItems: [RecognizedItem]
    
    // declaring variable to pass it to dataScannerView
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    
    
    let recognizesMultipleItems: Bool
    
    
    func makeUIViewController(context: Context) ->
        DataScannerViewController {
        
        // viewcontroller variable declaraltion
            let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType], // 1
            qualityLevel: .balanced, // 2
            recognizesMultipleItems: recognizesMultipleItems, // 3
            isGuidanceEnabled: true, // 4
            isHighlightingEnabled : true  // 5
        )
        // 1 passing variable to dataScaneer View to show either text/ barcode description
        // 2 // three options ( recognition speed after scanning balanced, accurate & fast )
        // 3 // allows to recognize multiple items ( boolean )
        // 4 // text that will be displayed
        // 5 // recognized items are highlighed after scanning
        
        return vc
    }
    
    
    //
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
        //
        uiViewController.delegate = context.coordinator
        
        //uiViewController.recognizesMultipleItems = recognizesMultipleItems        // gives error as parameters are let so use hash value to explicitly modify it
        
        // start the scanning for dataScannerViewController
        try? uiViewController.startScanning()
    }
    
    // declaration of coordinator to confirm delegate sends call back after items are recognized/ removed from frame or access the scanned object after tapping on it
    func makeCoordinator() -> Coordinator{
        
        // passed the initialized parameter in class coordinator
        Coordinator(recognizedItems: $recognizedItems)
    }
    
    // function to cleanup to stop the scanning
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        
        uiViewController.stopScanning()
    }
    
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate{
        
        // biniding of recognized items is passed here
        @Binding var recognizedItems : [RecognizedItem]
        
        // initializer declaration for recognized items binding
        init(recognizedItems: Binding <[RecognizedItem]>)
        {
            // _ to access the initialized parameter
            self._recognizedItems = recognizedItems
        }
        
        // invoked when user taps on one of the scanned item function call back
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem)
        {
            print("didtapOn \(item)")
        }
        
        // invoked when new items are recognized by live feed
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem],
                         allitems: [RecognizedItem])
        {
            // Invoke notification and pass vibration after sucessfulling adding of new item
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // append the array of scanned items to the binding
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
            
        }
        
        // Invoke when user removes the scanning frame
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem],
                         allitems: [RecognizedItem])
        {
            // invoking recognized items and applying filter
            self.recognizedItems = recognizedItems.filter {
                item in !removedItems.contains(where: {$0.id == item.id })
                
            }
            print("didRemovedItemsItems \(removedItems)")
                
        }
        
        // when the scanning fails with error
        func dataScanner(_ dataScanner: DataScannerViewController, becomeUnavaiableWithError error:
                         DataScannerViewController.ScanningUnavailable) {
            
            print("become unavailable with error \(error.localizedDescription)")
            
        }
    }
            
}
