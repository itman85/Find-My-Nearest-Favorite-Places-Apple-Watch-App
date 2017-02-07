//
//  InterfaceController.swift
//  Watch App Extension
//
//  Created by Phan Nguyen on 9/5/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import CoreLocation

class InterfaceController: WKInterfaceController,WCSessionDelegate,CLLocationManagerDelegate {

    @IBOutlet var table: WKInterfaceTable!
    
    var places = [String]()
    var _defaults = UserDefaults(suiteName: "group.omebee.sample.watch.findMyNearestPlaces")
    var wsession:WCSession!
    var locationManager = CLLocationManager()
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        var data=[String:Any]()
        data["placeType"] = places[rowIndex];
        data["currentLat"] = locationManager.location?.coordinate.latitude
        data["currentLong"] = locationManager.location?.coordinate.longitude
        pushController(withName: "mapInterfaceController", context: data)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if WCSession.isSupported(){
            self.wsession = WCSession.default()
            self.wsession.delegate = self
            self.wsession.activate()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        places = []
        let storedPlaces: AnyObject? = _defaults?.object(forKey: "places") as AnyObject?
        if let storedPlacesArray = storedPlaces as? Array<AnyObject>{
            for(_,value) in storedPlacesArray.enumerated(){
                if let placeName = value as? String{
                    places.append(placeName)
                }
            }
        }
        
        if places.count == 0{
            places = ["cinema","cafe","pub","restaurant"]
            //_defaults?.set(places, forKey: "places")
        }
        
        table.setNumberOfRows(places.count, withRowType: "tableRowController")
        for(index,place) in places.enumerated(){
            if let row = table.rowController(at: index) as? tableRowController{
                row.tableRowLabel.setText(place)
            }
        }

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //need these functions to comform wsessiondelegete
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activationDidCompleteWith")
    }
    
    /*func sessionDidBecomeInactive(_ session: WCSession) {
        print("session sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session sessionDidDeactivate")
    }*/
    /////////
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        //receive message from iphone
        print("Receive message from iphone:")
        print(message)
        if message.count > 0{
            places = []
            places.append(message["place1"] as! String)
            places.append(message["place2"] as! String)
            places.append(message["place3"] as! String)
            places.append(message["place4"] as! String)
            _defaults?.set(places, forKey: "places")
            
            table.setNumberOfRows(places.count, withRowType: "tableRowController")
            for(index,place) in places.enumerated(){
                if let row = table.rowController(at: index) as? tableRowController{
                    row.tableRowLabel.setText(place)
                }
            }
            
        }
        
        replyHandler(["status":"received"])

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location did update \(locations)")
    }
    


}
