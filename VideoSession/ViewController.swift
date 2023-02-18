//
//  ViewController.swift
//  VideoSession
//
//  Created by Ángel González on 18/02/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var videoSesion:AVCaptureSession!
    var preview: AVCaptureVideoPreviewLayer!
    
    var btnCamara = UIButton(type: .custom)
    var capturando: Bool = false {
        didSet { // se desencadena cuando la variable tiene un nuevo valor
            if capturando {
                btnCamara.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
            else {
                btnCamara.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnCamara.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        btnCamara.frame = CGRect(x:view.center.x, y:view.bounds.height - 80, width: 60, height: 60)
        view.addSubview(btnCamara)
        btnCamara.addTarget(self, action:#selector(pausarGrabar), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoSesion = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        if (videoSesion.canAddInput(videoInput)) {
            videoSesion.addInput(videoInput)
        }
        else {
            failed()
            return
        }
        let metadataOutput = AVCaptureMetadataOutput()
        if (videoSesion.canAddOutput(metadataOutput)) {
            videoSesion.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .code39]
            
            // configurar el preview para que el usuario vea lo que esta "viendo" la camara
            preview = AVCaptureVideoPreviewLayer(session: videoSesion)
            preview.frame = CGRect(x:20, y:50, width:view.frame.width - 40, height:view.frame.height - 140)
            preview.videoGravity = .resizeAspectFill
        }
        else {
            failed()
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        stopSesion()
        capturando = false
        if let metadataObject = metadataObjects.first {
            guard let objetoDetectado = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let textoEnElObjeto = objetoDetectado.stringValue else { return }
            // encontre un codigo... y ahora que? TODO: presentar el resultado en un Alert
            print ()
            let ac = UIAlertController(title: "Yeiii", message:"encontré \(textoEnElObjeto)", preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default) {
                alertaction in
                // Este codigo se ejecutará cuando el usuario toque el botón
            }
            ac.addAction(action)
            self.present(ac, animated: true)
        }
    }
    
    func stopSesion () {
        videoSesion.stopRunning()
        preview.removeFromSuperlayer()
    }
    
    @objc func pausarGrabar () {
        if capturando {
            stopSesion()
        }
        else {
            // agregar el preview
            view.layer.addSublayer(preview)
            // empezar a capturar
            videoSesion.startRunning()
        }
        capturando = !capturando
    }

    func failed() {
      let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
      ac.addAction(UIAlertAction(title: "OK", style: .default))
      present(ac, animated: true)
      videoSesion = nil
  }
}

