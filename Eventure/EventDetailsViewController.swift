//
//  EventDetailsViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/18/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import Firebase

class EventDetailsViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventAddressLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var addToFavButton: UIButton!
    
    var eventId: String?

    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var favouritesRef: FIRDatabaseReference = FIRDatabase.database().reference().child("favourites")
    
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEventDetails()
        checkEvent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didDeleteEventPressed(_ sender: UIBarButtonItem) {
        let refreshAlert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this event?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.eventsRef.child(self.eventId!).removeValue { (error, ref) in
                if error != nil {
                    print("error \(error)")
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func addToFavouritesButtonPressed(_ sender: UIButton) {
        let userId = AppUtils.getCurrentUser().uid
        if sender.titleLabel?.text == "Add to favourites" {
            let favourite = [
                "userId": userId,
                "eventId": eventId!
                ] as [String : Any]
            
            let newFavRef = favouritesRef.childByAutoId()
            newFavRef.setValue(favourite)
            
            addToFavButton.setTitle("Remove from favourites", for: .normal)
        } else {
            removeFromFavs()
        }
        
    }
    
    func loadEventDetails() {
        eventsRef.child(eventId!).observeSingleEvent(of: .value, with: { (snapshot) in
            let event = Event(snapshot: snapshot)
            if !AppUtils.isLoggedIn() || event.addedByUser != AppUtils.getCurrentUser().uid {
                self.navigationItem.rightBarButtonItem = nil
            }
            self.eventNameLabel.text = event.eventName
            self.eventDescriptionTextView.text = event.eventDescription
            self.eventAddressLabel.text = event.address
            self.eventDateLabel.text = event.timestamp
            self.loadPhoto(url: event.photoId!)
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    func loadPhoto(url: String) {
        let photoRef = FIRStorage.storage().reference(forURL: url)
        photoRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            
            photoRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                self.coverImage.image = UIImage.init(data: data!)
                
            })

        }
    }
    
    func checkEvent() {
        
        if !AppUtils.isLoggedIn() {
            self.addToFavButton.isHidden = true
            return
        }
        
        favouritesRef
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: AppUtils.getCurrentUser().uid)
            .observe(.value, with: { snapshot in
            
            for item in snapshot.children {
                let firSnapshot = item as! FIRDataSnapshot
                let snapshotValue = firSnapshot.value as! [String: AnyObject]
                if (snapshotValue["eventId"] as! String) == self.eventId! {
                    self.addToFavButton.setTitle("Remove from favourites", for: .normal)
                }
            }
            
        })

    }
    
    func removeFromFavs() {
        favouritesRef
            .queryOrdered(byChild: "userId")
            .queryEqual(toValue: AppUtils.getCurrentUser().uid)
            .observe(.value, with: { snapshot in
                
                for item in snapshot.children {
                    let firSnapshot = item as! FIRDataSnapshot
                    let snapshotValue = firSnapshot.value as! [String: AnyObject]
                    if (snapshotValue["eventId"] as! String) == self.eventId! {
                        self.favouritesRef.child(firSnapshot.key).removeValue { (error, ref) in
                            if error != nil {
                                print("TestError \(error)")
                                return
                            }
                            
                            self.addToFavButton.setTitle("Add to favourites", for: .normal)
                        }
                    }
                }
                
            })
    }

}
