//
//  CamViewController.swift
//  WebCamApp
//
//  Created by Douglas Mandarino on 4/4/16.
//  Copyright © 2016 Douglas. All rights reserved.
//

import UIKit
import AVFoundation

class WebCamViewController: UIViewController
{
    
// MARK: - Public & ReadOnly Properties
    
    private var _captureSession: AVCaptureSession!
    private var _previewLayer: AVCaptureVideoPreviewLayer!
    private var _captureDevice: AVCaptureDevice!
    
    private var _isFront = false

// MARK: - Initializers
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setConfigs()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
// MARK: - Public Methods
    
    func startCam() {
        
        let devicePosition = returnDevicePosition()
        
        _captureSession = AVCaptureSession()
        _captureSession!.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices {
            
            if(device.position == devicePosition) {
                
                _captureDevice = device as? AVCaptureDevice
                
                if _captureDevice != nil {
                    
                    beginSession()
                }
            }
        }
    }
    
    func doubleTapReceived(sender: UITapGestureRecognizer) {

        _captureSession = nil
        _captureDevice = nil
        _previewLayer = nil
        
        startCam()
    }
    
    func setCamOrientation() {
        
        switch (UIDevice.currentDevice().orientation) {
            
            case .LandscapeRight:
                _previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
                break
            case .LandscapeLeft:
                _previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
                break
            default:
                break
        }
    }
    
// MARK: - Private Methods
    
    private func beginSession() {
        
        let err : NSError? = nil
        
        do {
            try _captureSession!.addInput(AVCaptureDeviceInput(device: _captureDevice))
            
        } catch {
            print("error: \(err?.localizedDescription)")
        }
        
        _previewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
        _previewLayer?.frame = self.view.bounds
        
        setCamOrientation()
        
        _captureSession!.startRunning()
        
        self.view.layer.addSublayer(_previewLayer!)
    }
    
    private func returnDevicePosition() -> AVCaptureDevicePosition {
        
        if _isFront {
            
            _isFront = false
            return AVCaptureDevicePosition.Back
        }
        else {
            
            _isFront = true
            return AVCaptureDevicePosition.Front
        }
    }
    
    private func setConfigs() {
    
        self.view.backgroundColor = UIColor.blackColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.setCamOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        setTapGesture()
    }
    
    private func setTapGesture() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapReceived(_:)))
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
    }
}