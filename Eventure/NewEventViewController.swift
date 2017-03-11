//
//  NewEventViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/4/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import DateTimePicker
import LocationPicker
import CoreLocation
import MapKit
import Firebase
import Photos

class NewEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pickedImageView: UIImageView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var placeholderLabel: UILabel!
    var currentDate: Date?
    var currentDateString: String?
    var location: Location? {
        didSet {
            locationLabel.text = location.flatMap({ $0.title }) ?? "No location selected"
        }
    }
    var photoReferenceURL: URL?
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUIElements()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didOpenCameraPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func didOpenPhotoLibraryPressed(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didChooseDateButtonPressed(_ sender: UIButton) {
        currentDate = Date()
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(selected: currentDate, minimumDate: min, maximumDate: max)
        picker.highlightColor = AppUtils.colorFromHex(rgbValue: 0x1696BD)
        picker.doneButtonTitle = "Done"
        picker.todayButtonTitle = "Today"
        picker.completionHandler = { date in
            self.currentDate = date
            self.currentDateString = AppUtils.stringFromDate(date: date)
            self.dateLabel.text = "Date: \(self.currentDateString!)"
        }
    }
    
    @IBAction func didPickLocationButtonPressed(_ sender: UIButton) {
        let locationPicker = LocationPickerViewController()
        
        let coordinates = CLLocationCoordinate2D(latitude: 43.235334, longitude: 76.909766)
        let initialLocation = Location(name: "International Information Technology University", location: nil,
                            placemark: MKPlacemark(coordinate: coordinates, addressDictionary: [:]))
        locationPicker.location = initialLocation
        locationPicker.mapType = .standard
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.searchBarPlaceholder = "Search places"
        locationPicker.searchHistoryLabel = "Previously searched"
        locationPicker.resultRegionDistance = 500
        
        locationPicker.completion = { self.location = $0 }
        
        navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func didPostButtonPressed(_ sender: UIBarButtonItem) {
        uploadPhoto()
    }
    
    func initUIElements() {
        let borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        descriptionTextField.delegate = self
        descriptionTextField.layer.borderWidth = 0.5
        descriptionTextField.layer.borderColor = borderColor.cgColor
        descriptionTextField.layer.cornerRadius = 5.0
        pickedImageView.layer.borderWidth = 0.5
        pickedImageView.layer.borderColor = borderColor.cgColor
        pickedImageView.layer.cornerRadius = 5.0
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter the description..."
        placeholderLabel.font = UIFont.systemFont(ofSize: (descriptionTextField.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        descriptionTextField.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (descriptionTextField.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !descriptionTextField.text.isEmpty
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        photoReferenceURL = info[UIImagePickerControllerReferenceURL] as? URL
        pickedImageView.contentMode = .scaleAspectFit
        pickedImageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    func uploadPhoto() {
        if photoReferenceURL == nil {
            return
        }
        
        let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceURL!], options: nil)
        let asset = assets.firstObject
        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
            let imageFileURL = contentEditingInput?.fullSizeImageURL
        
            let path = "\(AppUtils.getCurrentUser().uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(self.photoReferenceURL?.lastPathComponent)"
            
            self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading photo: \(error.localizedDescription)")
                    return
                }
                
                self.postEvent(photoUrl: self.storageRef.child((metadata?.path)!).description)
            }
        })
    }
    
    func postEvent(photoUrl: String) {
        let eventName = eventNameTextField.text
        let description = descriptionTextField.text
        let eventLocation = ["lat": Double((self.location?.coordinate.latitude)!), "lng": Double((self.location?.coordinate.longitude)!)]
        let user = AppUtils.getCurrentUser().uid
        let date = self.currentDateString!
        let address = self.location?.address
        let event = [
            "eventName": eventName!,
            "eventDescription": description!,
            "location": eventLocation,
            "photoId": photoUrl,
            "addedByUser": user,
            "rating": 0.0,
            "timestamp": date,
            "address": address!
        ] as [String : Any]
        
        print("eventtt: \(event)")
            
            
        let newEventRef = eventsRef.childByAutoId()
        newEventRef.setValue(event)
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension NewEventViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !descriptionTextField.text.isEmpty
    }
}
