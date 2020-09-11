//
//  PhotosCollectionViewController.swift
//  RxSwiftCameraFilter
//
//  Copyright © 2020 manato. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class PhotoCollectionViewController: UICollectionViewController {
  private let selectedPhotoSubject = PublishSubject<UIImage>()
  var selectedPhoto: Observable<UIImage> {
    selectedPhotoSubject.asObservable()
  }
  
  private var images = [PHAsset]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populatePhotos()
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    self.images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
      fatalError("NO CELL")
    }
    
    let asset = self.images[indexPath.row]
    let manager = PHImageManager.default()
    
    manager.requestImage(for: asset, targetSize: CGSize(width: 128, height: 128), contentMode: .aspectFit, options: nil) { image, _ in
      
      DispatchQueue.main.async {
        cell.photoImageView.image = image
      }
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedAsset = self.images[indexPath.row]
    
    PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { [weak self] image, info in
      guard let info = info else { return }
      
      // ignore thumnail images
      let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool
      
      if !isDegradedImage {
        if let image = image {
          self?.selectedPhotoSubject.onNext(image)
          self?.dismiss(animated: true)
        }
      }
    }
  }
  
  private func populatePhotos() {
    PHPhotoLibrary.requestAuthorization { [weak self] status in
      if status == .authorized {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        
        assets.enumerateObjects { (object, count, stop) in
          self?.images.append(object)
        }
        
        self?.images.reverse()
        
        DispatchQueue.main.async {
          self?.collectionView.reloadData()
        }
      }
    }
  }
}
