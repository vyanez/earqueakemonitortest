//
//  Feature.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import UIKit

class AllHour : NSObject {
    var type : String!
    var metadata : [String:AnyObject]!
    var features : [Feature]?
    
    override init(){}
    
    init(type : String, metadata : [String:AnyObject], features : [Feature]?) {
        self.type = type; self.metadata = metadata; self.features = features
    }
    
    class func fromJSON(dic : AnyObject?) -> AllHour? {
        if dic == nil {return nil}
        
        let _type = dic?.valueForKey("type") as? String ?? "NO_TITLE"
        let _metadata = dic?.valueForKey("metadata") as [String:AnyObject]
        let _features : [Feature]? = Feature.fromJSON( (dic?.valueForKey("features"))!)
        
        return AllHour(type: _type, metadata: _metadata, features: _features)
    }
}

class Feature: NSObject {
    
    var type : String!
    var properties : Properties!
    var geometry : Geometry!
    var id : String!
    
    override init(){}
    
    init( type : String!, properties : Properties?, geometry : Geometry?, id : String!) {
        self.type = type; self.properties = properties;
        self.geometry = geometry; self.id = id;
    }
    
    class func fromJSON(dic : AnyObject?) -> Feature? {
        
        if dic == nil {return nil}
        
        let _type : String = dic?.valueForKey("type") as String
        let _id : String = dic?.valueForKey("id") as String
        let _geometry : Geometry? = Geometry.fromJSON(dic?.valueForKey("geometry"))
        let _properties : Properties? = Properties.fromJSON(dic?.valueForKey("properties"))
        
        return Feature(type: _type, properties: _properties, geometry: _geometry, id: _id)
    }
    
    class func fromJSON(dic : AnyObject) -> [Feature]? {
        let tmpFeaturesJSON : NSArray? = dic as? NSArray
        
        if tmpFeaturesJSON != nil && tmpFeaturesJSON?.count > 0 {
            
            var tmpFeatures = [Feature]();
            
            for (var i=0; i < tmpFeaturesJSON?.count; i++) {
                let tmpFeature : Feature? = Feature.fromJSON(tmpFeaturesJSON?[i])
                tmpFeatures.append(tmpFeature!)
            }
            
            return tmpFeatures
        }
        
        return nil
    }
}

class Properties: NSObject {
    var mag, time, updated, tsunami, sig, nst, dmin, rms, gap : Double!
    var place, url, detail, status, code, ids, sources, types, magType, type, title : String?
    var felt, cdi, mmi, alert, products : AnyObject?
    
    override init() {}
    
    init(mag : Double, time : Double, updated : Double, tsunami : Double, sig : Double, nst : Double, dmin : Double, rms : Double, gap : Double, place : String?, url : String?, detail : String?, felt : AnyObject?, cdi : AnyObject?, mmi : AnyObject?, alert : AnyObject?, status : String?, code : String?, ids : String?, sources : String?, types : String?, magType : String?, type : String?, title : String?, products : AnyObject? ) {
        
        self.mag = mag; self.time = time; self.updated = updated;
        self.tsunami = tsunami; self.sig = sig; self.nst = nst;
        self.dmin = dmin; self.rms = rms; self.gap = gap;
        self.place = place; self.url = url; self.detail = detail;
        self.felt = felt; self.cdi = cdi; self.mmi = mmi;
        self.alert = alert; self.status = status; self.code = code;
        self.ids = ids; self.sources = sources; self.types = types;
        self.magType = magType; self.type = type; self.title = title;
        self.products = products;
    }
    
    class func fromJSON(dic : AnyObject?) -> Properties? {
        if dic == nil {return nil}
        
        let _mag : Double = dic?.valueForKey("mag") as? Double ?? 0.0
        let _time : Double = dic?.valueForKey("time") as? Double ?? 0.0
        let _updated : Double = dic?.valueForKey("updated") as? Double ?? 0.0
        let _tsunami : Double = dic?.valueForKey("tsunami") as? Double ?? 0.0
        let _sig : Double = dic?.valueForKey("sig") as? Double ?? 0.0
        let _nst : Double = dic?.valueForKey("nst") as? Double ?? 0.0
        let _dmin : Double = dic?.valueForKey("dmin") as? Double ?? 0.0
        let _rms : Double = dic?.valueForKey("rms") as? Double ?? 0.0
        let _gap : Double = dic?.valueForKey("gap") as? Double ?? 0.0
        let _place : String = dic?.valueForKey("place") as String
        let _url : String = dic?.valueForKey("url") as String
        
        var _detail : String?
        
        if let _detailJSON : String = dic?.valueForKey("detail") as? String {
            _detail = _detailJSON
        }
        
        var _products : AnyObject?
        
        if let _productsJSON : AnyObject? = dic?.valueForKey("products") {
            _products = _productsJSON
        }
        
        let _felt : AnyObject? = dic?.valueForKey("felt")
        let _cdi : AnyObject? = dic?.valueForKey("cdi")
        let _mmi : AnyObject? = dic?.valueForKey("mmi")
        let _alert : AnyObject? = dic?.valueForKey("alert")
        
        let _status : String = dic?.valueForKey("status") as String
        let _code : String = dic?.valueForKey("code") as String
        let _ids : String = dic?.valueForKey("ids") as String
        let _sources : String = dic?.valueForKey("sources") as String
        let _types : String = dic?.valueForKey("types") as String
        let _magType : String = dic?.valueForKey("magType") as String
        let _type : String = dic?.valueForKey("type") as String
        let _title : String = dic?.valueForKey("title") as String
        
        return Properties(mag: _mag, time: _time, updated: _updated, tsunami: _tsunami, sig: _sig, nst: _nst, dmin: _dmin, rms: _rms, gap: _gap, place: _place, url: _url, detail: _detail, felt: _felt, cdi: _cdi, mmi: _mmi, alert: _alert, status: _status, code: _code, ids: _ids, sources: _sources, types: _types, magType: _magType, type: _type, title: _title, products : _products)
    }
}

class Geometry : NSObject {
    
    var coordinates : [Double]!
    var type : String!
    
    override init() {}
    
    init (type:String, coordinates : [Double]) {
        self.type = type; self.coordinates = coordinates
    }
    
    class func fromJSON (dic : AnyObject?) -> Geometry? {
        
        if dic == nil {return nil}
        
        let tmpGeo : Geometry = Geometry(
            type: dic?.valueForKey("type") as String,
            coordinates: dic?.valueForKey("coordinates") as [Double]
        )
        
        return tmpGeo
    }
}
