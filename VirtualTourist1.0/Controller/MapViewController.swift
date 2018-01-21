//
//  MapViewController.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/15/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController : CoreDataViewController, MKMapViewDelegate {
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var mkMapView: MKMapView!
    var editButtonTapped = true
    
    @IBOutlet weak var deleteView: UIView!
    // MARK: Lifecylce Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mkMapView.delegate = self
        deleteView.isHidden = false
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation))
        gesture.minimumPressDuration = 0.75
        mkMapView.addGestureRecognizer(gesture)
        
        setLastSavedRegion()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    @IBAction func editPressed(_ sender: AnyObject) {
        if editButton.titleLabel?.text == "Done" {
            UIView.animate(withDuration: 0.7, animations: {
                self.mkMapView.frame.origin.y += self.deleteView.frame.height
            })
            editButton.setTitle("Edit", for: .normal)
            self.editButtonTapped = true
           
           (UIApplication.shared.delegate as! AppDelegate).stack.save()
        } else {
            UIView.animate(withDuration: 0.7, animations: {
                self.mkMapView.frame.origin.y -= self.deleteView.frame.height
                
            })
            editButton.setTitle("Done", for: .normal)
            self.editButtonTapped = false
            (UIApplication.shared.delegate as! AppDelegate).stack.save()
        }
    }
    
    // MARK: Delegate functions
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UserDefaults.standard.set(regionToArray(regionToConvert: mapView.region), forKey: "lastRegion")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
        controller.annotation = view.annotation
        controller.pin = getCorrespondingLocation((view.annotation?.coordinate)!)
        
        if editButtonTapped == true {
            let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
            fr.sortDescriptors = []
            controller.fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: (fetchedResultsController?.managedObjectContext)!, sectionNameKeyPath: nil, cacheName: nil)
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            (UIApplication.shared.delegate as! AppDelegate).stack.context.delete(controller.pin)
               // sharedContext.delete(controller.annotation)
                (UIApplication.shared.delegate as! AppDelegate).stack.save()
            
            self.mkMapView.removeAnnotation(controller.annotation)
        }
        
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView?.animatesDrop = true
            pinView?.isDraggable = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // MARK: Helper Functions
    
    @objc func addAnnotation(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mkMapView)
            let coords = mkMapView.convert(touchPoint, toCoordinateFrom: mkMapView)
            _ = Pin(latitude: coords.latitude, longitude: coords.longitude, context: (fetchedResultsController?.managedObjectContext)!)
            (UIApplication.shared.delegate as! AppDelegate).stack.save()
        }
    }
    
    func getCorrespondingLocation(_ coordinates: CLLocationCoordinate2D) -> Pin? {
        for obj in (fetchedResultsController?.fetchedObjects)! {
            let loc = obj as? Pin
            if loc?.latitude == coordinates.latitude && loc?.longitude == coordinates.longitude {
                return obj as? Pin
            }
        }
        return nil
    }
    
    func setLastSavedRegion() {
        if UserDefaults.standard.bool(forKey: "returning") {
            let regionData = UserDefaults.standard.array(forKey: "lastRegion") as! [Double]
            
            let center = CLLocationCoordinate2D(latitude: regionData[0], longitude: regionData[1])
            let span = MKCoordinateSpan(latitudeDelta: regionData[2], longitudeDelta: regionData[3])
            let region = MKCoordinateRegion(center: center, span: span)
            
            mkMapView.setRegion(region, animated: false)
        } else {
            UserDefaults.standard.set(regionToArray(regionToConvert: mkMapView.region), forKey: "lastRegion")
            UserDefaults.standard.set(true, forKey: "returning")
        }
    }
    
    func displaySavedPins() {
        if let objs = fetchedResultsController?.fetchedObjects as! [Pin]? {
            for location in objs {
                let coords = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coords
                if !mkMapView.annotations.contains(where: { (mk) -> Bool in
                    return mk.coordinate.latitude == annotation.coordinate.latitude && mk.coordinate.longitude == annotation.coordinate.longitude
                }){
                    mkMapView.addAnnotation(annotation)
                }
            }
        } else {
            print("no items fetched")
        }
    }
    
    func regionToArray(regionToConvert region: MKCoordinateRegion) -> [Double] {
        return [region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta]
    }
    
    // MARK: Abstract functions
    
    override func updateViewAfterChange() {
        displaySavedPins()
    }
    
}
