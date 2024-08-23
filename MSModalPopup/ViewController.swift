import UIKit

class ViewController: UIViewController {
    
    let backgroundImage:UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "background")
        return view
    }()
    
    let button:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.setTitle("Button", for: .normal)
        view.backgroundColor = UIColor.white
        view.setTitleColor(UIColor.black, for: .normal)
        view.addTarget(self, action: #selector(openPopUp), for: .touchUpInside)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func openPopUp(){
        // MARK: need to set the default modal animation to false
        let popUpVC = PopUpVC(titleModal: "Title", displayCloseButton: true)
        self.present(popUpVC, animated: false, completion: nil)
    }
    
    func setupViews(){
        view.addSubview(backgroundImage)
        backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

}
