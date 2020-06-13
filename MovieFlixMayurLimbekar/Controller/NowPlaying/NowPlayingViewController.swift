//
//  NowPlayingViewController.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 08/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Alamofire

class NowPlayingViewController: UIViewController {
    
    @IBOutlet weak var nowPlayingCollectionView: UICollectionView!
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect.zero)
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section,NowPlayingResults>
    typealias DataSourseSnapshot = NSDiffableDataSourceSnapshot<Section,NowPlayingResults>
    
    private var datasource:DataSource!
    private var snapshot = DataSourseSnapshot()
    
    private let cellId = "cellId"
    
    var nowPlayingArr = [NowPlayingResults]()
    private var filteredArray = [NowPlayingResults]()
    
    enum Section {
        case main
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    //Mark:- initial design setup
    private func setupView() {
        //Mark:- change background and nav bar color
        view.backgroundColor = UIColor.lightGray
        navigationController?.navigationBar.barTintColor = UIColor.systemOrange
        navigationController?.navigationBar.tintColor = UIColor.black
        
        //MArk:- Collection view setup and call api
        nowPlayingCollectionView.register(NowPlayingCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        self.nowPlayingCollectionView.delegate = self
        nowPlayingCollectionView.collectionViewLayout = compLayout()
        configureCollectionViewDataSource()
        self.nowPlayingApi(url:Utility.shared.NoWPlaying)
        
        // Mark:- Add search bar to navigation bar
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
}

//MArk:- Search bar related work
extension NowPlayingViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.applySnapshot(movieData: nowPlayingArr)
        } else {
            filteredArray = nowPlayingArr.filter(){nil != $0.title.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive)}
            self.applySnapshot(movieData: filteredArray)
        }
    }
}

//MArk:- Collection view related work
extension NowPlayingViewController:UICollectionViewDelegate {
    //Mark:- Create Compoitional layout
    func compLayout() -> UICollectionViewCompositionalLayout {
       return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
              let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
              item.contentInsets.bottom = 1
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
            }
    }
    
    //Mark:- configure CollectionView DataSource data i.e attach values of data to view
    private func configureCollectionViewDataSource() {
        datasource = DataSource(collectionView: nowPlayingCollectionView, cellProvider: { (nowPlayingCollectionView, indexPath, nowplaying) -> NowPlayingCollectionViewCell? in
            let cell = nowPlayingCollectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! NowPlayingCollectionViewCell
            cell.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.6)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(self.deleteBtnTapped), for: UIControl.Event.touchUpInside)
            cell.configureCell(nowplaying: nowplaying)
            return cell
        })
    }
    
    //Mark:- Manage Delete action on cell
    @objc private func deleteBtnTapped(_ sender : UIButton) {
        nowPlayingArr.remove(at: sender.tag)
        applySnapshot(movieData: nowPlayingArr)
    }
    
    //Mark:- apply snap shots to the collection view
    private func applySnapshot(movieData: [NowPlayingResults]) {
        snapshot = DataSourseSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(movieData)
        datasource.apply(snapshot,animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nowPlaying = datasource.itemIdentifier(for: indexPath) else { return }
        print(nowPlaying.title)
        let detailsView = NowPlayingDeatilsViewController()
        detailsView.selectedMovie = nowPlaying
        detailsView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailsView, animated: true)
    }
}

//Mark:- Call api and parse json object
extension NowPlayingViewController {
    func nowPlayingApi(url:String) {
        AF.request(url,method: .get).responseJSON { (resp) in
            switch resp.result {
            case .success :
                print(resp.value!)
                guard let data = resp.data else { return }
                do {
                    let nowPlaying = try JSONDecoder().decode(NowPlaying.self, from: data)
                    self.nowPlayingArr.removeAll()
                    self.nowPlayingArr = nowPlaying.results
                    self.applySnapshot(movieData: nowPlaying.results)
                } catch let jsonErr {
                    print("json serializing error:- ",jsonErr)
                }
                break
            case .failure(let err):
                print("Error :- \(err)")
            }
        }
    }
}
