//
//  SummaryTableViewController.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import UIKit

class SummaryTableViewController: UITableViewController, USGSApiConnectionDelegate {

    var mSummaryConnection : (USGSApiConnection, USGSApiUrlRequest)?
    private var refreshCtrl : UIRefreshControl!
    private var allHourFetched : AllHour?
    private var isLoadingcontent = false
    private var mIndexPath : NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customSetup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.mSummaryConnection = USGSApiConnection.startGettingSummaryLastHour(self)
        self.isLoadingcontent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func customSetup() {
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: Selector("refreshContent:"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshCtrl)
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
        self.handleDataBackground("Loading data...")
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.allHourFetched? == nil ? 0 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fetchedCount = self.allHourFetched?.features?.count
        return (fetchedCount)!
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("summaryCell", forIndexPath: indexPath) as UITableViewCell

        let tmpFeature = self.allHourFetched?.features?[indexPath.row]
        
        cell.textLabel?.text = "Mag: " + (tmpFeature?.properties?.mag.description ?? "")!
        cell.detailTextLabel?.text = tmpFeature?.properties?.title ?? ""
        //cell.backgroundColor = UIColor(red: 1.0, green: 0.3, blue: 0.5, alpha: 1.0)
        return cell
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.mIndexPath = indexPath
        self.performSegueWithIdentifier("show_details", sender: self)
    }
    
    // MARK: - USGSApiDelegate
    func requestCompleted(connection: USGSApiConnection, response: USGSApiUrlResponse) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.isLoadingcontent = false
        
        if self.refreshCtrl.refreshing {
            self.refreshCtrl.endRefreshing()
        }
        
        //Load & parse data from server.
        self.allHourFetched = AllHour.fromJSON(response.result)

        if self.allHourFetched?.features?.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
        } else {
            self.handleDataBackground("No data. Please scroll down to refresh.")
        }
        
        #if DEBUG
            println("\n--- Summary Response ---\n\(response.result)")
        #endif
    }
    
    func requestFailed(connection: USGSApiConnection, error: NSError) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        self.isLoadingcontent = false
        
        if self.refreshCtrl.refreshing {
            self.refreshCtrl.endRefreshing()
        }
        
        self.handleDataBackground("Something went wrong. Please scroll down to refresh.")
        
        #if DEBUG
            println("\n--- Summary Error ---\n\(error.localizedDescription); \n--- Connection ---\n\(connection.request?.URL?.description)")
        #endif
    }
    
    func refreshContent(sender:AnyObject) {
        if !isLoadingcontent {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.mSummaryConnection = USGSApiConnection.startGettingSummaryLastHour(self)
        } else {
            self.refreshCtrl.endRefreshing()
        }
    }
    
    @IBAction func refreshTapped(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.mSummaryConnection = USGSApiConnection.startGettingSummaryLastHour(self)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "show_details" {
            var vc = segue.destinationViewController as? DetailsViewController
            if vc != nil  && mIndexPath != nil {
                vc?.mFeature = self.allHourFetched?.features?[(mIndexPath?.row)!]
            }
        }
    }
    
    func handleDataBackground(str:String) {
        var lbl = UILabel(frame: CGRectMake(0,0,self.view.bounds.width, self.view.bounds.height))
        lbl.text = str
        lbl.numberOfLines = 3;
        lbl.font = UIFont(name: "System-System", size: 30)
        lbl.textAlignment = .Center;
        lbl.textColor = .darkGrayColor();
        lbl.sizeToFit()
        
        if self.tableView?.backgroundView != nil {
            self.tableView?.backgroundView = nil
        }
        
        self.tableView?.backgroundView = lbl
        self.tableView?.separatorStyle = .None

    }
}
