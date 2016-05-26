//
//  CamViewController.swift
//  WebCamApp
//
//  Created by Douglas Mandarino on 5/26/16.
//  Copyright © 2016 Douglas. All rights reserved.
//

import UIKit
import AVFoundation

class WebCamViewController: UIViewController {
    
    // MARK: - Properties
    
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
            case .LandscapeLeft:
                _previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            case .Portrait:
                _previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
            case .PortraitUpsideDown:
                _previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            default:
                break
        }
    }
    
    func moveWebCam(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self.view)
        
        self.view.center = CGPointMake(self.view.center.x + translation.x, self.view.center.y + translation.y)
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateWebCam(sender: UIRotationGestureRecognizer) {
        
        self.view.transform = CGAffineTransformRotate(self.view.transform, sender.rotation)
    }
    
    func resizeWebCam(sender: UIPinchGestureRecognizer) {
        
        self.view.transform = CGAffineTransformScale(self.view.transform, sender.scale, sender.scale)
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
        
        let x = UIScreen.mainScreen().bounds.height/4
        let y = UIScreen.mainScreen().bounds.width/2
        
        let rect = CGRectMake(x, y, 300.0, 169.0)
        
        self.view.backgroundColor = UIColor.blackColor()
        self.view.frame = rect
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.setCamOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        addGesturesToWebCam()
    }
    
    // MARK: - WebCam Gestures
    
    private func addGesturesToWebCam() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapReceived(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.moveWebCam(_:)))
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeWebCam(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateWebCam(_:)))
        
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        
        panGesture.delaysTouchesBegan = false
        pinchGesture.delaysTouchesBegan = false
        rotationGesture.delaysTouchesBegan = false
        
        panGesture.delaysTouchesEnded = true
        pinchGesture.delaysTouchesEnded = true
        rotationGesture.delaysTouchesEnded = true
        
        panGesture.cancelsTouchesInView = true
        pinchGesture.cancelsTouchesInView = true
        rotationGesture.cancelsTouchesInView = true
        
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(pinchGesture)
        self.view.addGestureRecognizer(rotationGesture)
    }
}