import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var dataFirebase = DataFirebase()
    
    var ref: DatabaseReference{
        return  Database.database().reference()
    }
    
    @IBOutlet weak var splitNumberLabel: UILabel!
    @IBOutlet weak var speedView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var stepperSpeed: UIStepper!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocation()
                
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: true)
        

    }
    
    @objc func updateLocation() {
        
        let urlCurrentLatitude = ref.child("/").child("currentLatitude")
        
        let CLatitude = urlCurrentLatitude.observe(DataEventType.value, with: { snapshot in
            if let getCurrentLatitude = snapshot.value as? Double {
                self.dataFirebase.latitude = getCurrentLatitude
            }
        })
        
        let urlCurrentLongitude = ref.child("/").child("currentLongitude")
        
        let CLongitude = urlCurrentLongitude.observe(DataEventType.value, with: { snapshot in
            if let getCurrentLongitude = snapshot.value as? Double {
                self.dataFirebase.longitude = getCurrentLongitude
            }
        })
        
        let urlFinishLatitude = ref.child("/").child("finishLatitude")
        
        let FLatitude = urlFinishLatitude.observe(DataEventType.value, with: { snapshot in
            if let getFinishLatitude = snapshot.value as? Double {
                self.dataFirebase.finishLatitude = getFinishLatitude
            }
        })
        
        let urlFinishLongitude = ref.child("/").child("finishLongitude")
        
        let FLongitude = urlFinishLongitude.observe(DataEventType.value, with: { snapshot in
            if let getFinishLongitude = snapshot.value as? Double {
                self.dataFirebase.finishLongitude = getFinishLongitude
            }
        })
        
        let urlSpeed = ref.child("/").child("speed")
        
        let Speed = urlSpeed.observe(DataEventType.value, with: { snapshot in
            if let getSpeed = snapshot.value as? Double {
                self.dataFirebase.speed = getSpeed
            }
        })
        
        stepperSpeed.value = Double(dataFirebase.speed)
        splitNumberLabel.text = String(format: "%.0f", stepperSpeed.value)
        
        switch stepperSpeed.value {
        case 0:
            speedView.tintColor = UIColor.black
        case 1...125:
            speedView.tintColor = UIColor.green
        case 126...200:
            speedView.tintColor = UIColor.yellow
        case 201...255:
            speedView.tintColor = UIColor.red
        default:
            print("error")
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        
        self.addAnnotaionsOnMapView()
    }
    
    func addAnnotaionsOnMapView() {
        let CurrentLatitude = dataFirebase.latitude
        let CurrentLongitude = dataFirebase.longitude
        let FinishLatitude = dataFirebase.finishLatitude
        let FinishLongitude = dataFirebase.finishLongitude
        
        let oneLocation = MKPointAnnotation()
        oneLocation.coordinate = CLLocationCoordinate2D(latitude: CurrentLatitude, longitude: CurrentLongitude)
                
        mapView.addAnnotation(oneLocation)
        let twoLocation = MKPointAnnotation()
        twoLocation.coordinate = CLLocationCoordinate2D(latitude: FinishLatitude, longitude: FinishLongitude)
        
        mapView.addAnnotation(twoLocation)

        
        self.drawLineTwoLocation(sourceLocation: oneLocation.coordinate, destinationLocation: twoLocation.coordinate)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    func drawLineTwoLocation(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        
        self.mapView.removeOverlays(self.mapView.overlays)
        
        //step 1
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // Step 2
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        //Step 3
        
        let directRequest = MKDirections.Request()
        
        directRequest.source = sourceMapItem
        
        directRequest.destination = destinationMapItem
        
        directRequest.transportType = .automobile
        
        //Step 4
        
        let directions = MKDirections(request: directRequest)
        directions.calculate { (response, error) in
            if error == nil {
                if let route = response?.routes.first {
                    
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    let rect = route.polyline.boundingMapRect
                    
                    self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 20, right: 20), animated: true)
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        
        let splitLabel = dataFirebase.speed
        
        print(splitLabel)
        
        splitNumberLabel.text = String(format: "%.0f", sender.value)

        self.ref.child("speed").setValue(sender.value)

        switch sender.value {
        case 0:
            speedView.tintColor = UIColor.black
        case 1...125:
            speedView.tintColor = UIColor.green
        case 126...200:
            speedView.tintColor = UIColor.yellow
        case 201...255:
            speedView.tintColor = UIColor.red
        default:
            print("error")
        }
    }
}
