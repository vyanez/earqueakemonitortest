//
//  DetailsViewController.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, USGSApiConnectionDelegate {

    var urlDetails : String?
    var mFeature : Feature?
    
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
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - USGSApiDelegate
    func requestCompleted(connection: USGSApiConnection, response: USGSApiUrlResponse) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        #if DEBUG
            println("\n--- Details Response ---\n\(response)")
        #endif
    }
    
    func requestFailed(connection: USGSApiConnection, error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        #if DEBUG
            println("\n--- Details Error ---\n\(error.localizedDescription); \n--- Connection ---\n\(connection.request?.URL?.description)")
        #endif
    }
}
