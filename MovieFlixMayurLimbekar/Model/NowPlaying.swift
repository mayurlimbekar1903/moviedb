//
//  NowPlaying.swift
//  MovieFlixMayurLimbekar
//
//  Created by Admin on 08/06/20.
//  Copyright © 2020 Admin. All rights reserved.
//

import Foundation

struct NowPlaying : Decodable,Hashable {
    var page:Int
    var total_pages:Int
    var total_results:Int
    var dates:NowPlayingDates
    var results:[NowPlayingResults]
}

struct NowPlayingDates:Decodable,Hashable {
    var minimum:String
    var maximum:String

}

struct NowPlayingResults:Decodable,Hashable {
    var adult:Bool
    var title:String
    var poster_path:String?
    var overview:String
    var release_date:String
    var genre_ids:[Int]
    var id:Int
    var original_title:String
    var original_language:String
    var backdrop_path:String?
    var popularity:Decimal
    var vote_count:Int
    var video:Bool
    var vote_average:Decimal
}
