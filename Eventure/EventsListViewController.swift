//
//  EventsListViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 1/3/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class EventsListViewController: UIViewController {
    
    let eventsToLogin = "EventsToLogin"
    let eventsToAdd = "EventsToAdd"
    let eventsToProfile = "EventsToProfile"
    let eventsToDetails = "EventsToDetails"
    
    var events = [Event]()
    
    @IBOutlet weak var eventsTableView: UITableView!

    @IBOutlet weak var searchBar: UISearchBar!
    var activityIndicator: UIActivityIndicatorView?
    
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.eventsTableView.indexPathForSelectedRow {
            self.eventsTableView.deselectRow(at: index, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUIElements()
        getEvents(query: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: EventDetailsViewController.self) {
            let eventDetailsVC = segue.destination as! EventDetailsViewController
            eventDetailsVC.eventId = sender as? String
        }
    }
    
    @IBAction func didAddButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? eventsToAdd : eventsToLogin
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    @IBAction func didProfileButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? eventsToProfile : eventsToLogin
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    func initUIElements() {
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.addSubview(self.refreshControl)
        searchBar.delegate = self
        eventsTableView.tableFooterView = UIView()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator?.color = AppUtils.colorFromHex(rgbValue: 0x1696BD)
        activityIndicator?.center = view.center
        
        self.view.addSubview(activityIndicator!)

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        getEvents(query: nil)
    }
    
    func getEvents(query: String?) {
        
        let queryRef = query == nil ? eventsRef : eventsRef.queryOrdered(byChild: "eventName").queryStarting(atValue: query!).queryEnding(atValue: query! + "\u{f8ff}")
        activityIndicator?.startAnimating()
        queryRef.observe(.value, with: { snapshot in
            var items = [Event]()
            self.activityIndicator?.stopAnimating()
            self.refreshControl.endRefreshing()
            if snapshot.childrenCount != 0 {
                self.eventsTableView.backgroundView = nil
                self.eventsTableView.separatorStyle = .singleLine
            } else {
                TableViewHelper.EmptyMessage(tableView: self.eventsTableView)
            }
            for item in snapshot.children {
            
                let eventItem = Event(snapshot: item as! FIRDataSnapshot)
                items.append(eventItem)
            }
            
            self.events = items
            self.eventsTableView.reloadData()
        })
    }
}

extension EventsListViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        self.performSegue(withIdentifier: eventsToDetails, sender: cell?.id)
    }
    
}

extension EventsListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text
        self.getEvents(query: text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            self.getEvents(query: nil)
        }
    }
}
