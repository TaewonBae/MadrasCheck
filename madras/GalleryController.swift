//
//  GalleryController.swift
//  madras
//
//  Created by 배태원 on 2023/02/04.
//

import UIKit
import Photos

class GalleryController: UIViewController{
    
    
    @IBOutlet weak var gallery_collectionview: UICollectionView!
    
    var allMedia: PHFetchResult<PHAsset>?
    
    let scale = UIScreen.main.scale
    var thumbnailSize = CGSize.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Madras.galleryTitle //앨범 타이틀
        backBtn() // left navigation Item 뒤로가기
        
        gallery_collectionview.delegate = self
        gallery_collectionview.dataSource = self
        
        
        self.thumbnailSize = CGSize(width: 1024 * self.scale, height: 1024 * self.scale)
        
        self.gallery_collectionview.reloadData()
        
        
        
        
    }
    
    
    
    
    //Back Button
    func backBtn(){
        // 이미지 및 크기 조절
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20) //image frame 20*20
        backBtn.setImage(UIImage(named:"icon_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(onClickBackBtn(_:)), for: UIControl.Event.touchUpInside)
        
        // UIBarButtonItem의 leftBarButtonItem 할당, width * hegith = 26 * 26
        let menuBarItem = UIBarButtonItem(customView: backBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 26)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 26)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    //Back버튼 클릭 이벤트
    @IBAction func onClickBackBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
// 셀 간격 조정 및 셀 크기 조정 하는 함수들 >> 안먹힘 : 스토리보드에서 estimate size = none 해줘야 적용가능
extension GalleryController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격 : 4pt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    // 옆 간격 : 4pt
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 전체 width에서 4pt 두칸의 여백을 빼준 뒤 3을 나눠주면  셀 하나의 width를 구할 수 있다.
        let interval:CGFloat = 4
        let width: CGFloat = ( UIScreen.main.bounds.width - interval * 2 ) / 3   //cell width = (전체 - (4pt * 여백2개)) / 3
        let size = CGSize(width: width, height: width)
        return size
    }
    
}
extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    // collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Madras.allImage?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        
        let asset = Madras.allImage?[indexPath.item]
        LocalImageManager.shared.requestIamge(with: asset, thumbnailSize: self.thumbnailSize) { (image) in
            cell.gallery_img.image = image
        }
        return cell
    }
    
    //컬렉션 뷰 클릭이벤트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = Madras.allImage!.object(at: indexPath.row)
        
        var byte = ""
        let resources = PHAssetResource.assetResources(for: asset)
        let filename = resources.first!.originalFilename
        
        //file 크기 >> MB로 변환
        var sizeOnDisk: Int64 = 0
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            let sizeImage = round(Double(sizeOnDisk) / (1024.0*1024.0) * 10) / 10
            byte = String(format: "%.1f", sizeImage) + " MB" //소숫점 1째자리 적용
        }
        // AlertController로 사진정보(파일명, 파일크기) 알림 메시지
        let alert = UIAlertController(title: "사진정보", message: "파일명 : "+filename+"\n파일크기 : "+byte, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in}))
        self.present(alert, animated: true, completion: nil)
    }
}
final class LocalImageManager {
    
    static var shared = LocalImageManager()
    fileprivate let imageManager = PHImageManager()
    var representedAssetIdentifier: String?
    func requestIamge(with asset: PHAsset?, thumbnailSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard let asset = asset else {
            completion(nil)
            return
        }
        self.representedAssetIdentifier = asset.localIdentifier
        self.imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
            if self.representedAssetIdentifier == asset.localIdentifier {
                completion(image)
            }
        })
    }
}
