//
//  VideoPlayerViewController.swift
//  Simple Loop Player
//
//  Created by Peter Zeman on 24.2.17.
//  Copyright © 2017 Procus s.r.o. All rights reserved.
//

import AVFoundation
import UIKit


class VideoPlayerViewController: UIViewController {
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    let invisibleButton = UIButton()
    var videoUrl: NSURL!
    var timeObserver: AnyObject!
    let timeRemainingLabel = UILabel()
    let timePlayedLabel = UILabel()
    let seekSlider = UISlider()
    let pauseButton = UIButton()
    let closeButton = UIButton()
    let nextLoopButton = UIButton()
    var playerRateBeforeSeek: Float = 0
    var componentsHidden = false
    var startOver = false
    var loops = [Loop]()
    var mainLoop: Loop!
    var loopIndex: Int!
    var loopingOn = false
    var loopBar = UIView()
    var loopButtons = [UIButton]()
    
    
    override func viewDidAppear(_ animated: Bool) {
        loopingOn = true
        skipToLoop(id: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped), for: .touchUpInside)
        
        if let url = videoUrl{
            let playerItem = AVPlayerItem(url: url as URL)
            avPlayer.replaceCurrentItem(with: playerItem)
            let timeInterval: CMTime = CMTimeMake(1, 100)
            timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                                       queue: DispatchQueue.main) { (elapsedTime: CMTime) -> Void in
                                                                        self.observeTime(elapsedTime: elapsedTime)
                                                                        
            } as AnyObject!
            timeRemainingLabel.textColor = .white
            view.addSubview(timeRemainingLabel)
            timePlayedLabel.textColor = .white
            view.addSubview(timePlayedLabel)
            
            
            
            loopBar.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
            view.addSubview(loopBar)
            
            view.addSubview(seekSlider)
            seekSlider.addTarget(self, action: #selector(sliderBeganTracking),
                                 for: .touchDown)
            seekSlider.addTarget(self, action: #selector(sliderEndedTracking),
                                 for: [.touchUpInside, .touchUpOutside])
            seekSlider.addTarget(self, action: #selector(sliderValueChanged),
                                 for: .valueChanged)
            
            if let image = UIImage(named: "pause") {
                pauseButton.setImage(image, for: .normal)
            }
            pauseButton.addTarget(self, action: #selector(playPause), for: .touchUpInside)
            view.addSubview(pauseButton)
            
            if let image = UIImage(named: "close") {
                closeButton.setImage(image, for: .normal)
            }
            closeButton.addTarget(self, action: #selector(endViewController), for: .touchUpInside)
            view.addSubview(closeButton)
            
            nextLoopButton.setTitle(NSLocalizedString("VideoPlayerViewController.nextLoop", comment: "next loop"), for: .normal)
            nextLoopButton.tintColor = UIColor.white
            nextLoopButton.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 0.5)
            nextLoopButton.addTarget(self, action: #selector(nextLoop), for: .touchUpInside)
            nextLoopButton.alpha = 1
            view.addSubview(nextLoopButton)
            
            
        }
        
        setLoops()
        
        
        
    }
    

    
    func addLoopButton(){
        var i = 0
        let theWidth = view.bounds.size.width
        for loop in loops{
            let startX = Double(theWidth * CGFloat(loop.start))
            let width = Double((theWidth * CGFloat(loop.end)) - (theWidth * CGFloat(loop.start)))
            let button = UIButton(frame: CGRect(x: startX, y: Double(nextLoopButton.frame.maxY), width: width, height: Double(seekSlider.frame.maxY - nextLoopButton.frame.maxY)))
            button.backgroundColor = UIColor(red: 200/255, green: 20/255, blue: 20/255, alpha: 0.5)
           
            button.tag = i
            loopButtons.append(button)
            button.alpha = 0
            view.insertSubview(button, at: 7)
            UIView.animate(withDuration: 0.5, animations: {
                button.alpha = 1
            })
            i += 1
        }
    }
    
    
    func skipToLoop(id: Int){
        if !loops.isEmpty{
            mainLoop = loops[id]
            loopIndex = id
            loopingOn = true
            seekToPercent(percent: mainLoop.start)
        }
    }
    
    func removeLoopButtons(){
        for button in loopButtons{
            UIView.animate(withDuration: 0.5, animations: {
                button.alpha = 0
            })
            button.removeFromSuperview()
        }
        loopButtons = []
    }
    
    func setLoops(){
        let loop1 = Loop(start: 0.12, end: 0.2)
        let loop2 = Loop(start: 0.3, end: 0.4)
        let loop3 = Loop(start: 0.5, end: 0.52)
        let loop4 = Loop(start: 0.6, end: 0.9)
        loops = [loop1, loop2, loop3, loop4]
        loopIndex = 0
        mainLoop = loops[loopIndex]
    }
    
