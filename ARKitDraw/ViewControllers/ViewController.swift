//
//  ViewController.swift
//  ARKitDraw
//
//  Created by Felix Lapalme on 2017-06-07.
//  Copyright © 2017 Felix Lapalme. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ChromaColorPicker

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var button: UIButton!
    //@IBOutlet weak var colorPicker: ChromaColorPicker!
    
    var previousPoint: SCNVector3?
    var lineColor: UIColor = .white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

}

extension ViewController {
    
    func configureUI() {
        let colorPicker = ChromaColorPicker(frame: CGRect(x: 0.0, y: 0.0, width: 200.0, height: 200.0))
        colorPicker.delegate = self
        colorPicker.padding = 5.0
        colorPicker.stroke = 3.0
        colorPicker.hexLabel.isHidden = true
        colorPicker.layout()
        view.addSubview(colorPicker)
    }
}

 
extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else { return }
        guard let button = button else { return }
        
        let mat = pointOfView.transform
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        let currentPosition = pointOfView.position + (dir * 0.1)
        
        // move to main thread
        if button.isHighlighted {
            if let previousPoint = previousPoint {
                let twoPointsNode = SCNNode()
                _ = twoPointsNode.buildLineInTwoPointsWithRotation(
                    from: previousPoint,
                    to: currentPosition,
                    radius: 0.002,
                    color: lineColor)
                
                sceneView.scene.rootNode.addChildNode(twoPointsNode)
            }
        }
        previousPoint = currentPosition
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("error launching ARSession: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("session was interrupted ended")
    }
}

extension ViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        print(color)
        lineColor = color
    }
}
