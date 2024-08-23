import UIKit

class ModalVC: UIViewController {
    
    let navbarView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let mainView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let contentView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleModalView:UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.font = UIFont.systemFont(ofSize: 30)
        view.textColor = UIColor.black
        return view
    }()
    
    let closeButton:UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "x-icon")
        view.setImage(image, for: .normal)
        view.imageView?.tintColor = UIColor.black
        view.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        return view
    }()
    
    let blurView:UIView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurEffectView
    }()
    
    
    var minimumVelocityToHide = 1500 as CGFloat
    var minimumScreenRatioToHide = 0.3 as CGFloat
    var animationDuration = 0.2 as TimeInterval
    var initialMainY:CGFloat!
    var maxHeight:CGFloat!
    var initialDragY:CGFloat!
    var CORNER_RADIUS_DIVIDE:CGFloat = 40
    var MAX_BLUR:CGFloat = 1
    var titleModal:String!
    var displayCloseButton = false
    var navbar = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        navbar = false
    }
    
    init(titleModal:String, displayCloseButton:Bool) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        
        self.titleModal = titleModal
        self.displayCloseButton = displayCloseButton
        self.navbar = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        initialMainY = (self.view.frame.height - mainView.frame.height)/2
        maxHeight = UIScreen.main.bounds.height
        mainView.addGestureRecognizer(panGesture)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.mainView.frame.origin.y = maxHeight
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mainView.frame.origin.y = self.initialMainY
            self.blurView.alpha = self.MAX_BLUR
        }, completion: nil)
    }
    
    func slideViewVerticallyTo(_ y: CGFloat, view:UIView) {
        view.frame.origin = CGPoint(x: view.frame.origin.x, y: y)
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: self.mainView)
            let y = max(initialMainY, translation.y)
            self.slideViewVerticallyTo(y, view: self.mainView)
            
            if (initialDragY == nil){
                initialDragY = y
            } else {
                var opacity = (initialDragY / y)
                if opacity > MAX_BLUR {
                    opacity = MAX_BLUR
                }
                self.blurView.alpha = opacity
            }
            print(y)
            
            break
        case .ended:
            // If pan ended, decide it we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: self.mainView)
            let velocity = panGesture.velocity(in: self.mainView)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    self.blurView.alpha = 0
                    self.slideViewVerticallyTo(self.view.frame.size.height, view: self.mainView)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    self.blurView.alpha = self.MAX_BLUR
                    self.slideViewVerticallyTo(self.initialMainY, view: self.mainView)
                })
            }
            break
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                self.blurView.alpha = self.MAX_BLUR
                self.slideViewVerticallyTo(self.initialMainY, view: self.mainView)
            })
            break
        }
    }
    
    @objc func closeModal(){
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            self.mainView.frame.origin.y = self.maxHeight
            self.blurView.alpha = 0
        }, completion: { (isCompleted) in
            if isCompleted {
                // Dismiss the view when it dissapeared
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.clear
        view.addSubview(blurView)
        blurView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        view.addSubview(mainView)
        mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mainView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        mainView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8).isActive = true
        mainView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.8).isActive = true
        mainView.setNeedsLayout()
        mainView.layoutIfNeeded()
        mainView.layer.cornerRadius = mainView.frame.height / CORNER_RADIUS_DIVIDE
        
        if (navbar == true){
            mainView.addSubview(navbarView)
            navbarView.leftAnchor.constraint(equalTo: self.mainView.leftAnchor).isActive = true
            navbarView.rightAnchor.constraint(equalTo: self.mainView.rightAnchor).isActive = true
            navbarView.topAnchor.constraint(equalTo: self.mainView.topAnchor).isActive = true
            navbarView.heightAnchor.constraint(equalToConstant: 55).isActive = true
            
            navbarView.addSubview(titleModalView)
            titleModalView.centerXAnchor.constraint(equalTo: navbarView.centerXAnchor).isActive = true
            titleModalView.bottomAnchor.constraint(equalTo: navbarView.bottomAnchor, constant: -8).isActive = true
            titleModalView.text = titleModal
            
            if (displayCloseButton){
                navbarView.addSubview(closeButton)
                closeButton.rightAnchor.constraint(equalTo: navbarView.rightAnchor, constant: -8).isActive = true
                closeButton.topAnchor.constraint(equalTo: navbarView.topAnchor, constant: 8).isActive = true
                closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
                closeButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
            }
            
            mainView.addSubview(contentView)
            contentView.topAnchor.constraint(equalTo: navbarView.bottomAnchor).isActive = true
            contentView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
            contentView.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        } else {
            mainView.addSubview(contentView)
            contentView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
            contentView.leftAnchor.constraint(equalTo: mainView.leftAnchor).isActive = true
            contentView.rightAnchor.constraint(equalTo: mainView.rightAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
        }
        
    }
    
}
