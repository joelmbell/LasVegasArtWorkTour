//
//  ArtworkListViewController.swift
//  LasVegasArtWorkTour
//
//  Created by Joel Bell on 11/12/16.
//  Copyright © 2016 ROKIBI. All rights reserved.
//

import UIKit
import CoreLocation

fileprivate let dataURL = "https://opendata.lasvegasnevada.gov/resource/nefs-tayh.json"
fileprivate let cellIdentifier = "CellIdentifier"


class ArtworkListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView?
    
    fileprivate let dataService = DataService()
    fileprivate let locationService = LocationService()
    
    var currentLocation: CLLocation?
    
    var artworks = [Artwork]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(ArtworkCell.self, forCellReuseIdentifier: cellIdentifier)
        
        updateData()
    }
    
    fileprivate func updateData() {
        self.dataService.download(from: dataURL) { response in
            switch response {
            case .success(let value):
                self.artworks = ArtworkParser.parse(value)
                self.updateCurrentLocation()
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    fileprivate func updateCurrentLocation() {
        self.locationService.fetchLocation { (result) in
            switch result {
            case .success(let location):
                self.currentLocation = location
                self.tableView?.reloadData()
            case .failure(let error):
                print("Error Fetching Location: \(error)")
                self.currentLocation = nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artworks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let artwork = self.artworks[indexPath.row]
        cell.textLabel?.text = artwork.name
        
        var locString = artwork.locationDesc
        if let currentLoc = self.currentLocation {
            let artworkLoc = CLLocation(latitude: artwork.coordinate.latitude, longitude: artwork.coordinate.longitude)
            let miles = currentLoc.miles(from: artworkLoc)
            locString = String(format: "%.2f miles away.", miles)
        }
        
        cell.detailTextLabel?.text = locString

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artwork = self.artworks[indexPath.row]
        self.performSegue(withIdentifier: "ArtworkDetailSegue", sender: artwork)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtworkDetailSegue" {
            if let artwork = sender as? Artwork {
                if let detailVC = segue.destination as? ArtworkDetailViewController {
                    detailVC.artwork = artwork
                }
            }
        }
    }
}
