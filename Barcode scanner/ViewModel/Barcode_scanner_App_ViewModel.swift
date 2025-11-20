//
//  Barcode scanner Barcode_scanner_App_ViewModel.swift
//  Barcode scanner
//
//  Created by Snehal Chavan on 3/23/25.
//

import Foundation
import AVKit
import VisionKit
import SwiftUI

enum ScanType: String {
    case barcode
    case text
}

enum DataScannerAcessStatusType{
    case notDetermined
    case cameraAcessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor

final class Barcode_scanner_App_ViewModel: ObservableObject{
    
    // property to check the status of app ifit is scanning or no
    @Published var dataScannerAcessStatus: DataScannerAcessStatusType = .notDetermined
    
    // recognized items array intitialized with empty array
    // ( computing the recognized data type based on the scanType and textContext type is performed)
    @Published var recognizedItems: [RecognizedItem] = []
    
    // property for scantype as barcode ( by default selected)
    @Published var scanType: ScanType = .barcode
    
    // for scan type text is optional to scan all available texts in frame (optional by default)
    @Published var textContentType: DataScannerViewController.TextContentType?
    
    // bool variable to track if we want to scan multiple items at once
    @Published var recognizesMultipleItems = true
    
    
    // variable to generate recognized datatype based on published property
    var recognizedDataType:
    DataScannerViewController.RecognizedDataType{
        
        // check if scan type is barcode return it else pass the textcontent
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    
    var headerText: String{
        if recognizedItems.isEmpty{
            return " Scanning \(scanType.rawValue)"
        }
        else{
            return " Recognized \(recognizedItems.count) items(s)"
        }
    }
    
    var DataScannerViewId: Int{
        
        var hasher = Hasher()
        
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        
        if let textContentType{
            
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    // declaration of variable to check if scanner is avaiable
    private var isScannerAvailable: Bool{
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    //
    func requestDataScannerAcessStatus() async{
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            dataScannerAcessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video){
            
            // User allows acess to camera
        case .authorized:
            // assign scanner with value after checking if the scanner is available
            dataScannerAcessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
                
        case .restricted, .denied:
            // user denies acess to the camera
            dataScannerAcessStatus = .cameraAcessNotGranted
            
            
            // camera is not found
        case .notDetermined:
            
            // wait if the user has gone to changes settongs and provide camera acess, again check if access is granted
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            
            if granted{
                dataScannerAcessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            }
            else{
                dataScannerAcessStatus = .cameraAcessNotGranted
            }
            
        default: break
        }
    }
}
