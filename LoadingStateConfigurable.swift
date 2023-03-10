//
//  LoadingStateConfigurable.swift
//
//  Created by Prashan Samarathunge on 2023-03-07.
//

import UIKit

protocol LoadingStateConfigurable where Self:UIView {}
protocol LoadingStateDisplayable: LoadingStateConfigurable{
    var isPending:Bool {get set}
    func startShimmering(_ start:Bool)
}


//MARK: ViewTags
fileprivate struct ViewTags{
    static var overlayViewTag:Int = -99999
    static var coverViewTag:Int = -99998
}

//MARK: Shimmering
extension LoadingStateConfigurable where Self:UIView {

    //Exposed Variables
    var isShimmering: Bool {
        set {
            if newValue != self.isShimmering {
                startShimmering()
            } else {
                stopShimmering()
            }
        }
        
        get {
            return shimmerView != nil
        }
    }
 
    //FilePrivate
    
    fileprivate var shimmerAnimKey: String {
        return "shimmer"
    }
    
    fileprivate var shimmerView: UIView? {
        return subviews.first(where: { $0.tag == ViewTags.overlayViewTag })
    }
    
    private func addConstraints(to view:UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        let c = [view.topAnchor.constraint(equalTo: view.superview!.topAnchor, constant: 0),
                 view.trailingAnchor.constraint(equalTo:  view.superview!.trailingAnchor, constant: 0),
                 view.bottomAnchor.constraint(equalTo:  view.superview!.bottomAnchor, constant: 0),
                 view.leadingAnchor.constraint(equalTo: view.superview!.leadingAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(c)
        view.layoutIfNeeded()
    }
    
    private func makeVisible(this view:UIView){
        view.alpha = 0
        
    }
    
    private func startShimmering() {
        guard shimmerView == nil else {return}
        let gradient = CAGradientLayer()
    
        // Add overlay view
        let overlay = UIView(frame: .zero)
        overlay.clipsToBounds = true
       
        overlay.backgroundColor = .white
        overlay.alpha = 1
        overlay.tag = ViewTags.overlayViewTag
        
        addSubview(overlay)
        addConstraints(to: overlay)
       
        gradient.frame = overlay.bounds
        overlay.layer.addSublayer(gradient)
       
        
        let gradientColor1 = #colorLiteral(red: 0.7647058824, green: 0.7647058824, blue: 0.7647058824, alpha: 1).withAlphaComponent(0.85).cgColor
        let gradientColor2 = #colorLiteral(red: 0.8791421652, green: 0.8791421652, blue: 0.8791421652, alpha: 1).cgColor
        
        gradient.colors = [gradientColor1,gradientColor2,gradientColor1]
        
        gradient.locations = [0.0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.backgroundColor = UIColor.white.cgColor
        gradient.drawsAsynchronously = true
        
        let animDuration: CFTimeInterval = 0.5
        
        let anim1 = CABasicAnimation(keyPath: "locations")
        anim1.fromValue = [-1.0, -0.5, 0.0]
        anim1.toValue = [1.0, 1.5, 2.0]
        anim1.fillMode = .forwards
        anim1.duration = animDuration
        anim1.beginTime = 0
        
        
        //Grouped anim
        let group = CAAnimationGroup()
        group.animations = [anim1]
        group.repeatDuration = .infinity
        group.isRemovedOnCompletion = false
        group.beginTime = Double.random(in: 0.0...1.2)
        group.duration = group.animations!.reduce(0, { partialResult, anim in
            partialResult + anim.duration
        })
        
        gradient.add(group, forKey: shimmerAnimKey)
    }
    
    private func stopShimmering() {
        guard shimmerView != nil else {return}
        // Remove overlay view
        UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
            self?.shimmerView?.alpha = 0.0
        }completion: { [weak self] _ in
            self?.shimmerView?.removeFromSuperview()
            // Remove shimmer anim
            self?.layer.mask = nil
        }
       
    }
    
    
}

//MARK: Covering
extension LoadingStateConfigurable where Self:UIView {
    var isCovered:Bool {
        set {
            if newValue {
                addCover()
            } else {
                removeCover()
            }
        }
        
        get {
            return coverView != nil
        }
    }
    
    fileprivate var coverView: UIView? {
        return subviews.first(where: { $0.tag == ViewTags.coverViewTag })
    }
    
    //Add Cover
    private func addCover(){
        guard coverView == nil else {return}
        // Add cover view
        let cover = UIView(frame: .zero)
        cover.clipsToBounds = true
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.backgroundColor = .lightGray
        cover.alpha = 1
        cover.tag = ViewTags.coverViewTag
        
        addSubview(cover)
        addConstraints(to: cover)
        
    }
    
    ///Remove the Cover
    private func removeCover(){
        guard coverView != nil else {return}
        UIView.animate(withDuration: 0.5, delay: 0) { [weak self] in
            self?.coverView?.alpha = 0.0
        }completion: { [weak self] _ in
            self?.coverView?.coverView?.layer.removeAllAnimations()
            self?.coverView?.removeFromSuperview()
        }
    }
    
}


//MARK: Extend
extension UIView: LoadingStateConfigurable{}