    deinit {
        avPlayer.removeTimeObserver(timeObserver)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play()
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
        invisibleButton.frame = view.bounds
        
        let theWidth = view.bounds.size.width
        let theHeight = view.bounds.size.height
        
        let controlsHeight: CGFloat = 30
        let controlsWidth: CGFloat = 60
        let controlsX: CGFloat = view.bounds.size.width - controlsWidth - 5
        let controlsY: CGFloat = view.bounds.size.height - controlsHeight
        timePlayedLabel.frame = CGRect(x: 5, y: controlsY, width: controlsWidth, height: controlsHeight)
        timeRemainingLabel.frame = CGRect(x: controlsX, y: controlsY, width: controlsWidth, height: controlsHeight)
        
        let sliderWidth = view.bounds.size.width
        
        seekSlider.frame = CGRect(x: 0, y: controlsY - 30, width: sliderWidth, height: controlsHeight)
        
        
        pauseButton.frame = CGRect(x: view.bounds.size.width / 2 - 40, y: view.bounds.size.height / 2 - 40, width: 80, height: 80)
        
        closeButton.frame = CGRect(x: 10, y:  10, width: 30, height: 30)
        
        nextLoopButton.frame = CGRect(x: theWidth - theWidth/5, y:  0, width: theWidth - (theWidth - theWidth/5), height: seekSlider.frame.minY - 15)
        
        
        loopBar.frame = CGRect(x: 0, y:  nextLoopButton.frame.maxY, width: theWidth, height: seekSlider.frame.maxY - nextLoopButton.frame.maxY)
        
        
        addLoopButton()
        
        
        
    }
    
    func nextLoop(){
        if loopIndex < loops.count - 1{
            loopIndex = loopIndex + 1
            mainLoop = loops[loopIndex]
            seekToPercent(percent: mainLoop.start)
        }else{
            loopIndex = 0
            mainLoop = loops[loopIndex]
            seekToPercent(percent: mainLoop.start)
        }
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        showHideComponents()
    }
    
    func showHideComponents(){
        UIView.animate(withDuration: 0.5, animations: {
            if self.componentsHidden{
                self.pauseButton.alpha = 1
                self.closeButton.alpha = 1
                self.timeRemainingLabel.alpha = 1
                self.timePlayedLabel.alpha = 1
            
                self.loopBar.alpha = 1
            
                self.nextLoopButton.alpha = 1
     
                for button in self.loopButtons{
                    UIView.animate(withDuration: 0.5, animations: {
                        button.alpha = 1
                    })
                }
            
                self.seekSlider.alpha = 1
                
            }else{
                self.seekSlider.alpha = 0
                self.pauseButton.alpha = 0
                self.closeButton.alpha = 0
                self.timeRemainingLabel.alpha = 0
                self.timePlayedLabel.alpha = 0
         
                self.nextLoopButton.alpha = 0
                self.loopBar.alpha = 0
                for button in self.loopButtons{
                    UIView.animate(withDuration: 0.5, animations: {
                        button.alpha = 0
                    })
                }
    
            }
        })
        componentsHidden = !componentsHidden
    }
    
    func playPause(sender: UIButton) {
        if startOver {
            avPlayer.seek(to: CMTimeMakeWithSeconds(0, 100)) { (completed: Bool) -> Void in
                
                if let image = UIImage(named: "pause") {
                    self.pauseButton.setImage(image, for: .normal)
                }
                self.showHideComponents()
                
                self.avPlayer.play()
                self.startOver = false
                
            }
        }else{
            let playerIsPlaying = avPlayer.rate > 0
            if playerIsPlaying {
                if let image = UIImage(named: "play") {
                    pauseButton.setImage(image, for: .normal)
                }
                avPlayer.pause()
            } else {
                if let image = UIImage(named: "pause") {
                    pauseButton.setImage(image, for: .normal)
                }
                showHideComponents()
                avPlayer.play()
            }
        }
    }
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        let timePlayed: Float64 = elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        timePlayedLabel.text = String(format: "%02d:%02d", ((lround(timePlayed) / 60) % 60), lround(timePlayed) % 60)
    }
    
    private func updateSlider(elapsedTime: Float64, duration: Float64){
        seekSlider.value = Float(elapsedTime/duration)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            if elapsedTime == duration{
                if let image = UIImage(named: "play") {
                    pauseButton.setImage(image, for: .normal)
                    startOver = true
                    if componentsHidden {
                        showHideComponents()
                    }
                }
            }
            if !loopingOn{
                updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
                updateSlider(elapsedTime: elapsedTime, duration: duration)
            }else{
                let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
                let endTime: Float64 = videoDuration * Float64(mainLoop.end)
                if elapsedTime >= endTime{
                    seekToPercent(percent: mainLoop.start)
                    updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
                    updateSlider(elapsedTime: elapsedTime, duration: duration)
                 
                }else{
                    updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
                    updateSlider(elapsedTime: elapsedTime, duration: duration)
             
                }
                
            }
            
        }
    }
    
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        let inLoop = isInLoop(value: Float64(slider.value))
        
        switch (inLoop) {
        case -1:
            avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
                if self.playerRateBeforeSeek > 0 {
                    self.avPlayer.play()
                }
            }
        default:
            skipToLoop(id: inLoop)
            
        }
        
        
    }
    
    func seekToPercent(percent: Float64){
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(percent)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
    func endViewController(){
        avPlayer.pause()
        avPlayerLayer.removeFromSuperlayer()
        dismiss(animated: true, completion: nil)
    }
    
    func isInLoop(value: Float64) -> Int{
        var i = 0
        for loop in loops{
            if loop != mainLoop{
                if loop.start < value && loop.end > value{
                    return i
                }
            }
            i += 1
        }
        if mainLoop.start > value{
            return loopIndex
        }
        
        return -1
    }


}
