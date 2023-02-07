# 마드라스체크-배태원
- [iOS - Photokit]을 사용하여 디바이스 내 사진 앨범리스트를 나타내고 앨범별 이미지를 최신순으로 정렬한 후 해당 사진의 정보를 출력합니다.
- 이미지를 클릭하면 해당 사진의 데이터 정보(파일명, 파일크기)를 메시지로 나타냅니다.

![001](https://user-images.githubusercontent.com/43931412/217058355-a5ceb0e8-c14a-4a35-94b1-dde598080601.png)

</br>

## Screen
- 로딩화면과 나머지 화면입니다.
- 화면은 AlbumController와 Album을 선택할 경우 해당 앨범별 이미지를 나타내는 GalleryController 2가지로 구성되어있습니다.
![002](https://user-images.githubusercontent.com/43931412/217058364-a4b26289-ae53-42f4-bfbf-f942aa70b9f4.png)

</br></br>

## AlbumController & GalleryController
![003](https://user-images.githubusercontent.com/43931412/217058370-214fc4b0-9546-40a2-ad8d-185cd960680c.png)

</br></br>

![004](https://user-images.githubusercontent.com/43931412/217058374-affc4e7b-31c5-4b27-8446-8eb7fbd1c420.png)

</br></br>

### 1. 전역변수 설정
- url은 Madras 클래스에 어디에서나 접근할 수 있도록 전역 변수를 설정했습니다. 
```swift
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
```

### 2. 사진첩 접근에 대한 permission check
- 디바이스 사진첩에 접근할 수 있도록 photoPermission이라는 함수를 만들어 권한 설정을 해줍니다. 
```swift
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
```
- 권한 승인 했을 경우 requestImageCollection() 메소드를 호출합니다.
- 해당 메소드에서는 앨범 리스트를 만들어주고, Recents(전체), Favorites(좋아요를 누른 앨범), 나머지 생성 된 앨범들을 만들어줍니다. 
- 앨범 각 앨범의 타이틀, 앨범별 이미지 개수 등을 array 형태로 받은 뒤 해당 데이터들을 tableview에 reload 해줍니다.
```swift
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
```
### 3. Album Controller의 TableView 설정
- tableview cell의 수 = 앨범 리스트 수
- cell 클릭시 해당 cell의 인덱스를 받아 해당 앨범에 대한 전체 이미지 데이터를 GalleryController에 넘겨준다.
- tableview cell의 height = 85pt
- Image Thumbnail size = 70pt * 70pt(가장 최근 이미지)
- 앨범 제목 font size = 17pt, Color #000000, 앨범 내 이미지 수 font size = 12pt, Color #000000
```swift
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
```
### 4. Gallery Controller의 CollectionView 설정
- collectionView 지정된 섹션에 표시할 항목의 개수 = 해당 앨범 내 이미지 수
- AlbumController에서 tableview 클릭시 할당했던 이미지 데이터 allImage를 통해 전체 이미지를 cell에 세팅
- collection view cell spacing = 4pt
- Image size = (디바이스 width - (셀간격 4pt * 2칸))/ 3 >> height = width
- 이미지 클릭시 UIAlertController를 통해 해당 이미지 정보(파일명, 파일크기)출력
```swift
extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource{
    // collectionView 지정된 섹션에 표시할 항목의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Madras.allImage?.count ?? 0
    }
    // 컬렉션뷰의 지정된 위치에 표시할 cell 요청
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        
        let asset = Madras.allImage?[indexPath.item]
        LocalImageManager.shared.requestIamge(with: asset, thumbnailSize: Madras.thumbnailSize) { (image) in
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
```
```swift
// 셀 간격 조정 및 셀 크기 조정 하는 함수들 (안먹힘 : 스토리보드에서 estimate size = none 해줘야 적용가능)
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
```
## 개발 환경

- 언어 : swift
- xcode : 14.2
- Deployment Target : iOS15
