

import UIKit

public struct Help_Content:Codable{
    public var title:Help_Sub_Content
    public var content:[Help_Sub_Content]?
}

public struct Help_Sub_Content:Codable{
    public var title:String
    public var description:String?
    public var image:String?
}

class HelpContentViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    @IBOutlet weak var mNavigationView: UIView!
    @IBOutlet weak var mContentTable: UITableView!
    @IBOutlet weak var mBackButton: UIButton!
    @IBOutlet weak var mCloseButton: UIButton!
    @IBOutlet weak var mViewTitle: UILabel!
    
    
    private var content:Help_Content?
    private var _title:String?
    private var kHelpContentTableViewCell = "HelpContentTableViewCell"
    private var kTitleContentTableViewCell = "TitleContentTableViewCell"
    
    convenience init(content: Help_Content, title: String){
        self.init()
        self.content = content
        self._title = title
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._Initialize()
    }
    
    @IBAction func _BackButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func _CloseButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    

}

extension HelpContentViewController{
    
    private func _Initialize(){
        self.mViewTitle.text = self._title
        self.mContentTable.register(UINib.init(nibName: kHelpContentTableViewCell, bundle: nil), forCellReuseIdentifier: App_Constants.Instance.Cell(.cell))
        self.mContentTable.register(UINib.init(nibName: kTitleContentTableViewCell, bundle: nil), forCellReuseIdentifier: App_Constants.Instance.Cell(.Cell))
    }
    
    private func _Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension HelpContentViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !((content?.title.description ?? "").isEmpty){
            return (content?.content?.count ?? 0) + 1
        }else{
            return content?.content?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !((content?.title.description ?? "").isEmpty){
            if indexPath.row == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.Cell)) as! TitleContentTableViewCell
                if !((content?.title.description ?? "").isEmpty){
                    cell.mTitle.text = content?.title.title ?? ""
                }
                cell.mDescription.text = content?.title.description ?? ""
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.cell)) as! HelpContentTableViewCell
                cell.mTitle.text = content?.content?[indexPath.row-1].title
                cell.mDescription.text = content?.content?[indexPath.row-1].description
                cell.mImage.image = UIImage(named: content?.content?[indexPath.row-1].image ?? "") ?? UIImage()
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: App_Constants.Instance.Cell(.cell)) as! HelpContentTableViewCell
            cell.mTitle.text = content?.content?[indexPath.row].title
            cell.mDescription.text = content?.content?[indexPath.row].description
            cell.mImage.image = UIImage(named: content?.content?[indexPath.row].image ?? "") ?? UIImage()
            print(cell.mImage.frame.width,cell.mImage.frame.height)
            return cell
        }
    }
    
    
}
