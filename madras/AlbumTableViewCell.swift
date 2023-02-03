//
//  AlbumTableViewCell.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cnt: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
