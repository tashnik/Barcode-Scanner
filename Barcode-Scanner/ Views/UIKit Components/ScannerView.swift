//
//  ScannerView.swift
//  Barcode-Scanner
//
//  Created by Tashnik on 11/19/20.
//

import SwiftUI

struct ScannerView: UIViewControllerRepresentable {
  
  @Binding var scannedCode: String
  @Binding var alertItem: AlertItem?
  
  func makeCoordinator() -> Coordinator {
    Coordinator(scannerView: self)
  }
  
  
  func makeUIViewController(context: Context) -> ScannerVC {
    ScannerVC(scannerDelegate: context.coordinator)
  }
  
  func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {  }
  
  final class Coordinator: NSObject, ScannerVCDelegate {
    
    private let scannerView: ScannerView
    
    init(scannerView: ScannerView) {
      self.scannerView = scannerView
    }
    
    func didFindBarcode(barcode: String) {
      scannerView.scannedCode = barcode
    }
    
    func didSurface(error: CameraError) {
      
      switch error {
      case .invalidDeviceInput:
        scannerView.alertItem = AlertContext.invalidDeviceInput
      case .invalidScannedValue:
        scannerView.alertItem = AlertContext.invalidScannedType
      }
    }
    
  }
}

