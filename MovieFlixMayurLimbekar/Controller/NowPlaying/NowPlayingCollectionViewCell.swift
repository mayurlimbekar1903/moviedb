//
//  NowPlayingCollectionViewCell.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 12/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Alamofire


class NowPlayingCollectionViewCell: UICollectionViewCell {
    //Mark:- Variables and Constants
    let imageCache = NSCache<NSString, UIImage>()
    
    //Mark:- Design Views
    lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    
    lazy var descriptionLbl:UILabel = {
        let lbl = UILabel()
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .left
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.textColor = UIColor.darkGray
        lbl.numberOfLines = 3
        return lbl
    }()
    
    lazy var deleteBtn : UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.close)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //Mark:- initial Design setup
    private func setupView() {
        addSubview(posterImageView)
        addSubview(titleLbl)
        addSubview(descriptionLbl)
        addSubview(deleteBtn)
        
        NSLayoutConstraint.activate([
            posterImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            posterImageView.heightAnchor.constraint(equalToConstant: 80),
            posterImageView.widthAnchor.constraint(equalToConstant: 60),

            titleLbl.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            titleLbl.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 12),
            titleLbl.heightAnchor.constraint(equalToConstant: 20),
            titleLbl.trailingAnchor.constraint(equalTo: deleteBtn.trailingAnchor, constant: -8),
            deleteBtn.centerYAnchor.constraint(equalTo: titleLbl.centerYAnchor),
//            deleteBtn.topAnchor.constraint(equalTo: posterImageView.topAnchor),
            deleteBtn.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            deleteBtn.heightAnchor.constraint(equalToConstant: 34),
            deleteBtn.widthAnchor.constraint(equalToConstant: 34),
            
            descriptionLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            descriptionLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            descriptionLbl.trailingAnchor.constraint(equalTo: titleLbl.trailingAnchor),
            descriptionLbl.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    //Mark:- Attach data to view
    func configureCell(nowplaying:NowPlayingResults) {
        self.titleLbl.text = nowplaying.title
        self.descriptionLbl.text = nowplaying.overview
        
        if let posterPath = nowplaying.poster_path {
            posterImageView.image = nil
            let posterImageURL = Utility.shared.movie_poster + posterPath
            self.downloadImage(url: posterImageURL)
        }
    }
    
    //Mark:- Download image from url and attaching image to image view
    private func downloadImage(url:String) {
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            DispatchQueue.main.async {
            self.posterImageView.image = cachedImage
            }
        } else {
            AF.download(url).responseData { response in
                if let data = response.value,let image = UIImage(data: data) {
                    self.posterImageView.image = image
                    self.imageCache.setObject(image, forKey: url as NSString)
                }
            }
        }
    }
}
