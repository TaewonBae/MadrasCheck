//
//  Madras.swift
//  madras
//
//  Created by 배태원 on 2023/02/03.
//

import Foundation
import Photos

class Madras{
    //AlbumController
    public static var fetchResults: [PHFetchResult<PHAsset>] = [] //앨범별 분류된 사진 저장
    public static var imageManager = PHCachingImageManager()    //앨범에서 사진 받아오기 위한 객체
    public static var fetchOptions: PHFetchOptions {  //앨범 정보에 대한 옵션
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }
    public static var currentIdx = 0 //Album index값
    public static var albumTitle: [String] = [] //앨범별 이름
    public static var albumCnt: [String] = [] //앨범별 개수
    public static var allImage: PHFetchResult<PHAsset>? //앨범 내 모든 이미지
    //GalleryController
    public static var galleryTitle = "" //Navigation Title(앨범 이름)
}
