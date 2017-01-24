//
//  MapViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/4/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class MapViewController: UIViewController {
    
    var events = [Event]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")

    override func viewDidLoad() {
        super.viewDidLoad()
        loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadEvents() {
        eventsRef.observe(.value, with: { snapshot in
            var items = [Event]()
    
            for item in snapshot.children {
                let eventItem = Event(snapshot: item as! FIRDataSnapshot)
                items.append(eventItem)
            }
            
            self.events = items
            self.initMapAnnotations()
        })
    }
    
    func initMapAnnotations() {
        for event in events {
            let address = event.address
            let location = event.location
            let annotation = MKPointAnnotation()
            annotation.title = address
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(location["lat"]!), longitude: Double(location["lng"]!))
            mapView.addAnnotation(annotation)
        }
    }
}
