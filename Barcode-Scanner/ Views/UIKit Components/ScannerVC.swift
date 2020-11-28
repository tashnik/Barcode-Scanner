//
//  ScannerVC.swift
//  Barcode-Scanner
//
//  Created by Tashnik on 11/19/20.
//

import UIKit
import AVFoundation


enum CameraError {
  
  case invalidDeviceInput
  case invalidScannedValue
}

protocol ScannerVCDelegate: class {
  func didFindBarcode(barcode: String)
  func didSurface(error: CameraError)
}


final class ScannerVC: UIViewController {
  
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var scannerDelegate: ScannerVCDelegate?
  
  init(scannerDelegate: ScannerVCDelegate) {
    super.init(nibName: nil, bundle: nil)
    self.scannerDelegate = scannerDelegate
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCameraSession()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    guard let previewLayer = previewLayer else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    previewLayer.frame = view.layer.bounds
  }
  
  private func setupCameraSession() {
    
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    let videoInput: AVCaptureDeviceInput
    
    do {
      try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    if captureSession.canAddInput(videoInput) {
      captureSession.addInput(videoInput)
    } else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    let metaDataOutput = AVCaptureMetadataOutput()
    
    if captureSession.canAddOutput(metaDataOutput) {
      captureSession.addOutput(metaDataOutput)
      metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metaDataOutput.metadataObjectTypes = [.ean8, .ean13]
    } else {
      scannerDelegate?.didSurface(error: .invalidDeviceInput)
      return
    }
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer!.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer!)
    
    captureSession.startRunning()
  }
  
}


extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard let object = metadataObjects.first else {
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    guard let barcode = machineReadableObject.stringValue else {
      scannerDelegate?.didSurface(error: .invalidScannedValue)
      return
    }
    
    scannerDelegate?.didFindBarcode(barcode: barcode)
  }
}
