//
//  ViewController.swift
//  AR-Ruler
//
//  Created by Young Sup Shin on 2018-06-13.
//  Copyright © 2018 Youngsup Shin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var points = [SCNNode]() // store the starting point and ending point
    var textNode = SCNNode() // store the text
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // we need to refresh for new measurement
        if points.count >= 2 {
            for point in points {
                point.removeFromParentNode()
            }
            points = [SCNNode]()
        }
        
        // get the touched location by the user and add a point on scene at that place
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addPoint(location: hitResult)
            }
        }
    }
    
    func addPoint(location hitResult : ARHitTestResult) {
        // create a point object on scene
        let pointGeometry = SCNSphere(radius: 0.005)
        let material =  SCNMaterial()
        material.diffuse.contents = UIColor.blue
        pointGeometry.materials = [material]
        let point = SCNNode(geometry: pointGeometry)
        point.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(point)
        points.append(point)
        
        //once two points are placed, we should calculate the distance between then
        if points.count >= 2 {
            calculateDistance()
        }
    }
    
    func calculateDistance() {
        let start = points[0]
        let end = points[1]
        
        // using equation distance = √ ((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2) to find the distance between two points in 3D space
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) + pow(end.position.y - start.position.y, 2) + pow(end.position.z - start.position.z, 2)
        )
        
        updateText(text: "\(abs(distance))", location: start.position)
    }
    
    func updateText(text: String, location position: SCNVector3){
        // clear previous text
        textNode.removeFromParentNode()
        
        // create new object that contains text
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
