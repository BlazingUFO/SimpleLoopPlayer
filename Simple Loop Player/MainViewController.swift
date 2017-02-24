//
//  ViewController.swift
//  Simple Loop Player
//
//  Created by Peter Zeman on 24.2.17.
//  Copyright © 2017 Procus s.r.o. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var nextBtn:UIButton!
    @IBOutlet var sampleVideoButton:UIButton!
    var videoURL: NSURL?
    let imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        setupAppearence()
        
     
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupAppearence(){
        
        let theWidth = self.view.frame.width
        let theHeight = self.view.frame.height
        
        let background = UIImageView(frame: CGRect(x: 0, y: 0, width: theWidth, height: theHeight))
        let backgroundImage = UIImage(named: "login")
        background.image = backgroundImage
        self.view.addSubview(background)
        
        
        
        
        sampleVideoButton = UIButton(frame: CGRect(x: 10, y: 60, width: theWidth - 20, height: 200))
        if let image = UIImage(named: "sampleVideo") {
            self.sampleVideoButton.setImage(image, for: .normal)
        }
        sampleVideoButton.addTarget(self, action: #selector(playSampleVideo), for: .touchUpInside)
        
        sampleVideoButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        sampleVideoButton.imageView?.contentMode = .scaleAspectFit
     
        sampleVideoButton.layer.borderWidth = 3
        sampleVideoButton.layer.borderColor = UIColor(red: 247/255.0, green: 215/255.0, blue: 129/255.0, alpha: 1).cgColor
        
        view.addSubview(sampleVideoButton)
        
        let sampleVideoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
        sampleVideoLabel.center = CGPoint(x: theWidth/2, y: sampleVideoButton.frame.maxY + 40)
        sampleVideoLabel.textColor = UIColor.white
        sampleVideoLabel.text = NSLocalizedString("MainViewController.sampleVideo", comment: "info text under btns")
        
        sampleVideoLabel.textAlignment = .center
        self.view.addSubview(sampleVideoLabel)
        
        
    
        nextBtn = UIButton(frame: CGRect(x: 0, y: (theHeight - 30 - (35)), width: theWidth-60, height: 35))
        
        
        
        nextBtn.center.x = self.view.center.x
        nextBtn.setBackgroundImage(UIImage(color: UIColor(red: 217/255, green: 178/255, blue: 59/255, alpha: 0.5)), for: .highlighted)
        nextBtn.setBackgroundImage(UIImage(color: UIColor.clear), for: .normal)
        nextBtn.layer.borderColor = UIColor(red: 243/255, green: 211/255, blue: 95/255, alpha: 1).cgColor
        nextBtn.layer.borderWidth = 1
        nextBtn.setTitle(NSLocalizedString("MainViewController.selectVideo", comment: "select video button placeholder"), for: .normal)
        nextBtn.addTarget(self, action: #selector(selectVideo), for: UIControlEvents.touchUpInside)
        nextBtn.titleLabel?.font = UIFont(name: "OpenSans", size: 15)
        self.view.addSubview(nextBtn)
        
        let orLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 35))
        orLabel.center = CGPoint(x: theWidth/2, y: nextBtn.frame.minY - 40)
        orLabel.textColor = UIColor.white
        orLabel.text = NSLocalizedString("MainViewController.or", comment: "info text under btns")
        
        orLabel.textAlignment = .center
        self.view.addSubview(orLabel)

    }
    
    
    func playSampleVideo(){
        guard let path = Bundle.main.path(forResource: "video", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        videoURL = URL(fileURLWithPath: path) as NSURL?
        
        startPlayback(videoURL: videoURL!)
    }
        
        
    func selectVideo(sender: UIBarButtonItem) {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayer" {
            
            let destVC = segue.destination as! VideoPlayerViewController
            destVC.videoUrl = videoURL!
            
        }

    }

    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
        print(videoURL ?? "no url")
        imagePickerController.dismiss(animated: true, completion: nil)
        startPlayback(videoURL: videoURL!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func startPlayback(videoURL: NSURL){
    
        self.performSegue(withIdentifier: "showPlayer", sender: self)
        
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }


}

