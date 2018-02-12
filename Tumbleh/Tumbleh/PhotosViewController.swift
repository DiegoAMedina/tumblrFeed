
import UIKit
import AlamofireImage

class PhotosViewController: UIViewController , UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    var posts: [[String: Any]] = []
    var refresh:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(PhotosViewController.didPTR(_:)), for: .valueChanged)
        tableView.insertSubview(refresh, at: 0)
        
        tableView.dataSource = self
        
        
        getAPI()
        print("after api")

        
    }
    
    @objc func didPTR(_ refresh:UIRefreshControl){
        getAPI()
    }
    
    func getAPI(){
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]{
                
                let responseDictionary = dataDictionary["response"] as! [String: Any]
                self.posts = responseDictionary["posts"] as! [[String: Any]]

                self.tableView.reloadData()
                self.refresh.endRefreshing()

                // TODO: Reload the table view
                //table.load after the network stuff
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]

        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            print(urlString)
            let url = URL(string: urlString)
            
            cell.imageV.af_setImage(withURL: url!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationViewController = segue.destination as! PhotoDetailsViewController
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        
        let post = posts[(indexPath?.row)!]
        
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
//            print(urlString)
            let url = URL(string: urlString)
            
            destinationViewController.photoURL = url
            
//            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
