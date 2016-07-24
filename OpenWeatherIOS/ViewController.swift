//
//  ViewController.swift
//  OpenWeatherIOS
//
//  Created by Sávio Xavier on 7/21/16.
//  Copyright © 2016 Sávio Xavier. All rights reserved.
//

import UIKit
import MapKit

/*Class that controls the first view (that ones with the map)*/
class ViewController: UIViewController, MKMapViewDelegate {
    
    let regionRadius: CLLocationDistance = 50000
    var centerPointPin = MKPointAnnotation()
    var coordinate: CLLocationCoordinate2D!
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*Here I declare a constant that will reconize a long press (with a minimum press duration) and then run an action. After that I add this new gesture recognizer to the mapView*/
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.pressAction(_:)))
        longPress.minimumPressDuration = 0.7
        mapView.addGestureRecognizer(longPress)
        
    }
    
    /*Function performed when the user long presses the mapView*/
    func pressAction(gestureRecognizer:UIGestureRecognizer) {
        
        /*This condition guarantees that the pin will appear only when the long press is confirmed. Doing so, when the user hold his/her finger and move around the screen, he/she do not add multiple pins on the way*/
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            coordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView) //Converts the touch location into real life coordinates and saves it in a global variable (coordinate)
            
            mapView.removeAnnotation(centerPointPin) //Removes former annotations (pins). That's why 'centerPointPin' isn't a local variable. To remove it later.
            
            /*Adds a pin and center the map in the choosen coordinate*/
            centerPointPin.coordinate = coordinate
            mapView.addAnnotation(centerPointPin)
            centerMapOnLocation(coordinate)
            
        }
        
    }
    
    /*Sets a radial region arround a given coordinate and zooms (in or out) in it*/
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToCitiesList" {
            if let destination = segue.destinationViewController as? CitiesList {
                
                destination.coordinate = self.coordinate /*Send the choosen coordinate to a variable of the same kind in the other view*/
                
            }
        }
    }
    
    /*If the user presses 'search'*/
    @IBAction func search(sender: UIButton) {
        
        /*Only go to the other view to search for the nearby cities, if the user successfully pin a coordinate*/
        if (coordinate != nil){
        
            self.performSegueWithIdentifier("goToCitiesList", sender: self)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

