//
//  ViewController2.swift
//  ZoomTransition
//
//  Created by Jaycee on 2019/12/10.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit
import SwiftyJSON

class ListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private static let numberOfDataShowing = 20
    private var numberOfPageRequest = 1
    private var dataFromServer:JSON = JSON(arrayLiteral: "")
    private var product:[JSON] = []
    private var selectedDataID = 0
    private var fetchingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialDataConfigure()
        configureInitial()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        segue.destination.transitioningDelegate = self
        
        if let vc = segue.destination as? DetailViewController {
            vc.productID = selectedDataID
        }else{
            print(segue.destination)
        }
    }
    
    private func initialDataConfigure(){
        API.products(numberOfPageRequest).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let value = JSON(value)
                self.dataFromServer = value["body"]
                self.product = self.dataFromServer.filter{$0.1["id"].int ?? 0 <= ListViewController.numberOfDataShowing}.map{$0.1}
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func configureInitial(){
        collectionView.register(UINib(nibName: ItemCell.nibName, bundle: nil), forCellWithReuseIdentifier: ItemCell.reusableIdentifier)
        collectionView.register(UINib(nibName: LoadingCell.nibName, bundle: nil), forCellWithReuseIdentifier: LoadingCell.reusableIdentifier)
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        self.collectionView.collectionViewLayout = layout
    }
}




extension ListViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return product.count
        }else if section == 1 && fetchingMore {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.nibName, for: indexPath) as! ItemCell
            if let url = URL(string: product[indexPath.row]["thumbnail_520"].string ?? ""){
                cell.imageView.downloaded(from: url)
            }else{
                cell.imageView.image = UIImage.init(named: "imgNotFound")
            }
            cell.title.text = product[indexPath.row]["title"].string ?? ""
            cell.subtitle.text = product[indexPath.row]["seller"].string ?? ""
            cell.imageView.contentMode = .scaleToFill
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.nibName, for: indexPath) as! LoadingCell
            cell.myIndicator.spin(repeatCount: 20)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 2 {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    
    private func beginBatchFetch() {
        
        fetchingMore = true
        collectionView.reloadSections(IndexSet(integer: 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            
            // MARK: - Always add Data According to NumberOfDataShowing.
            let tempData = self.dataFromServer.filter{
                let id = $0.1["id"].int ?? 0
                return id > self.numberOfPageRequest * ListViewController.self.numberOfDataShowing
                    && id <= (self.numberOfPageRequest + 1) * ListViewController.self.numberOfDataShowing}
                .map{$0.1}
            self.product.append(contentsOf: tempData)
            self.numberOfPageRequest += 1
            
            
            // MARK: - Add Data From Server.
            API.products(self.numberOfPageRequest).responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let value = JSON(value)
                    self.dataFromServer = self.dataFromServer.merged(other: value["body"])
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.fetchingMore = false //append가 다 됐으니까 이제 그만 더하고 리로드 해라 그거지.
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedDataID = product[indexPath.row]["id"].int ?? 0
        performSegue(withIdentifier: "showdetail", sender: self) //이거 꼭필요하네?
        
        
    }
}




// MARK: - UICollectionViewDelegateFlowLayout
extension ListViewController: UICollectionViewDelegateFlowLayout {
    
    private struct Metric {
        static let numberOfItem: CGFloat = 2
        static let numberOfLine: CGFloat = 2
        
        static let leftPadding: CGFloat = 10.0
        static let rightPadding: CGFloat = 10.0
        static let topPadding: CGFloat = 10.0
        static let bottomPadding: CGFloat = 10.0
        
        static let itemSpacing: CGFloat = 10.0
        static let lineSpacing: CGFloat = 10.0
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if indexPath.section == 0 {
            let itemSpacing = Metric.itemSpacing * (Metric.numberOfItem - 1)
            let horizontalPadding = Metric.leftPadding + Metric.rightPadding
            let totalSpacing = itemSpacing + horizontalPadding
            let width = (collectionView.frame.width - totalSpacing) / Metric.numberOfItem
            return CGSize(width: width, height: 300)
        }else{
            return CGSize(width: view.frame.width, height: 50)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Metric.lineSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return Metric.itemSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: Metric.topPadding, left: Metric.leftPadding,
                            bottom: Metric.bottomPadding, right: Metric.rightPadding)
    }
}




extension ListViewController: RMPZoomTransitionAnimating {
    var transitionSourceImageView: UIImageView {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
        let cell = self.collectionView.cellForItem(at: selectedIndexPath) as! ItemCell
        let imageView = UIImageView(image: cell.imageView.image)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = cell.imageView.convert(cell.imageView.frame, to: self.collectionView.superview)
        return imageView;
    }
    
    var transitionSourceBackgroundColor: UIColor? {
        return self.collectionView.backgroundColor
    }
    
    var transitionDestinationImageViewFrame: CGRect {
        let selectedIndexPath = self.collectionView.indexPathsForSelectedItems!.first!
        let cell = self.collectionView.cellForItem(at: selectedIndexPath) as! ItemCell
        let cellFrameInSuperview = cell.imageView.convert(cell.imageView.frame, to: self.collectionView.superview)
        return cellFrameInSuperview
    }
}




extension ListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceTransition = source as? RMPZoomTransitionAnimating,
            let destinationTransition = presented as? RMPZoomTransitionable else {
                return nil
        }
        
        let animator = RMPZoomTransitionAnimator()
        animator.goingForward = true
        animator.sourceTransition = sourceTransition
        animator.destinationTransition = destinationTransition
        return animator;
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let sourceTransition = dismissed as? RMPZoomTransitionAnimating else {
            return nil
        }
        let destinationTransition = self
        
        let animator = RMPZoomTransitionAnimator()
        animator.goingForward = false
        animator.sourceTransition = sourceTransition
        animator.destinationTransition = destinationTransition as? RMPZoomTransitionable
        return animator;
    }
}





