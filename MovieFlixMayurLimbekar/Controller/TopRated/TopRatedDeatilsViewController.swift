//
//  TopRatedDeatilsViewController.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 13/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Alamofire
class TopRatedDeatilsViewController: UIViewController {
    //Mark:- Variables and Constants
    var selectedMovie:TopRatedResults!
    var bottomViewAnchor:NSLayoutConstraint!
    
    //Mark:- Design Views
    lazy var backgrounImage:UIImageView = {
       let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleToFill
        return imgView
    }()

    lazy var activityInicator:UIActivityIndicatorView = {
       let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .black
        indicator.center = self.view.center
        return indicator
    }()
    
    lazy var bottomView:UIView = {
        let btmView = UIView()
        btmView.translatesAutoresizingMaskIntoConstraints = false
        btmView.isHidden = true
        btmView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return btmView
    }()
    
    lazy var titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        return lbl
    }()
    
    lazy var releaseDateLbl : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.font = UIFont.systemFont(ofSize: 14)
        return lbl
    }()
    
    lazy var descLbl: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.font = UIFont.boldSystemFont(ofSize: 16)
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }
    
    
    //Mark:- initial Design setup
    private func setupView() {
        view.backgroundColor = .white
        view.addSubview(backgrounImage)
        view.addSubview(bottomView)
        view.addSubview(activityInicator)
        
        bottomView.addSubview(titleLbl)
        bottomView.addSubview(releaseDateLbl)
        bottomView.addSubview(descLbl)
        
        //Mark:- apply constraints to view
        NSLayoutConstraint.activate([
            backgrounImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgrounImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgrounImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgrounImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLbl.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 12),
            titleLbl.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            titleLbl.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            titleLbl.heightAnchor.constraint(equalToConstant: 18),
            
            releaseDateLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 12),
            releaseDateLbl.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            releaseDateLbl.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            releaseDateLbl.heightAnchor.constraint(equalToConstant: 16),
            
            descLbl.topAnchor.constraint(equalTo: releaseDateLbl.bottomAnchor, constant: 8),
            descLbl.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            descLbl.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            descLbl.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -16)
        ])
        bottomViewAnchor = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40)
        bottomViewAnchor.isActive = true
        
        //Mark:- Attach data to view
        titleLbl.text = selectedMovie.title
        releaseDateLbl.text = getDates(selectedMovie.release_date)
        descLbl.text = selectedMovie.overview
        self.bottomView.isHidden = false
        
        if let backdropPath = self.selectedMovie.backdrop_path {
            let url = (Utility.shared.backgroundPath + backdropPath)
            let queue = DispatchQueue.global(qos: .background)
            self.activityInicator.startAnimating()
            queue.async {
            self.downloadImage(url: url)
            }
        }
        
        //Mark:- Adding gesture to bottom view
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    //Mark:- Convert date to specific format
    private func getDates(_ date:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateFromStr = formatter.date(from: date)
        formatter.dateFormat = "MMMM dd, yyyy"
        let convetedDate = formatter.string(from: dateFromStr!)
        return convetedDate
    }
    
    //MArk:- handling Swipe gesture
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .down:
               UIView.animate(withDuration: 0.3) {
                self.bottomViewAnchor.constant = 40
                self.view.layoutIfNeeded()
               }
            case .up:
                UIView.animate(withDuration: 0.3) {
                    self.bottomViewAnchor.constant = -60
                    self.view.layoutIfNeeded()
                }
            default:
                break
            }
        }
    }
    
    //Mark:- Download image from url and attaching image to image view
    private func downloadImage(url:String) {
            AF.download(url).responseData { response in
                DispatchQueue.main.async {
                    self.activityInicator.stopAnimating()
                    if let data = response.value,let image = UIImage(data: data) {
                        self.backgrounImage.image = image
                    }
            }
        }
    }
}
