//
//  TopRated.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 13/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

struct TopRated:Decodable,Hashable{
    var page:Int
    var results:[TopRatedResults]
    var total_results : Int
    var total_pages:Int
    
}

struct TopRatedResults :Decodable,Hashable{
    var poster_path:String?
    var adult:Bool
    var overview:String
    var release_date:String
    var genre_ids:[Int]
    var id:Int
    var original_title:String
    var original_language:String
    var title:String
    var backdrop_path:String?
    var popularity:Decimal
    var vote_count:Int
    var video:Bool
    var vote_average:Decimal
}


