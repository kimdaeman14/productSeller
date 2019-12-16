//
//  DetailViewController.swift
//  ZoomTransition
//
//  Created by Jaycee on 2019/12/10.
//  Copyright © 2019 Jaycee. All rights reserved.
//

import UIKit
import SwiftyJSON

class DetailViewController: UIViewController {
    
    private var json:JSON = JSON(arrayLiteral: "")
    private var imgURLArray:[String] = []
    private var buyButton = UIButton()
    private var imageView = UIImageView()
    public var productID:Int = 0

    
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var productSeller: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDiscountRate: UILabel!
    @IBOutlet weak var productDiscountCost: UILabel!
    @IBOutlet weak var productCost: UILabel!
    @IBOutlet weak var productNotDiscountCost: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var productInfomationView: UIView!
    @IBOutlet weak var productInfomationLabel: UILabel!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separationBorder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialDataConfigure()
        configureInitial()
    }
    
    @IBAction func XButtonDidTap(sender: UIButton) {
        let transition: CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    private func initialDataConfigure(){
        API.productDetails(productID).responseJSON { (response) in
            switch response.result{
            case .success(let value):
                let value = JSON(value)
                self.json = value["body"]
                if(self.json[0]["discount_rate"].string ?? "" == ""
                    || self.json[0]["discount_cost"].string ?? "" == ""){
                    self.productNotDiscountCost.text = self.json[0]["cost"].string ?? ""
                    self.productNotDiscountCost.isHidden = false
                    self.productDiscountRate.isHidden = true
                    self.productDiscountCost.isHidden = true
                    self.productCost.isHidden = true
                }else{
                    self.productNotDiscountCost.isHidden = true
                }
                self.productSeller.text = self.json[0]["seller"].string ?? ""
                self.productTitle.text = self.json[0]["title"].string ?? ""
                self.productDiscountRate.text = self.json[0]["discount_rate"].string ?? ""
                self.productDiscountCost.text = self.json[0]["discount_cost"].string ?? ""
                self.productCost.text = self.json[0]["cost"].string ?? ""
                self.productSeller.text = self.json[0]["title"].string ?? ""
                self.productDescription.text = self.json[0]["description"].string ?? ""
                
                let imgURLString = self.json[0]["thumbnail_list_320"].string ?? ""
                self.imgURLArray = imgURLString.components(separatedBy: "#")
                
                let contentWidth = CGFloat(Int(self.collectionView.frame.width) * self.imgURLArray.count)
                let initialProgress = Float(self.collectionView.frame.width/contentWidth)
                self.progressBar.setProgress(initialProgress, animated: true)
                self.progressBar.progressTintColor = UIColor.white
                self.progressBar.trackTintColor = UIColor.gray
                
                let total = self.productDescription.intrinsicContentSize.height + self.collectionView.frame.height + self.productInfomationView.frame.height + self.productTitle.intrinsicContentSize.height + 300
                self.contentViewHeightConstraint.constant = total
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    private func configureInitial(){
        collectionView.register(UINib(nibName: ImageCell.nibName, bundle: nil), forCellWithReuseIdentifier: ImageCell.reusableIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        xButton.layer.cornerRadius = xButton.frame.width/2
        xButton.backgroundColor = UIColor.darkAlpha
        
        productInfomationView.layer.cornerRadius = 14
        productInfomationView.backgroundColor = UIColor.paleGrey
        
        productInfomationLabel.textColor = UIColor.coolGrey
        
        separationBorder.backgroundColor = UIColor.lightGray
        
        productSeller.textColor = UIColor.darkSkyBlue
        
        productTitle.textColor = UIColor.dark
        productNotDiscountCost.textColor = UIColor.dark
        productDescription.textColor = UIColor.dark
        productDiscountCost.textColor = UIColor.dark
        
        productDiscountRate.textColor = UIColor.coralPink
        
        productCost.textColor = UIColor.blueyGrey
        
        buyButton.frame = CGRect(x: 24, y: view.frame.height + 100, width: view.frame.width - (24 * 2), height: 52)
        buyButton.backgroundColor = UIColor.coralPink
        buyButton.setTitle("구매하기", for: .normal)
        buyButton.backgroundColor = UIColor.init(displayP3Red: 255/255, green: 88/255, blue: 108/255, alpha: 1.0)
        buyButton.layer.cornerRadius = 14
        view.addSubview(buyButton)
    }
    
    
    @objc private func buybuttonAnimation(){
        UIView.animate(
            withDuration: 1.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.buyButton.frame.origin.y = self.view.frame.height - 80
        })
    }
}



extension DetailViewController: RMPZoomTransitionAnimating {
    
    var transitionSourceImageView: UIImageView {
        let imageView = UIImageView(image: self.imageView.image)
        imageView.contentMode = self.imageView.contentMode
        //        imageView.backgroundColor = .yellow
        //        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.imageView.frame
        return imageView;
    }
    
    var transitionSourceBackgroundColor: UIColor? {
        return view.backgroundColor
    }
    
    var transitionDestinationImageViewFrame: CGRect {
        let frame = self.collectionView.frame
        return frame
    }
}

extension DetailViewController: RMPZoomTransitionDelegate {
    func zoomTransitionAnimator(animator: RMPZoomTransitionAnimator,
                                didCompleteTransition didComplete: Bool,
                                animatingSourceImageView imageView: UIImageView) {
        buybuttonAnimation()
    }
}




extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgURLArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.nibName, for: indexPath) as! ImageCell
        
        if let url = URL(string: imgURLArray[indexPath.row]){
            cell.imageView.downloaded(from: url)
            cell.imageView.contentMode = .scaleToFill
        }else{
            cell.imageView.image = UIImage.init(named: "imgNotFound")
        }
        return cell
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}


extension DetailViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        
        let progress = Float(scrollView.frame.width/contentWidth) + Float(offSetX/contentWidth)
        progressBar.setProgress(progress, animated: true)
    }
    
}

