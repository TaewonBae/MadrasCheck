//
//  ViewController.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import UIKit
import Photos
class AlbumController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var album_tableview: UITableView!
    var fetchResults: [PHFetchResult<PHAsset>] = []    //앨범 정보
    let imageManager = PHCachingImageManager()    //앨범에서 사진 받아오기 위한 객체
    var fetchOptions: PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }    //앨범 정보에 대한 옵션
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "앨범"
        checkPermission()
        album_tableview.delegate = self
        album_tableview.dataSource = self
        
    }
    // TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        let cell = album_tableview.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as! AlbumTableViewCell
        //        return cell
        guard let cell = album_tableview.dequeueReusableCell(withIdentifier: "AlbumTableViewCell", for: indexPath) as? AlbumTableViewCell else {
            return UITableViewCell()
        }
        guard let asset = fetchResults[indexPath.row].firstObject else {
            return UITableViewCell()
        }
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 70, height: 70), contentMode: .aspectFill, options: nil) { (image, _) in
            cell.thumb.image = image
        }
        cell.title.text = Madras.albumTitle[indexPath.row]
        cell.cnt.text = Madras.albumCnt[indexPath.row]
        return cell
    }
    
    // 사진첩 접근에 대한 permission
    func checkPermission() {
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
        let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let favoriteList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        let albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        addAlbums(collection: cameraRoll)
        addAlbums(collection: favoriteList)
        addAlbums(collection: albumList)
        
        
        OperationQueue.main.addOperation {
            self.album_tableview.reloadData()
        }
    }
    private func addAlbums(collection : PHFetchResult<PHAssetCollection>){
        for i in 0 ..< collection.count {
            let collection = collection.object(at: i)
            //앨범 타이틀 및 이미지count 설정
            Madras.albumTitle.append(collection.localizedTitle!)
            // 아래와 같이 불러올 경우 숫자 에러
//            Madras.albumCnt.append(String(collection.estimatedAssetCount))
            let assetsFetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
            Madras.albumCnt.append(String(assetsFetchResult.count))
            self.fetchResults.append(PHAsset.fetchAssets(in: collection, options: fetchOptions))
            
        }
    }
}

