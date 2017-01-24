//
//  ProfileViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/18/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileViewController: UIViewController {
    
    let profileToDetails = "ProfileToDetails"

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var myPostsTableView: UITableView!
    
    var events = [Event]()
    var activityIndicator: UIActivityIndicatorView?
    
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.myPostsTableView.indexPathForSelectedRow {
            self.myPostsTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUIElements()
        getEvents()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func didLogoutButtonPressed(_ sender: UIBarButtonItem) {
        try! FIRAuth.auth()?.signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: EventDetailsViewController.self) {
            let eventDetailsVC = segue.destination as! EventDetailsViewController
            eventDetailsVC.eventId = sender as? String
        }
    }
    
    func initUIElements() {
        
        emailLabel.text = "E-mail: \(AppUtils.getCurrentUser().email!)"
        
        myPostsTableView.delegate = self
        myPostsTableView.dataSource = self
        myPostsTableView.tableFooterView = UIView()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator?.color = AppUtils.colorFromHex(rgbValue: 0x1696BD)
        activityIndicator?.center = view.center
        
        self.view.addSubview(activityIndicator!)
        
    }
    
    func getEvents() {
        activityIndicator?.startAnimating()
        eventsRef.queryOrdered(byChild: "addedByUser").queryEqual(toValue: AppUtils.getCurrentUser().uid).observe(.value, with: { snapshot in
            var items = [Event]()
            self.activityIndicator?.stopAnimating()
            if snapshot.childrenCount != 0 {
                self.myPostsTableView.backgroundView = nil
                self.myPostsTableView.separatorStyle = .singleLine
            } else {
                TableViewHelper.EmptyMessage(tableView: self.myPostsTableView)
            }
            for item in snapshot.children {
                
                let eventItem = Event(snapshot: item as! FIRDataSnapshot)
                items.append(eventItem)
            }
            
            self.events = items
            self.myPostsTableView.reloadData()
        })
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventItemTableViewCell
        cell.eventRating.settings.fillMode = .precise
        cell.eventRating.rating = Double(events[indexPath.row].rating)
        cell.eventNameLabel.text = events[indexPath.row].eventName
        cell.dateLabel.text = events[indexPath.row].timestamp
        cell.placeLabel.text = events[indexPath.row].address
        cell.id = events[indexPath.row].id
        let photoRef = FIRStorage.storage().reference(forURL: events[indexPath.row].photoId!)
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
                
                cell.eventThumbnail.image = UIImage.init(data: data!)
                
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: tableView.indexPathForSelectedRow!) as? EventItemTableViewCell
        self.performSegue(withIdentifier: profileToDetails, sender: cell?.id)
    }
    
}

