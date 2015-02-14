//
//  DetailsViewController.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, USGSApiConnectionDelegate {
    
    @IBOutlet var mMap: GMSMapView!
    @IBOutlet var lblMagnitude: UILabel!
    @IBOutlet var lblDateAndTime: UILabel!
    var mFeature : Feature?
    @IBOutlet var lblLocation: UILabel!
    
    private var mDetailsConnection : (USGSApiConnection, USGSApiUrlRequest)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.mFeature != nil {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.mDetailsConnection = USGSApiConnection.startGettingDetails(self, tmpURL: (self.mFeature?.properties.detail)!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - USGSApiDelegate
    func requestCompleted(connection: USGSApiConnection, response: USGSApiUrlResponse) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let feature : Feature? = Feature.fromJSON(response.result)

        dispatch_async(dispatch_get_main_queue(),{
            self.lblMagnitude.text = feature?.properties.mag.description
            self.lblDateAndTime.text = feature?.properties.time.description
            
            let _lat = (feature?.geometry.coordinates[1])!
            let _lng = (feature?.geometry.coordinates[0])!
            
            var camera = GMSCameraPosition.cameraWithLatitude(_lat,
                longitude:_lng, zoom:5)
            
            var marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(_lat, _lng)
            marker.appearAnimation = kGMSMarkerAnimationPop
            marker.title = feature?.properties.title
            marker.snippet = feature?.properties.mag.description
            self.mMap.camera = camera
            marker.map = self.mMap

            
        })
        #if DEBUG
            //println("\n--- Details Response ---\n\(response.result)")
            println("\n--- Details Geometry ---\n\(feature?.geometry.coordinates[0]);\(feature?.geometry.coordinates[1])")
        #endif
    }
    
    func requestFailed(connection: USGSApiConnection, error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        #if DEBUG
            println("\n--- Details Error ---\n\(error.localizedDescription); \n--- Connection ---\n\(connection.request?.URL?.description)")
        #endif
    }
}
