//
//  ThisWeekViewController.swift
//  Eventure
//
//  Created by Mukhamed Issa on 3/11/17.
//  Copyright © 2017 Mukhamed Issa. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class ThisWeekViewController: UIViewController {
    
    let thisWeekToDetails = "ThisWeekToDetails"
    let thisWeekToLogin = "ThisWeekToLogin"
    let thisWeekToAdd = "ThisWeekToAdd"
    let thisWeekToProfile = "ThisWeekToProfile"
    
    lazy var eventsRef: FIRDatabaseReference = FIRDatabase.database().reference().child("events")
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://eventure-52ae7.appspot.com")
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.handleRefresh), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    var events = [Event]()
    
    @IBOutlet weak var thisWeekTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.thisWeekTableView.indexPathForSelectedRow {
            self.thisWeekTableView.deselectRow(at: index, animated: true)
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
    
    func initUIElements() {
        thisWeekTableView.delegate = self
        thisWeekTableView.dataSource = self
        thisWeekTableView.addSubview(self.refreshControl)
        searchBar.delegate = self
        thisWeekTableView.tableFooterView = UIView()
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator?.color = AppUtils.colorFromHex(rgbValue: 0x1696BD)
        activityIndicator?.center = view.center
        
        self.view.addSubview(activityIndicator!)
        
    }
    
    @IBAction func didAddButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? thisWeekToAdd : thisWeekToLogin
        print("Identifierr \(segueIdentifier)")
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    @IBAction func didProfileButtonPressed(_ sender: UIBarButtonItem) {
        let segueIdentifier = AppUtils.isLoggedIn() ? thisWeekToProfile : thisWeekToLogin
        self.performSegue(withIdentifier: segueIdentifier, sender: nil)
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
                self.thisWeekTableView.backgroundView = nil
                self.thisWeekTableView.separatorStyle = .singleLine
            } else {
                TableViewHelper.EmptyMessage(tableView: self.thisWeekTableView)
            }
            for item in snapshot.children {
                
                let eventItem = Event(snapshot: item as! FIRDataSnapshot)
                let eventDate = AppUtils.dateFromString(stringDate: eventItem.timestamp)
                if AppUtils.isDateInCurrentWeek(date: eventDate) {
                    items.append(eventItem)
                }
            }
            
            if items.count == 0 {
                TableViewHelper.EmptyMessage(tableView: self.thisWeekTableView)
            }
            self.events = items
            self.thisWeekTableView.reloadData()
        })
    }
}

extension ThisWeekViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        self.performSegue(withIdentifier: thisWeekToDetails, sender: cell?.id)
    }
    
}

extension ThisWeekViewController: UISearchBarDelegate {
    
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
