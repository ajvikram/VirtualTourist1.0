//
//  PictureViewController.swift
//  VirtualTourist1.0
//
//  Created by Ajay Singh on 1/16/18.
//  Copyright © 2018 ATT. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class PictureViewController : CoreDataViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collection: UICollectionView!
    
    var annotation: MKAnnotation!
    var pin: Pin!
    var page = 1
    var fetching = false
    
    // MARK: Lifecylce Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        collection.delegate = self
        collection.dataSource = self
        mapView.addAnnotation(annotation)
        let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    
        if pin.vtphotos?.count == 0 {
            getNewCollection(pin)
            page += 1
        }
        
    }
    
    // MARK: Delegate Functions
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = pin.vtphotos?.allObjects[indexPath.row] as! Photos
        fetchedResultsController?.managedObjectContext.delete(photo)
         (UIApplication.shared.delegate as! AppDelegate).stack.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (pin.vtphotos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        DispatchQueue.main.async {
            if !self.fetching {
                cell.image.image = UIImage(data: (self.pin.vtphotos?.allObjects[indexPath.row] as! Photos).image! as Data)
            } else {
                cell.image.image = UIImage(named: "Placeholder")
            }
        }
        
        return cell
    }
    
    // MARK: Button Actions
    
    @IBAction func addNewCollection(_ sender: Any) {
        for photo in pin.vtphotos! {
            fetchedResultsController?.managedObjectContext.delete(photo as! NSManagedObject)
        }
        (UIApplication.shared.delegate as! AppDelegate).stack.save()
        
        getNewCollection(pin)
        page += 1
    }
    
    // MARK: Helper functions
    
   func storePhotos(_ photosDictionary: [[String: Any?]]) {
        DispatchQueue.main.async {
            self.collection.reloadData()
        }
    
        for photo in photosDictionary {
            let urlString = photo[FlickrClient.URLValues.URLMediumPhoto] as! String?
            let id = photo[FlickrClient.JSONResponseKeys.ID] as! String?
            let url = URL(string: urlString!)
    
            if let imageData = try? Data(contentsOf: url!) {
                let p = Photos(id: id!, image: imageData as NSData, imageUrl: urlString!, context: (fetchedResultsController?.managedObjectContext)!)
                pin.addToVtphotos(p)
            } else {
                print("Image does not exist at \(urlString!)")
            }
        }
    
        fetching = false
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).stack.save()
            self.collection.reloadData()
            self.enableUI(true)
        }
    }

    func getNewCollection(_ pin: Pin) {
       enableUI(false)
        fetching = true
        
        //fetch photos at coordinates
        let coord = annotation.coordinate
        FlickrClient.sharedInstance.downloadPhotosForPin(pin, completionHandlerForPhotosForPin: { success, photo, error in
            func showAlert(_ errorString: String = "Error with network request."){
                let alert = UIAlertController(title: "Data Error", message:
                    errorString, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            guard success else {
                showAlert()
                return
            }
            
            if photo?.count == 0 {
                showAlert("No photos available.")
                return
            }
            
            self.storePhotos(photo!)
        })
    }
    
    // MARK: Abstact functions
    
    override func updateViewAfterChange() {
        if let col = collection {
            col.reloadData()
        }
    }
    
    // MARK: UI Funcitons

    func enableUI(_ enable: Bool) {
        collectionButton.isEnabled = enable
    }
}

