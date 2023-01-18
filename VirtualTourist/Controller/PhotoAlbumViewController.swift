//
//  DataController.swift
//  VirtualTourist
//
//  Created by Deer on 16/11/1441 AH.
//  Copyright © 1441 Rahaf Naif. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController :UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MKMapViewDelegate ,NSFetchedResultsControllerDelegate{
    
    static var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var newCollection: UIBarButtonItem!
    
    //var photosList = [photoInfo]()
    //var imageUrlList : [PhotoAlbum] = []
    var dataController : DataController!
    var pin:Pin!
    var fetchedResultsController:NSFetchedResultsController<PhotoAlbum>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let annotation = MKPointAnnotation()
        zoomingMap(PhotoAlbumViewController.coordinate, mapView: mapView)
        annotation.coordinate = PhotoAlbumViewController.coordinate
        self.mapView.addAnnotation(annotation)
        
        setUpFetch()
        
        if fetchedResultsController.fetchedObjects!.isEmpty {
            APIRequest()
            newCollection.isEnabled = false

        }
        
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tap))
        collectionView.addGestureRecognizer(tapped)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetch()
    }
    
    
    func zoomingMap(_ location: CLLocationCoordinate2D, mapView: MKMapView) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .infoLight)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
       
//        if fetchedResultsController.fetchedObjects!.isEmpty {
//            let photo = self.photosList[(indexPath as NSIndexPath).row]
//            addPhotoAlbum(imageUrl: photo.imageUrl.absoluteString)
//            cell.imageView.load(url: photo.imageUrl)
        
      
        let photo = fetchedResultsController.object(at: indexPath).imageUrl
        cell.imageView.load(url: URL(string: photo!)!)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
   
    func addPhotoAlbum(photos : [photoInfo]){
        
        for image in photos {
            let photo = PhotoAlbum(context: dataController.viewContext)
             photo.imageUrl = image.imageUrl.absoluteString
             photo.location = pin
             photo.creationDate = Date()
        }
        try! dataController.viewContext.save()
    }
    
    func deletePhoto(at indexPath : IndexPath){
        
        let photo = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
        
    }
    
    fileprivate func setUpFetch() {
        let fetchRequest:NSFetchRequest<PhotoAlbum> = PhotoAlbum.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        self.collectionView.reloadData()
       
    }
    
    fileprivate func APIRequest() {
        API.photoRequest(lat: PhotoAlbumViewController.coordinate.latitude, long: PhotoAlbumViewController.coordinate.longitude, completionHandler: {(photos,error) in
            //self.photosList = (photos?.photos.photo)!
            self.addPhotoAlbum(photos: (photos?.photos.photo)!)
            if photos?.photos.total == "0"{
                DispatchQueue.main.async{
                    self.text.isHidden = false
                }
            }
            
            DispatchQueue.main.async{
                self.collectionView.reloadData()
            }
        })
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if let album = fetchedResultsController.fetchedObjects {
        for photo in album {
            self.fetchedResultsController.managedObjectContext.delete(photo)
            try? self.dataController.viewContext.save()
        }
      }
        APIRequest()
        newCollection.isEnabled = false
    }
    
    @objc func tap(sender: UIGestureRecognizer){

        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            
            collectionView.deleteItems(at: [indexPath])
            deletePhoto(at: indexPath)
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        default: break
            
        }
    }
    
}

