//
//  AlbumTableViewCell.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var thumb: UIImageView! //앨범 썸네일 이미지
    @IBOutlet weak var title: UILabel! //앨범 타이틀
    @IBOutlet weak var cnt: UILabel! //앨범내 이미지 수
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
