

import UIKit

class WeatherViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Sync.shared.getWeather(stationString: "OIII", callback: {(r:Bool,m:String,s:[Weather]?) in
            
        })
    }
    

}
