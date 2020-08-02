//
//  SpeedTrackTableViewCell.swift
//  Bolt
//
//  Created by Victor Monteiro on 7/20/20.
//  Copyright © 2020 Atomuz. All rights reserved.
//

import UIKit

class SpeedTrackTableViewCell: UITableViewCell {

    //MARK: - IBOutlet
    @IBOutlet weak var speedTrackTitleLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var customBackgroundView: UIView!
    
    //MARK: - Properties
    var speedTrack: SpeedTrack? {
        didSet { updateView() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customBackgroundView.roundViewWith(proportion: 10)
    }

    //MARK: - Methods
    func updateView() {
        guard let speedTrack = speedTrack else { return }
        self.speedTrackTitleLabel.text = speedTrack.destinationLocationName
        timeStampLabel.text = speedTrack.timeStamp.dateAsString()
    }
}
