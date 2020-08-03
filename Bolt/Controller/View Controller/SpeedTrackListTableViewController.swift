//
//  SpeedTrackListTableViewController.swift
//  Bolt
//
//  Created by Victor Monteiro on 6/28/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit
import AnimatableReload

class SpeedTrackListTableViewController: UITableViewController {
    
    //MARK: - Properties
    var reusableIdentifier = "speedTrackCell"
    var segueIdentifier = "toDetailScreen"
    var refresher: UIRefreshControl = UIRefreshControl()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadData()
    }
    
    //MARK: - Methods
    func updateViews() {
        DispatchQueue.main.async {
            AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
            self.refresher.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViews()
    }
    
    func setupViews() {
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to see new Speed Track")
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.addSubview(refresher)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Aero", size: 25)!]
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    //MARK: Fetching Data to load TableView
    @objc func loadData() {
        SpeedTrackController.shared.fetchSpeedTracks { (result) in
            switch result {
            case .success(let speedTrack):
                SpeedTrackController.shared.speedTrackers = speedTrack
                self.updateViews()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SpeedTrackController.shared.speedTrackers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "speedTrackCell", for: indexPath) as? SpeedTrackTableViewCell else { return UITableViewCell() }
        
        let speedTrack = SpeedTrackController.shared.speedTrackers[indexPath.row]
        cell.speedTrack = speedTrack
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let speedTrackToDelete = SpeedTrackController.shared.speedTrackers[indexPath.row]
            
            SpeedTrackController.shared.delete(speedTrack: speedTrackToDelete) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async { tableView.deleteRows(at: [indexPath], with: .fade)}
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let speedTrack = SpeedTrackController.shared.speedTrackers[indexPath.row]
            guard let destinationVC = segue.destination as? TrackSpeedDetailViewController else { return }
            destinationVC.speedTrack = speedTrack
        }
    }
}

extension SpeedTrackListTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Welcome"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Speed track recorded yet."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "white_gray")
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Refresh Screen"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        loadData()
    }
}
