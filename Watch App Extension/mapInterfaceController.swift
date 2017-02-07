//
//  mapInterfaceController.swift
//  Find My Nearest Favorite Places
//
//  Created by Phan Nguyen on 9/5/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class mapInterfaceController: WKInterfaceController {

    
    @IBOutlet var placeLabel: WKInterfaceLabel!
    
    @IBOutlet var map: WKInterfaceMap!
    
    var latitude:Double = 0
    var longitude:Double = 0
    var currentLat:Double = 0
    var currentLong:Double = 0
    
    var placeName = ""
    
    var placeType = ""
    
    //var locationManager = CLLocationManager()

    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if context != nil {
            let data = context as! [String:Any]
            print(data)
            placeType = data["placeType"] as! String
            currentLat = data["currentLat"] as! Double
            currentLong = data["currentLong"] as! Double
            
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        /*locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()*/
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(currentLat),\(currentLong)&radius=1000&name=" + placeType + "&key=GOOGLE_PLACE_API_KEY”)
        //print(url)
        let task = URLSession.shared.dataTask(with: url! as URL, completionHandler: {
            (data, response, error) -> Void in
            
            if error == nil {
                
                print(data ?? "No Data")
               // var jsonResult: NSDictionary = JSONSerialization.JSONObjectWithData(data, options: JSONSerialization.ReadingOptions.MutableContainers, error: nil) as! NSDictionary
                var jsonResult = [String:Any]()
                do{
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:Any]
                }catch{
                    //
                }
                //let returnedPlaces: Array? = jsonResult["results"] as? Array
                
                if let returnedPlaces = jsonResult["results"] as? [Any] {
                    
                    if returnedPlaces.count > 0 {
                    
                        if let returnedPlace = returnedPlaces[0] as? [String:Any] {
                            
                            if let name = returnedPlace["name"] as? String {
                                
                                self.placeName = name as String
                                
                            }
                            
                            if let geometry = returnedPlace["geometry"] as? [String:Any] {
                                
                                if let location = geometry["location"] as? [String:Any] {
                                    
                                    
                                    if let lat = location["lat"] as? Double {
                                        
                                        self.latitude = lat
                                        
                                    }
                                    
                                    if let lng = location["lng"] as? Double {
                                        
                                        self.longitude = lng
                                        
                                    }
                                    
                                }
                                
                                
                        }
                            
                    }
                }
            }
            
            } else {
                print(error ?? "Error parse google places json")
            }
            
            if self.latitude != 0 && self.longitude != 0 && self.placeName != "" {
                
                let location = CLLocationCoordinate2D(latitude: self.latitude as CLLocationDegrees, longitude: self.longitude as CLLocationDegrees)
                
                let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                
                let region = MKCoordinateRegion(center: location, span: span)
                
                self.map.setRegion(region)
                
                self.placeLabel.setText(self.placeName)
                
                self.map.addAnnotation(location, with: WKInterfaceMapPinColor.red)
                
            }
            
            
        })
        
        task.resume()

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
