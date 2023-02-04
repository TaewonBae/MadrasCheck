//
//  GalleryController.swift
//  madras
//
//  Created by 배태원 on 2023/02/04.
//

import UIKit
import Photos

class GalleryController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var gallery_collectionview: UICollectionView!
    @IBOutlet weak var navigationItem_: UINavigationItem!
    
    var allMedia: PHFetchResult<PHAsset>?
    
    let scale = UIScreen.main.scale
    var thumbnailSize = CGSize.zero
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem_.title = Madras.galleryTitle
        homeSettingBtn()
        
        gallery_collectionview.delegate = self
        gallery_collectionview.dataSource = self
        
        // MAKR: - 모든 미디어 가져오는 메소드
        //        self.allMedia = PHAsset.fetchAssets(with: nil)
        
        let creationDateFet = PHFetchOptions()
        creationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let listfet = PHFetchOptions()
        listfet.sortDescriptors = [NSSortDescriptor(key: "localizedTitle", ascending: false)]
        
        if(Madras.currentIdx == 0){
            
            let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            let userAlbum: PHAssetCollection = userAlbumList.object(at: 0)
            self.allMedia = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
        }else if(Madras.currentIdx == 1){
            let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
            let userAlbum: PHAssetCollection = userAlbumList.object(at: 0)
            self.allMedia = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
        }else{
            //생성날짜 최근거부터 정렬(내림차순)
            let userAlbumList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
            let userAlbum: PHAssetCollection = userAlbumList.object(at: Madras.currentIdx-2) 
            self.allMedia = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
            // MAKR: - 특정 타입(PHAssetMediaType) 미디어만 가져오는 메소드
            //self.allMedia = PHAsset.fetchAssets(with: .image, options: nil)
            
        }
        
        
        self.thumbnailSize = CGSize(width: 1024 * self.scale, height: 1024 * self.scale)
        self.gallery_collectionview.reloadData()
        
        
    }
    
    // collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.allMedia?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        let asset = self.allMedia?[indexPath.item]
        LocalImageManager.shared.requestIamge(with: asset, thumbnailSize: self.thumbnailSize) { (image) in
            
            cell.gallery_img.image = image
        }
        return cell
    }
    
    //컬렉션 뷰 클릭이벤트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    //Back Button
    func homeSettingBtn(){
        // 이미지 및 크기 조절
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"icon_back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(onClick_home_setting_btn(_:)), for: UIControl.Event.touchUpInside)
        // UIBarButtonItem의 rightBarButtonItem 할당
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 26)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 26)
        currHeight?.isActive = true
        navigationItem_.leftBarButtonItem = menuBarItem
    }
    //세팅버튼 클릭 이벤트
    @IBAction func onClick_home_setting_btn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
// 셀 간격 조정 및 셀 크기 조정 하는 함수들 >> 이거 안먹힘 : 스토리보드에서 estimate size = none 해줘야됨
extension GalleryController: UICollectionViewDelegateFlowLayout {
    
    // 위 아래 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // 옆 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    // cell 사이즈( 옆 라인을 고려하여 설정 )
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 3 - 2///  3등분하여 배치
        
        let size = CGSize(width: width, height: width)
        return size
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
