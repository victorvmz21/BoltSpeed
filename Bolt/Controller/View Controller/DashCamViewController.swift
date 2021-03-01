//
//  DashCamViewController.swift
//  Bolt
//
//  Created by Victor Monteiro on 9/20/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import ReplayKit

class DashCamViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var firstLayerSpeedView: UIView!
    @IBOutlet weak var secondLayerSpeedView: UIView!
    @IBOutlet weak var thirdLayerSpeedView: UIView!
    @IBOutlet weak var fourthLayerSpeedView: CustomDashedView!
    @IBOutlet weak var previewVideo: UIView!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var menuBackground: CustomViewRotationDesignable!
    @IBOutlet weak var videoRecordButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var recordingView: UIView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var metricButton: UIButton!
    @IBOutlet weak var screenShotLabel: CustomLabelRotationDesignable!
    
    //MARK: Properties
    var locationManager = CLLocationManager()
    var rotate90Degrees = CGAffineTransform(rotationAngle: -.pi / 2)
    var speedMultiplier: Double = 0.0
    var captureSession: AVCaptureSession!
    var stillImageOutput =  AVCapturePhotoOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    let recordingDate = Date()
    var isRecording = false
    var isMPH = false
    let recorder = RPScreenRecorder.shared()
    var isBackCamera = true
    var captureDevice: AVCaptureDevice?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settingUpView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SpeedTrackController.shared.updateDriverLocation(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - IBActions
    @IBAction func recordVideoButtonTapped(_ sender: UIButton) {
        videoRecordButton.setImage(isRecording ? UIImage(systemName: "video.fill") : UIImage(systemName: "pause.fill"), for: .normal)
        recordingScreen()
    }
    
    @IBAction func screenShotButtonTapped(_ sender: UIButton) {
        takeScreenshot()
    }
    
    @IBAction func switchCameraButtonTapped(_ sender: UIButton) {
        isBackCamera = !isBackCamera
        settinUpCaptureSession()
    }
    
    @IBAction func metricSpeedButtonTapped(_ sender: UIButton) {
        isMPH = !isMPH
        UserDefaults.standard.set(isMPH, forKey: "isMPH")
        Haptic.shared.generateHaptic(style: .medium)
        settingSpeedType()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Methods
    func settingUpView() {
        firstLayerSpeedView.roundView()
        secondLayerSpeedView.roundView()
        thirdLayerSpeedView.roundView()
        fourthLayerSpeedView.roundView()
        secondLayerSpeedView.layer.borderColor = UIColor.systemBlue.cgColor
        secondLayerSpeedView.layer.borderWidth = 4
        firstLayerSpeedView.transform = rotate90Degrees
        settinUpCaptureSession()
        timeStampLabel.transform = rotate90Degrees
        self.menuBackground.layer.cornerRadius = 20
        videoRecordButton.roundView()
        switchCameraButton.roundView()
        closeButton.roundView()
        timeStampLabel.text = recordingDate.dateAsString()
        screenShotLabel.alpha = 0.0
        screenShotLabel.layer.cornerRadius = 15
        screenShotLabel.layer.masksToBounds = true
        settingSpeedType()
    }
    
    func settingSpeedType() {
        let defaultMultiplier = UserDefaults.standard.bool(forKey: "isMPH")
        print(defaultMultiplier)
        speedMultiplier = defaultMultiplier ? 2.2369 : 3.6
        metricButton.setTitle(defaultMultiplier ? "MPH" : "KMH", for: .normal)
    }
    
    func recordingScreen() {
        isRecording = !isRecording
        self.recordingView.alpha = 0.0
        self.recordingView.layer.borderWidth = 3.0
        self.recordingView.layer.borderColor = UIColor.red.cgColor
        self.recordingView.layer.cornerRadius = 35
        self.recordingView.layer.masksToBounds = true
        
        if isRecording {
            UIView.animateKeyframes(withDuration: 0.7, delay: 0.0, options: [.repeat, .autoreverse], animations: { self.recordingView.alpha = 1.0 }, completion: nil)
            
            startRecording()
        } else {
            self.recordingView.alpha = 0.0
            stopRecording()
        }
    }
    
    func getFrontCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
    }
    
    func getBackCamera() -> AVCaptureDevice?{
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
    }
    
    func settinUpCaptureSession() {
        
        //setting session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        //setting camera
        do {
            
            if isBackCamera {
                captureDevice = getBackCamera()
            } else {
                captureDevice = getFrontCamera()
            }
            guard let captureDevice = captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: captureDevice)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                self.stillImageOutput.isHighResolutionCaptureEnabled = true
                setupLivePreview()
            }
            
            
        } catch let error {
            print("Error unable to initialize back camera: \(error.localizedDescription)")
        }
    }
    
    func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        self.previewVideo.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.main.async {
            self.captureSession.startRunning()
        }
        
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.previewVideo.bounds
        }
    }
    
    //MARK: - Start & Stop Recording
    func startRecording() {
        if recorder.isAvailable {
            recorder.isMicrophoneEnabled = true
            recorder.startRecording { error in
                if let error = error { print(error.localizedDescription) }
            }
        } else {
            self.presentAlert(alertType: .alert, title: "Screen Record Failed", message: "This device doesn't support screen recording")
        }
        
    }
    
    func stopRecording() {
        let recorder = RPScreenRecorder.shared()
        recorder.delegate = self
        
        recorder.stopRecording { [weak self] (preview, error) in
            if let unwrappedPreview = preview {
                unwrappedPreview.previewControllerDelegate = self
                self?.recordingView.alpha = 0.0
                self?.videoRecordButton.setImage(UIImage(systemName: "video.fill"), for: .normal)
                self?.present(unwrappedPreview, animated: true)
            }
        }
    }
    
    //MARK: - Take Screen Shot
    func takeScreenshot()  {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        UIView.animate(withDuration: 1.3) {
            self.screenShotLabel.alpha = 0.8
        } completion: { _ in
            self.screenShotLabel.alpha = 0.0
        }

    }
    
    @objc func enterForeground() {
        recordingView.alpha = 0.0
        recordingScreen()
    }
}

extension DashCamViewController: CLLocationManagerDelegate, RPPreviewViewControllerDelegate, RPScreenRecorderDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Getting Speed
        guard var speed = locations.last?.speed else { return }
        
        //Converting Speed into MPH or KMP
        speed = speed * speedMultiplier
        
        //Validating Speed
        if speed <= 0  {
            speedLabel.text = "0"
        }  else if speed > 240 {
            speedLabel.text = "240"
        } else if speed > 0.5 {
            speedLabel.text = "\(Int(speed + 1))"
        }
    }
}

extension DashCamViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageDate = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageDate) else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(handlingImageError) , nil)
    }
    
    @objc func handlingImageError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error =  error {
            print(error.localizedDescription)
        } else {
            print("photo saved successfully.")
        }
       }
}
