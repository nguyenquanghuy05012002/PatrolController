import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation

class ThietLapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var dataFirebase = DataFirebase()
    
    var ref: DatabaseReference{
        return  Database.database().reference()
    }
    
    @IBOutlet weak var splitNumberLabel: UILabel!
    @IBOutlet weak var speedView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textLatitude: UITextField!
    @IBOutlet weak var textLongitude: UITextField!
    @IBOutlet weak var getDirectionButton: UIButton!
    @IBOutlet weak var stepperSpeed: UIStepper!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlCurrentLatitude = ref.child("/").child("currentLatitude")
        
        let Latitude = urlCurrentLatitude.observe(DataEventType.value, with: { snapshot in
            if let getCurrentLatitude = snapshot.value as? Double {
                self.dataFirebase.latitude = getCurrentLatitude
            }
        })
        
        let urlCurrentLongitude = ref.child("/").child("currentLongitude")
        
        let Longitude = urlCurrentLongitude.observe(DataEventType.value, with: { snapshot in
            if let currentLongitude = snapshot.value as? Double {
                self.dataFirebase.longitude = currentLongitude
            }
        })
    }
    
    func addAnnotaionsOnMapView() {
        let CurrentLatitude = dataFirebase.latitude
        let CurrentLongitude = dataFirebase.longitude
        let finishLatitude = Double(textLatitude.text!)
        let finishLongitude = Double(textLongitude.text!)
        
        let oneLocation = MKPointAnnotation()
        oneLocation.coordinate = CLLocationCoordinate2D(latitude: CurrentLatitude, longitude: CurrentLongitude)
                
        mapView.addAnnotation(oneLocation)
        let twoLocation = MKPointAnnotation()
        twoLocation.coordinate = CLLocationCoordinate2D(latitude: finishLatitude!, longitude: finishLongitude!)
        
        mapView.addAnnotation(twoLocation)

        
        self.drawLineTwoLocation(sourceLocation: oneLocation.coordinate, destinationLocation: twoLocation.coordinate)
    }
    
    func drawLineTwoLocation(sourceLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
        
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
    
    @IBAction func goMap(_ sender: UIButton) {
        let finishLatitude = Double(textLatitude.text!)
        let finishLongitude = Double(textLongitude.text!)
        
        self.ref.child("finishLatitude").setValue(finishLatitude)
        self.ref.child("finishLongitude").setValue(finishLongitude)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        
        self.addAnnotaionsOnMapView()

    }
    
    @IBAction func huyButton(_ sender: UIButton) {
        stepperSpeed.value = 0
        splitNumberLabel.text = String(format: "%.0f", 0)
        speedView.tintColor = UIColor.black
    }
    
}
