//
//  Madras.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import Foundation
import Photos
import UIKit

class Madras{
    //AlbumController
    public static var fetchResults: [PHFetchResult<PHAsset>] = [] //앨범별 분류된 사진 저장
    public static var imageManager = PHCachingImageManager()    //앨범에서 사진 받아오기 위한 객체
    public static var fetchOptions: PHFetchOptions {  //앨범 정보에 대한 옵션
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    public static var cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)//recents
    public static var favoriteList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)//Favorites
    public static var albumList = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)// 나머지 생성된 앨범들
    public static var currentIdx = 0 //Album list index값
    public static var albumTitle: [String] = [] //앨범별 이름
    public static var albumCnt: [String] = [] //앨범별 개수
    public static var allImage: PHFetchResult<PHAsset>? //앨범 내 모든 이미지
    
    //GalleryController
    public static var galleryTitle = "" //Navigation Title(앨범 이름)
    public static var scale = UIScreen.main.scale //화면 scale
    public static var thumbnailSize = CGSize.zero // 이미지 Thumbnail Size
}
