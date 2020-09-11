//
//  ViewController.swift
//  RxSwiftCameraFilter
//
//  Copyright © 2020 manato. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
  @IBOutlet weak var applyFilterButton: UIButton!
  @IBOutlet weak var photoImageView: UIImageView!
  
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let navC = segue.destination as? UINavigationController,
      let photoCVC = navC.viewControllers.first as? PhotoCollectionViewController else {
      fatalError("NO NAV")
    }
    
    photoCVC.selectedPhoto.subscribe(onNext: { [weak self] photo in
      DispatchQueue.main.async {
        self?.updateUI(with: photo)
      }
    }).disposed(by: disposeBag)
  }
  
  private func updateUI(with image: UIImage) {
    self.photoImageView.image = image
    self.applyFilterButton.isHidden = false
  }
  
  @IBAction func applyFilterButtonPress() {
    guard let sourceImage = self.photoImageView.image else {
      return
    }
    
    FilterService().applyFilter(to: sourceImage).subscribe(onNext: { filteredImage in
      DispatchQueue.main.async {
        self.photoImageView.image = filteredImage
      }
    }).disposed(by: disposeBag)
  }
}

