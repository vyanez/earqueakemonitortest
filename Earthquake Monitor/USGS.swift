//
//  API_USGS.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import Foundation

enum USGSApiMethod {
    case None
    case SummaryLastHour
    case Details
}

protocol USGSApiConnectionDelegate {
    func requestCompleted(connection: USGSApiConnection, response: USGSApiUrlResponse)
    func requestFailed(connection: USGSApiConnection, error: NSError)
}

class USGSApiUrlResponse: NSHTTPURLResponse {
    var success: Bool = false
    var result: NSDictionary?
    var data: NSData?
    
    init?(httpResponse: NSHTTPURLResponse, data: NSData) {
        var jsonError: NSError?
        
        super.init(URL: httpResponse.URL!,
            statusCode: httpResponse.statusCode,
            HTTPVersion: nil, headerFields: nil)
        self.data = data
        self.success = httpResponse.statusCode == 200 ||
            httpResponse.statusCode == 201
        self.result = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.allZeros, error: &jsonError
            ) as? NSDictionary
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func bodyAsString() -> String {
        if self.data == nil {
            return String()
        }
        return NSString(data: self.data!, encoding: NSUTF8StringEncoding)!
    }
}

class USGSApiUrlRequest: NSMutableURLRequest {
    
    private var _method: USGSApiMethod = .None
    private var _data: AnyObject?
    private var _tmpUrl : String?
    private var _boundary: String?

    var method: USGSApiMethod {
        set(newMethod) {
            var stringURL: String = "http://earthquake.usgs.gov"
            
            self.HTTPMethod = "GET"
            self.addValue("application/json", forHTTPHeaderField: "Content-Type")

            switch newMethod {
                
            case USGSApiMethod.SummaryLastHour:
                stringURL += "/earthquakes/feed/v1.0/summary/all_hour.geojson"
                break;
            case USGSApiMethod.Details:
                self.URL = NSURL(string: _tmpUrl!)
                self._method = newMethod
                return
            default:
                stringURL += "/"
                break;
            }
            
            self.URL = NSURL(string: stringURL)
            self._method = newMethod
        }
        get { return self._method }
    }
    
    var data: AnyObject? {
        set(newData) {
            var jsonError: NSError?
            self._data = newData
            if newData != nil {
                
                // For URI elements and JSON by HTTP Body (POST)
                if newData is [NSObject: AnyObject] {
                    let data: NSData? = NSJSONSerialization.dataWithJSONObject(newData!,
                        options: NSJSONWritingOptions.allZeros, error: &jsonError)
                    self.HTTPBody = data
                }
            }
        }
        get { return self._data }
    }
    
    func bodyAsString() -> String {
        if self.HTTPBody == nil {
            return String()
        }
        return NSString(data: self.HTTPBody!, encoding: NSUTF8StringEncoding)!
    }
    
    func escapeURI(value: String) -> String {
        return value.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func appendURLParameter(parameter: AnyObject) {
        if let absURL: String = self.URL?.absoluteString {
            var stringValue: String?
            if parameter is Int {
                stringValue = String(parameter as Int)
            } else if parameter is String {
                stringValue = parameter as? String
            }
            self.URL = NSURL(string: absURL + "/" + stringValue!)
        }
    }
    
    init(method: USGSApiMethod, data: AnyObject?) {
        super.init()
        self.method = method
        self.data = data
    }
    
    init(method: USGSApiMethod, url: String?) {
        super.init()
        self._tmpUrl = url
        self.method = method
    }
    
    init(method: USGSApiMethod) {
        super.init()
        self.method = method
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(URL: NSURL, cachePolicy: NSURLRequestCachePolicy, timeoutInterval: NSTimeInterval) {
        super.init(URL: URL, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
    }
}


class USGSApiConnection: NSURLConnection, NSURLConnectionDataDelegate, NSURLConnectionDelegate {
    
    var connection: NSURLConnection?
    var delegate: USGSApiConnectionDelegate?
    var receivedData: NSMutableData?
    var httpResponse: NSHTTPURLResponse?
    
    var request: USGSApiUrlRequest? {
        get {
            return self.connection?.currentRequest as? USGSApiUrlRequest
        }
    }
    
    init(request: USGSApiUrlRequest, delegate: USGSApiConnectionDelegate?) {
        super.init()
        self.delegate = delegate
        self.connection = NSURLConnection(request: request, delegate: self)!
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.receivedData = NSMutableData()
        self.httpResponse = response as? NSHTTPURLResponse
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.receivedData?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        if self.delegate != nil {
            self.delegate?.requestFailed(self, error: error)
            #if DEBUG
                println("USGS API Failed with Code: \(error.code)")
            #endif
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        if self.delegate != nil {
            var jsonError: NSError?
            let status = self.httpResponse?.statusCode
            let result: NSDictionary? = NSJSONSerialization.JSONObjectWithData(self.receivedData!,
                options: NSJSONReadingOptions.allZeros, error: &jsonError) as? NSDictionary
            let response = USGSApiUrlResponse(
                httpResponse: self.httpResponse!,
                data: self.receivedData!)
            self.delegate?.requestCompleted(self, response: response!)
        }
    }
    
    override func start() {
        super.start()
    }
    
    class func startGettingSummaryLastHour(delegate:USGSApiConnectionDelegate) -> (USGSApiConnection, USGSApiUrlRequest) {
        var request = USGSApiUrlRequest(method:USGSApiMethod.SummaryLastHour)
        let connection = USGSApiConnection(request: request, delegate: delegate)
        connection.start()
        return (connection, request)
    }
    
    class func startGettingDetails(delegate:USGSApiConnectionDelegate, tmpURL : String) -> (USGSApiConnection, USGSApiUrlRequest) {
        var request = USGSApiUrlRequest(method: .Details, url: tmpURL)
        let connection = USGSApiConnection(request: request, delegate: delegate)
        connection.start()
        return (connection, request)
    }
}