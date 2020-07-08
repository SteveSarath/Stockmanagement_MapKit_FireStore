//
//  StocksViewController.swift
//  Stock Management
//
//  Created by sarath kumar on 26/06/20.
//  Copyright © 2020 sarath kumar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import FirebaseFirestore

class StocksViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var stockMapview: MKMapView!
    @IBOutlet weak var stockNeedButton: UIButton!
    
    private var documentRef: DocumentReference!
    private(set) var stocksCollection = [Stocks]()
    
    private lazy var db: Firestore = {
        let fireStoreDB = Firestore.firestore()
        let settings = fireStoreDB.settings
        fireStoreDB.settings = settings
        return fireStoreDB
    }()
    
    private lazy var locationManager: CLLocationManager = {
        
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.requestAlwaysAuthorization()
        return manager
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager.startUpdatingLocation()
        self.stockMapview.showsUserLocation = true
        self.stockMapview.delegate = self
        
        setupUI()
        configureObservers()
    }
                                                                                                        
    // MARK: - Custom Methods
    
    private func setupUI() {
        self.stockNeedButton.layer.cornerRadius = 5.0
        self.stockNeedButton.layer.masksToBounds = true
    }
    
    private func addStocksToMap(_ stock: Stocks) {
        
        let annotation = StockAnnotations(stock)
        annotation.title = "NEED STOCK"
        annotation.subtitle = stock.reportedDate.formatAsString()
        annotation.coordinate = CLLocationCoordinate2D(latitude: stock.latitude, longitude: stock.longitude)
        self.stockMapview.addAnnotation(annotation)
    }
    
    private func updateAnnotations() {
        
        DispatchQueue.main.async {
            self.stockMapview.removeAnnotations((self.stockMapview.annotations))
            self.stocksCollection.forEach {
                self.addStocksToMap($0)
            }
        }
    }
    
    private func configureObservers() {
        
        self.db.collection("StocksRegions").addSnapshotListener({ [weak self] snapshot, error in
            
            guard let snapshot = snapshot, error == nil else {
                print("error fetching document")
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                
                if diff.type == .added {
                    
                    if let stock = Stocks(diff.document) {
                        self?.stocksCollection.append(stock)
                        self?.updateAnnotations()
                    }
                } else if diff.type == .removed {
                    
                    if let stock = Stocks(diff.document) {
                        if let stocks = self?.stocksCollection {
                            self?.stocksCollection = stocks.filter { $0.documentId != stock.documentId }
                            self?.updateAnnotations()
                        }
                    }
                }
            }
            
        })
        
    }
    
    // MARK: - Action Methods
    
    @IBAction func stockNeedAction(_ sender: Any) {
        
        saveStocksToFireBase()
    }
    
    // MARK: - FireBase Methods
    
    private func saveStocksToFireBase() {
        
        guard let currentLocation = self.locationManager.location else {
            return
        }
        
        var stocks = Stocks(longitude: currentLocation.coordinate.longitude, latitude: currentLocation.coordinate.latitude)
        
        self.documentRef = self.db.collection("StocksRegions").addDocument(data: stocks.toDictionary()){ [weak self] error in
            
            if let error = error {
                print(error)
            } else {
                stocks.documentId = self?.documentRef.documentID
                self?.addStocksToMap(stocks)
                print("Location saved")
            }
        }
    }
    
    // MARK: - Delegate Methods
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let stockAnnotation = view.annotation as? StockAnnotations {
            
            let stock = stockAnnotation.stock
            
            self.db.collection("StocksRegions").document(stock.documentId!).delete() { error in
                
                if let error = error {
                    print("Error removing document \(error)")
                }
            }
        }
    }
    
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = stockMapview.dequeueReusableAnnotationView(withIdentifier: "StockAnnotationView")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "StockAnnotationView")
            annotationView?.canShowCallout = true
            annotationView?.image = UIImage(named: "flood-annotation")
            annotationView?.rightCalloutAccessoryView = UIButton.trashButton()
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: self.stockMapview.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        self.stockMapview.setRegion(region, animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
