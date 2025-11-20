//
//  ContentView.swift
//  Barcode scanner
//
//  Created by Snehal Chavan on 3/23/25.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    
    // property wrapper
    
    @EnvironmentObject
    
    // variable to initialize viewModel
    var vm: Barcode_scanner_App_ViewModel
    
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?) ] = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    var body: some View {
        
        
        switch vm.dataScannerAcessStatus {
        case .notDetermined:
            Text(" Request for camera acess")
            
        case .cameraAcessNotGranted:
            Text("Kindly allow acess to your camera settings " )
            
        case .cameraNotAvailable:
            Text (" Your devices camera is not functional or no camera ")
            
        case .scannerAvailable:
            Text(" Scanner is Available")
            
        case .scannerNotAvailable:
            Text(" Camera is not allowed access to scan the image")
        }
    }
    
    private var mainView: some View{
        
        
        // Datascanner view in VStack
        DataScannerView(
            recognizedItems: $vm.recognizedItems,
            recognizedDataType: vm.recognizedDataType, recognizesMultipleItems: vm.recognizesMultipleItems)
        
        .background{Color.gray.opacity(0.4)}
        .ignoresSafeArea()
        
        // pasing hash value based on all parameter values
        .id(vm.DataScannerViewId)
        
        .sheet(isPresented: .constant(true)){
         
            bottomContainerView
                .background(.ultraThinMaterial)  // translucent mateerial
                .presentationDetents([.medium, .fraction(0.25)])  // 25% screen height
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled() // user cant dismiss the view
                .onAppear(){
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let controller = windowScene.windows.first?.rootViewController?.presentedViewController else{
                        return
                    }
                    
                    controller.view.backgroundColor = .clear
                }
            
        }
            
        
        .onChange(of: vm.scanType) {  _, _ in vm.recognizedItems = [] }
        .onChange(of: vm.textContentType) { _,_ in vm.recognizedItems = [] }
        .onChange(of: vm.recognizesMultipleItems) { _, _ in vm.recognizedItems = [] }
    }
    
    // Toggle button for single or multiple item scan
    private var headerView: some View{
        
        VStack{
            HStack{
                Picker(" Scan Type", selection: $vm.scanType){
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan multiple", isOn: $vm.recognizesMultipleItems)
                
            }.padding(.top)
            
            if vm.scanType == .text{
                Picker(" Text content type", selection: $vm.textContentType)
                {
                    
                    ForEach(textContentTypes, id: \.self.textContentType){ option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            
            Text( vm.headerText).padding(.top)
        }.padding(.horizontal)
    }
    
    private var bottomContainerView: some View{
        
        VStack{
            headerView
            ScrollView{
                LazyVStack( alignment: .leading, spacing: 16){
                    ForEach(vm.recognizedItems){
                        item in
                        switch item{
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? " Unknown barcode")
                            
                        case .text(let text):
                            Text( text.transcript)
                            
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
        
        
}
    

