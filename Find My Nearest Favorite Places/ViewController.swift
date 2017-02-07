//
//  ViewController.swift
//  Find My Nearest Favorite Places
//
//  Created by Phan Nguyen on 9/5/16.
//  Copyright © 2016 Omebee. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity
class ViewController: UIViewController ,CLLocationManagerDelegate,WCSessionDelegate{

    var places = [String]()
    var _defaults = UserDefaults(suiteName: "group.omebee.sample.watch.findMyNearestPlaces")
    var locationManager = CLLocationManager()
    var wsession:WCSession!
    
    @IBOutlet weak var txtPlace1: UITextField!
    
    
    @IBOutlet weak var txtPlace2: UITextField!
    
    
    @IBOutlet weak var txtPlace3: UITextField!
    
    
    @IBOutlet weak var txtPlace4: UITextField!
    
    
    @IBAction func updateButtonPress(_ sender: Any) {
        places = [txtPlace1.text!,txtPlace2.text!,txtPlace3.text!,txtPlace4.text!]
        _defaults!.set(places, forKey: "places")
        let dicMessages: [String:String] = ["place1":txtPlace1.text!,"place2":txtPlace2.text!,"place3":txtPlace3.text!,"place4":txtPlace4.text!]
        //send message to watch
        wsession.sendMessage(dicMessages,
                             replyHandler: { reply in
                                print("Reply from watch \(reply)")
        },                   errorHandler: { error in
            print("Error from watch \(error)")
            
        })
       // wsession.sendMessage(dicMessages, replyHandler: nil, errorHandler: nil)
        
        
       
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported(){
            self.wsession = WCSession.default()
            self.wsession.delegate = self
            self.wsession.activate()
            
            if self.wsession.isPaired != true {
                print("Apple Watch is not paired")
            }
            
            if self.wsession.isWatchAppInstalled != true {
                print("WatchKit app is not installed")
            }
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        
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
            _defaults!.set(places, forKey: "places")
            
            let dicMessages: [String:String] = ["place1":places[0],"place2":places[1],"place3":places[2],"place4":places[3]]
            //send message to watch
            wsession.sendMessage(dicMessages,
                                 replyHandler: { reply in
                                    print("Reply from watch \(reply)")
            },                   errorHandler: { error in
                print("Error from watch \(error)")
 
            })
            
            wsession.sendMessage(dicMessages, replyHandler: nil, errorHandler: nil)


        }
        
        txtPlace1.text = places[0]
        txtPlace2.text = places[1]
        txtPlace3.text = places[2]
        txtPlace4.text = places[3]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
    //need these functions to comform wsessiondelegete
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("session activationDidCompleteWith")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session sessionDidBecomeInactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session sessionDidDeactivate")
    }
    /////////
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        //receive message from watch
    }

}

