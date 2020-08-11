//
//  ViewController.swift
//  SpeechToText
//
//  Created by Tushna Eduljee on 10/26/19.
//  Copyright © 2019 Tushna Eduljee. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Speech

class ViewController: UIViewController, ARSCNViewDelegate, SFSpeechRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var microphoneButton: UIButton!
    
//    @IBOutlet weak var textFieldName: UITextField!
    var name: String = " "
//
//
//    @IBAction func buttonAction(sender: UIButton) {
//          //getting input from Text Field
//        name = textFieldName.text!
//        view.endEditing(true)
//
//      }
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var buttonClick: UIButton!
    
    @IBAction func buttonAction(_ sender: UIButton) {
        
               name = textField.text!
               view.endEditing(true)
    }
    
    var rotationFactor: simd_float4x4!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and1 timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        
//        let longGesture = UILongPressGestureRecognizer(target: self, action: "longTap:")
//        view.addGestureRecognizer(longGesture)
        
        
        
//        let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
//
//        microphoneButton?.isEnabled = false
//        speechRecognizer?.delegate = self
//        SFSpeechRecognizer.requestAuthorization { (authStatus) in
//            var isButtonEnabled = false
//
//            switch authStatus {  //5
//            case .authorized:
//                isButtonEnabled = true
//
//            case .denied:
//                isButtonEnabled = false
//                print("User denied access to speech recognition")
//
//            case .restricted:
//                isButtonEnabled = false
//                print("Speech recognition restricted on this device")
//
//            case .notDetermined:
//                isButtonEnabled = false
//                print("Speech recognition not yet authorized")
//
//            default:
//                isButtonEnabled = false
//                print("Speech recognition not yet authorized")
//            }
//
//            OperationQueue.main.addOperation() {
//                self.microphoneButton?.isEnabled = isButtonEnabled
//            }
//        }
    }
//
//    @IBAction func microphoneTapped(_ sender: AnyObject) {
//       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
//    @objc func longTap(rec: UILongPressGestureRecognizer) {
//        if rec.state == .ended {
//            let location: CGPoint = rec.location(in: sceneView)
//            let hits = self.sceneView.hitTest(location, options: nil)
//            guard let node = hits.first?.node else { return }
//
//            if (abs(location.x - CGFloat(node.position.x)) < 0.04 || abs(location.y - CGFloat(node.position.y)) < 0.04) {
//                node.removeFromParentNode()
//            }
//        }
//
//    }
//
    @objc func doubleTapped(rec: UITapGestureRecognizer) {
        
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
            guard let node = hits.first?.node else { return }
            
            if let tappednode = hits.first?.node {
                tappednode.removeFromParentNode()
            }
            
//            if (abs(location.x - CGFloat(node.position.x)) < 0.04 || abs(location.y - CGFloat(node.position.y)) < 0.04) {
//                node.removeFromParentNode()
//            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //view.endEditing(true)
        guard let touch = touches.first else {return}
        
        
        let result = sceneView.hitTest(touch.location(in: sceneView), types: [ARHitTestResult.ResultType.featurePoint])
        guard let hitResult = result.last else {return}
        let hitTransform = (hitResult.worldTransform)
        
        rotationFactor = hitTransform
        
        let hitVector = SCNVector3Make(hitTransform.columns.3.x, hitTransform.columns.3.y, hitTransform.columns.3.z)
        
        createBall(position: hitVector)
    }
    
    func ballText() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        view.backgroundColor = .white
        let label = UILabel(frame: CGRect(x: 0, y: 35, width: 200, height: 30))
        label.text = name
        label.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(label)
        label.textAlignment = .center
        label.textColor = .black
        return view
    }

    func createBall(position: SCNVector3) {
        let ballShape = SCNSphere(radius: 0.05)
        
        ballShape.firstMaterial?.diffuse.contents = ballText()
        let ballNode = SCNNode(geometry: ballShape)
        ballNode.position = position
        
        let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
        
        let rotateTransform = simd_mul(rotationFactor, rotate)
        ballNode.transform = SCNMatrix4(rotateTransform)

        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}


//class SFSpeechRecognizer : NSObject {
//
//}

