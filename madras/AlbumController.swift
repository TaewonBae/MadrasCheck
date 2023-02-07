//
//  ViewController.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import UIKit
import Photos
class AlbumController: UIViewController{
    
    @IBOutlet weak var album_tableview: UITableView! //AlbumController tableview 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = "앨범"
        photoPermission() // 사진첩 접근 설정
        album_tableview.delegate = self
        album_tableview.dataSource = self
        
    }
    
    // 사진첩 접근에 대한 permission
    func photoPermission() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            self.requestImageCollection()
        case .denied: break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                switch $0 {
                case .authorized:
                    self.requestImageCollection()
                case .denied: break
                default:
                    break
                }
            })
        default:
            break
        }
    }
    
    func requestImageCollection() {
        addAlbums(collection: Madras.cameraRoll)
        addAlbums(collection: Madras.favoriteList)
        addAlbums(collection: Madras.albumList)
        
        DispatchQueue.main.async {
            self.album_tableview.reloadData()
        }
    }
    func addAlbums(collection : PHFetchResult<PHAssetCollection>){
        for i in 0 ..< collection.count {
            let collection = collection.object(at: i)
            //앨범 타이틀 및 앨범내 이미지 개수 설정
            Madras.albumTitle.append(collection.localizedTitle!)
            let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            Madras.albumCnt.append(String(assetsFetchResult.count))
            Madras.fetchResults.append(PHAsset.fetchAssets(in: collection, options: Madras.fetchOptions))
            
        }
    }
    
}

extension AlbumController: UITableViewDelegate, UITableViewDataSource{
    // TableView cell수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Madras.fetchResults.count
    }
    // TableView cell에 앨범 데이터(이미지, 제목, 이미지 수) 할당
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = album_tableview.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as? AlbumTableViewCell else {
            return UITableViewCell()
        }
        guard let asset = Madras.fetchResults[indexPath.row].firstObject else {
            return UITableViewCell()
        }
        //앨범 리스트에 표시할 이미지(thumbnail size : 70pt * 70pt)
        Madras.imageManager.requestImage(for: asset, targetSize: CGSize(width: 70, height: 70), contentMode: .aspectFill, options: nil) { (image, _) in
            cell.thumb.image = image
        }
        cell.title.text = Madras.albumTitle[indexPath.row]
        cell.cnt.text = Madras.albumCnt[indexPath.row]
        return cell
    }
    // TableView cell 클릭 Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GalleryController") as! GalleryController
        nextVC.modalPresentationStyle = .overFullScreen
        
        Madras.currentIdx = indexPath.row // 현재 인덱스(몇번째 테이블 cell인지)
        Madras.galleryTitle = Madras.albumTitle[indexPath.row]
        
        let creationDateFet = PHFetchOptions() //생성날짜 최신순으로 정렬(내림차순)
        creationDateFet.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        //각 폴더 내 이미지 데이터 setting
        if(Madras.currentIdx == 0){ // Device내 전체 이미지
            let userAlbumList: PHFetchResult<PHAssetCollection> = Madras.cameraRoll
            let userAlbum: PHAssetCollection = userAlbumList.object(at: 0)
            Madras.allImage = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
        }else if(Madras.currentIdx == 1){ //좋아요 누른 이미지(Favorites 폴더)
            let userAlbumList: PHFetchResult<PHAssetCollection> = Madras.favoriteList
            let userAlbum: PHAssetCollection = userAlbumList.object(at: 0)
            Madras.allImage = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
        }else{ // 나머지 생성된 폴더
            let userAlbumList: PHFetchResult<PHAssetCollection> = Madras.albumList
            let userAlbum: PHAssetCollection = userAlbumList.object(at: Madras.currentIdx-2)
            Madras.allImage = PHAsset.fetchAssets(in: userAlbum, options: creationDateFet)
        }
    }
    //tableview cell height : 85pt 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
