import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ThuCongController:UIViewController {
    
    var dataFirebase = DataFirebase()
    
    var ref: DatabaseReference{
        return  Database.database().reference()
    }
    
    @IBOutlet weak var splitNumberLabel: UILabel!
    @IBOutlet weak var iconTrangThai: UIImageView!
    @IBOutlet weak var speedView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
                
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateImage), userInfo: nil, repeats: true)

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
    
    
    @IBAction func upBotton(_ sender: UIButton) {
        self.ref.child("control").setValue("f")
        print("up")
        print(dataFirebase.latitude)
        print(dataFirebase.image)
        
    }
    
    @IBAction func downButton(_ sender: UIButton) {
        self.ref.child("control").setValue("b")
        print("down")
        print(dataFirebase.longitude)

    }
    
    @IBAction func leftButton(_ sender: UIButton) {
        self.ref.child("control").setValue("l")
        print("left")
    }
    
    @IBAction func rightButton(_ sender: UIButton) {
        self.ref.child("control").setValue("r")
        print("right")
    }
    
    @IBAction func trangThaiButton(_ sender: UIButton) {
        if iconTrangThai.image == UIImage(named: "stop") {
            iconTrangThai.image = UIImage(named: "go")
            self.ref.child("control").setValue("g")

        } else {
            iconTrangThai.image = UIImage(named: "stop")
            self.ref.child("control").setValue("s")
        }
    }
    
    @objc func updateImage() {
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
        let image = ref.child("/").child("img_url")
        let Image = image.observe(DataEventType.value, with: { snapshot in
            if let imageUpdate = snapshot.value as? String {
                self.dataFirebase.image = imageUpdate
            }
        })
        
        imageView.load(urlString: (dataFirebase.image))

    }
/*
    func updateUI() {
        let postRef = ref.child("/")
        
        let refHandle = postRef.observe(DataEventType.value, with: { snapshot in
            if let postDict = snapshot.value as? [String: AnyObject] {
                print(postDict)
            }
        })
    }
 */
}

extension UIImageView {
    func load(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
    }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
