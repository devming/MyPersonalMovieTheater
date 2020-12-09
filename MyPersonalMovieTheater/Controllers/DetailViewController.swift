//
//  DetailViewController.swift
//  MyPersonalMovieTheater
//
//  Created by Tony Jung on 2020/12/04.
//

import UIKit
import Kingfisher
import Cosmos
import AVFoundation

class DetailViewController: UIViewController {
    /// # Review 6-1 [반복되는 상수 정의]
    /// baseUrl은 지금 PlayerViewController를 제외하고는 모든 곳에서 사용되고 있네요!
    /// 여러가지 방법으로 해결해 볼 수 있겠는데요
    /// 우선 이런 상수를 별도로 Constant enum을 선언해서 사용해도 괜찮구요.
    /// 두번째 방법은 Review 6-2로 오세요.
    let baseUrl = "https://image.tmdb.org/t/p/w300/"
    var movieViewModel = MovieViewModel.shared //need to be stored in sperate Class
    
    //var gernes: [String] = ["Action","Comedy","Romance","Horror"]

 
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var ratingInStar: CosmosView!
    @IBOutlet weak var genresCollectionView: UICollectionView!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        //한발짝 느림..
        MovieViewModel.shared.genres = []
        MovieViewModel.shared.fetchMovieDetail{
            self.genresCollectionView.reloadData()
        }
        MovieViewModel.shared.fetchVideo{
            print("##completed video")
            print("\(self.movieViewModel.video.first?.key)")
        }
        MovieViewModel.shared.fetchSimilarMovies {
            print("##completed getting similar Movies")
        }
        
        print(movieViewModel.movies.count)
        movieTitle.text = movieViewModel.movies[movieViewModel.fetchMovieIndex()].title
        movieOverview.text = movieViewModel.movies[movieViewModel.fetchMovieIndex()].overview
        /// # Review 6-3 [반복되는 상수 정의]
        /// 아래처럼 url 객체를 만들 때, 아예 URL extension 에서 정의한 초기화 메소드로 해주게 되면 baseUrl을 반복적으로 각 ViewController마다 써줄 필요가 없을 거에요. 나머지도 작업해보세요!
//        let url = URL(string:"\(baseUrl)\( movieViewModel.movies[movieViewModel.fetchMovieIndex()].posterPath)")
        let imagePath = movieViewModel.movies[movieViewModel.fetchMovieIndex()].posterPath
        let url = URL(image: imagePath)
        movieImg.kf.setImage(with: url)
        rating.text = "\(movieViewModel.movies[movieViewModel.fetchMovieIndex()].rating)"
        ratingInStar.rating = movieViewModel.movies[movieViewModel.fetchMovieIndex()].rating / 2
        
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
    
        guard let key = movieViewModel.video.first?.key else {
            return
        }
        let movieKey = "https://www.youtube.com/watch?v=\(key)"
        print("@@@movie key: \(movieKey)")
        let url = URL(string: movieKey)!
        let item = AVPlayerItem(url: url)
        
        let sb = UIStoryboard(name: "Player", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        vc.modalPresentationStyle = .fullScreen
        
     //   vc.player.replaceCurrentItem(with: item)
        present(vc, animated: false, completion: nil)
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //gernes.count
        movieViewModel.genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresCell", for: indexPath) as? GenresCollectionViewCell else { return UICollectionViewCell() }
        cell.gernes.text = movieViewModel.genres[indexPath.row].name
       // cell.gernes.text = gernes[indexPath.row]
        return cell
    }
    
    
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 48)
    }
}

/// # Review 6-2 [반복되는 상수 정의]
/// 이 baseUrl이 반복적으로 사용되는 곳은 결국 URL객체를 만들기 위해서 사용되는 것이기 때문에,
/// URL 구조체 안에서 따로 선언해주는 것도 나쁘지 않은 방법일 것 같아요.
/// 그리고 지금의 경우에는 새로운 URL 초기화 메소드를 생성해주고 여기에 파라미터로 url의 뒤에 오는 주소를 넣어주는 식으로 만들어 봤습니다.
/// Review 6-3으로!
/// 아 그리고 아래 URL은 별도로 URLExtension.swift와 같이 파일을 만들어서 넣어두시면 관리하기 편할거에요.
/// 위치는 Util/Extensions 정도면 괜찮을 것 같아요.
extension URL {
    init?(image path: String) {
        let baseUrl = "https://image.tmdb.org/t/p/w300/"
        self.init(string: "\(baseUrl)\(path)")
    }
}

