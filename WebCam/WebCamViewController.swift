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
    
    init(addGestures: Bool) {
        
        super.init(nibName: nil, bundle: nil)
        
        if addGestures {
            addGesturesToWebCam()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setConfigs()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Landscape
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        _isFront = !_isFront
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
        
        let translation = sender.translationInView(self.view?.superview)
        
        self.view.center = CGPointMake(self.view.center.x + translation.x, self.view.center.y + translation.y)
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateWebCam(sender: UIRotationGestureRecognizer) {
        
        self.view.transform = CGAffineTransformRotate(self.view.transform, sender.rotation)
        sender.rotation = 0.0
    }
    
    func resizeWebCam(sender: UIPinchGestureRecognizer) {
        
        self.view.transform = CGAffineTransformScale(self.view.transform, sender.scale, sender.scale)
        sender.scale = 1
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
            
            return AVCaptureDevicePosition.Back
        }
        else {
            
            return AVCaptureDevicePosition.Front
        }
    }
    
    private func setConfigs() {
        
        //Set WebCamBounds
        let x = UIScreen.mainScreen().bounds.height/4
        let y = UIScreen.mainScreen().bounds.width/2
        
        //Make it 16:9 aspect ratio
        let rect = CGRectMake(x, y, 300.0, 169.0)
        
        self.view.backgroundColor = UIColor.blackColor()
        self.view.frame = rect
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.setCamOrientation), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    // MARK: - WebCam Gestures
    
    private func addGesturesToWebCam() {
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapReceived(_:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.moveWebCam(_:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.resizeWebCam(_:)))
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(self.rotateWebCam(_:)))
        
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 2
        
        pan.delaysTouchesBegan = false
        pinch.delaysTouchesBegan = false
        rotation.delaysTouchesBegan = false
        
        pan.delaysTouchesEnded = true
        pinch.delaysTouchesEnded = true
        rotation.delaysTouchesEnded = true
        
        pan.cancelsTouchesInView = true
        pinch.cancelsTouchesInView = true
        rotation.cancelsTouchesInView = true
        
        self.view.addGestureRecognizer(pan)
        self.view.addGestureRecognizer(pinch)
        self.view.addGestureRecognizer(rotation)
    }
}