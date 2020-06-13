//
//  TopRatedViewController.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 08/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import UIKit
import Alamofire

class TopRatedViewController: UIViewController {
    
    @IBOutlet weak var TopRatedCollectionView: UICollectionView!
    
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect.zero)
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section,TopRatedResults>
    typealias DataSourseSnapshot = NSDiffableDataSourceSnapshot<Section,TopRatedResults>
    
    private var datasource:DataSource!
    private var snapshot = DataSourseSnapshot()
    
    private let cellId = "cellId"
    
    var TopRatedArr = [TopRatedResults]()
    private var filteredArray = [TopRatedResults]()
    
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
        TopRatedCollectionView.register(TopRatedCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        self.TopRatedCollectionView.delegate = self
        TopRatedCollectionView.collectionViewLayout = compLayout()
        configureCollectionViewDataSource()
        self.TopRatedApi(url:Utility.shared.TopRated)
        
        // Mark:- Add search bar to navigation bar
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
    }
}

//MArk:- Search bar related work
extension TopRatedViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            self.applySnapshot(movieData: TopRatedArr)
        } else {
            filteredArray = TopRatedArr.filter(){nil != $0.title.range(of: searchBar.text!, options: String.CompareOptions.caseInsensitive)}
            self.applySnapshot(movieData: filteredArray)
        }
    }
}

//MArk:- Collection view related work
extension TopRatedViewController:UICollectionViewDelegate {
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
        datasource = DataSource(collectionView: TopRatedCollectionView, cellProvider: { (TopRatedCollectionView, indexPath, TopRated) -> TopRatedCollectionViewCell? in
            let cell = TopRatedCollectionView.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! TopRatedCollectionViewCell
            cell.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.6)
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(self.deleteBtnTapped), for: UIControl.Event.touchUpInside)
            cell.configureCell(topRated: TopRated)
            return cell
        })
    }
    
    //Mark:- Manage Delete action on cell
    @objc private func deleteBtnTapped(_ sender : UIButton) {
        TopRatedArr.remove(at: sender.tag)
        applySnapshot(movieData: TopRatedArr)
    }
    
    //Mark:- apply snap shots to the collection view
    private func applySnapshot(movieData: [TopRatedResults]) {
        snapshot = DataSourseSnapshot()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(movieData)
        datasource.apply(snapshot,animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let TopRated = datasource.itemIdentifier(for: indexPath) else { return }
        print(TopRated.title)
        let detailsView = TopRatedDeatilsViewController()
        detailsView.selectedMovie = TopRated
        detailsView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailsView, animated: true)
    }
}

//Mark:- Call api and parse json object
extension TopRatedViewController {
    func TopRatedApi(url:String) {
        AF.request(url,method: .get).responseJSON { (resp) in
            switch resp.result {
            case .success :
                print(resp.value!)
                guard let data = resp.data else { return }
                do {
                    let topRatedJSON = try JSONDecoder().decode(TopRated.self, from: data)
                    self.TopRatedArr.removeAll()
                    self.TopRatedArr = topRatedJSON.results
                    self.applySnapshot(movieData: topRatedJSON.results)
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
