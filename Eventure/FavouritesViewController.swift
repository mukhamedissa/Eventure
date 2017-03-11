//
//  FavouritesViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/18/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import Firebase

class FavouritesViewController: UIViewController {
    
    let favsToDetails = "FavouritesToDetails"
    let favsToLogin = "FavsToLogin"
    let favsToAdd = "FavsToAdd"
    let favsToProfile = "FavsToProfile"
    
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var favouritesRef: FIRDatabaseReference = FIRDatabase.database().reference().child("favourites")
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()

    @IBOutlet weak var favouritesTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var activityIndicator: UIActivityIndicatorView?
    
    var events = [Event]()
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.favouritesTableView.indexPathForSelectedRow {
            self.favouritesTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goToLoginVCIfNeed()
        initUIElements()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToLoginVCIfNeed() {
        if !AppUtils.isLoggedIn() {
            performSegue(withIdentifier: favsToLogin, sender: nil)
        } else {
            getFavourites(query: nil)
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getFavourites(query: nil)
    }
    
    func initUIElements() {
        favouritesTableView.delegate = self
        favouritesTableView.dataSource = self
        favouritesTableView.addSubview(self.refreshControl)
        searchBar.delegate = self
        favouritesTableView.tableFooterView = UIView()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator?.color = AppUtils.colorFromHex(rgbValue: 0x1696BD)
        activityIndicator?.center = view.center
        
        self.view.addSubview(activityIndicator!)
        
    }
    
    @IBAction func didProfileButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? favsToProfile : favsToLogin
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    @IBAction func didAddButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? favsToAdd : favsToLogin
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: EventDetailsViewController.self) {
            let eventDetailsVC = segue.destination as! EventDetailsViewController
            eventDetailsVC.eventId = sender as? String
        }
    }
    
    func getFavourites(query: String?) {
        
        events.removeAll()
        activityIndicator?.startAnimating()
        favouritesRef.queryOrdered(byChild: "userId").queryEqual(toValue: AppUtils.getCurrentUser().uid).observe(.value, with: {snapshot in
            
            self.activityIndicator?.stopAnimating()
            self.refreshControl.endRefreshing()
            if snapshot.childrenCount != 0 {
                self.favouritesTableView.backgroundView = nil
                self.favouritesTableView.separatorStyle = .singleLine
            } else {
                TableViewHelper.EmptyMessage(tableView: self.favouritesTableView)
            }
            
            for item in snapshot.children {
                let firSnapshot = item as! FIRDataSnapshot
                let snapshotValue = firSnapshot.value as! [String: AnyObject]
                let eventId = snapshotValue["eventId"] as! String
                print(eventId)
                self.eventsRef.queryOrderedByKey().queryEqual(toValue: eventId).observe(.value, with: { snapshot in
                    
                    for item in snapshot.children {
                        let eventItem = Event(snapshot: item as! FIRDataSnapshot)
                        if query != nil {
                            if eventItem.eventName.lowercased().contains((query?.lowercased())!) {
                                self.events.append(eventItem)
                            }
                        } else {
                            self.events.append(eventItem)
                        }
                    }
                    
                    self.favouritesTableView.reloadData()
                    
                })
            }
            
            
        })
    }
}

extension FavouritesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventItemTableViewCell
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
        self.performSegue(withIdentifier: favsToDetails, sender: cell?.id)
    }
    
}

extension FavouritesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        self.getFavourites(query: text!)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.getFavourites(query: nil)
        }
    }
}
