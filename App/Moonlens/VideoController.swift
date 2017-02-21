import UIKit
import AVKit
import AVFoundation
import CoreMotion

class VideoController: UIViewController {
    let motionManager = CMMotionManager()
    var timer: Timer!
    var timer2: Timer!
    var timer3: Timer!
    var leftVideoLayer:AVPlayerLayer!
    var rightVideoLayer:AVPlayerLayer!
    var player:AVPlayer!
    @IBOutlet var menuTap: UITapGestureRecognizer!
    @IBOutlet weak var lView: UIView!
    @IBOutlet weak var rView: UIView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var lMenuView: UIView!
    @IBOutlet weak var rMenuView: UIView!
    var xVal = CGFloat(0)
    var yVal = CGFloat(0)
    var cursorXVal = CGFloat(0)
    var cursorYVal = CGFloat(0)
    var zeroY = CGFloat(0)
    var videoScale = 1.3
    var isPlaying = false
    var isPaused = false
    var menuOn = false
    var prevCursorX = [CGFloat]()
    var prevCursorY = [CGFloat]()
    var prevCount = 10
    var menuMode = 0
    var menuOldYVal = CGFloat(0)
    @IBOutlet weak var lCursor: UIImageView!
    @IBOutlet weak var rCursor: UIImageView!
    @IBOutlet weak var lBack: UIImageView!
    @IBOutlet weak var lPause: UIImageView!
    @IBOutlet weak var lRecenter: UIImageView!
    @IBOutlet weak var rBack: UIImageView!
    @IBOutlet weak var rPause: UIImageView!
    @IBOutlet weak var rRecenter: UIImageView!
    @IBOutlet weak var lReplay: UIImageView!
    @IBOutlet weak var rReplay: UIImageView!
    var videoUrl:NSURL!
    var frequency = CGFloat(0) //MAYBE COMMENT
    var myStrings = [String]() //MAYBE COMMENT
    var parseCount = 0
    var gyroX = CGFloat(0)
    var gyroY = CGFloat(0)
    var mainMenuController: MainMenuController!
    var isGyro = false;
    var switched = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMenuController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainMenuController") as! MainMenuController
        lView.clipsToBounds = true
        rView.clipsToBounds = true
        lMenuView.clipsToBounds = true
        rMenuView.clipsToBounds = true
        xVal = CGFloat(0)
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        frequency = CGFloat(15) //MAYBE COMMENT
        timer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(VideoController.update), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(VideoController.updateCursor), userInfo: nil, repeats: true)
//        if(isGyro){
//            if let path = Bundle.main.path(forResource: "gyroscopedata", ofType: "txt") {
//                do {
//                    let data = try String(contentsOfFile: path, encoding: .utf8)
//                    myStrings = data.components(separatedBy: .newlines)
//                    
//                } catch {
//                    print(error)
//                }
//            }
//            timer3 = Timer.scheduledTimer(timeInterval: Double(1)/Double(frequency), target: self, selector: #selector(VideoController.updateGyro), userInfo: nil, repeats: true) //MAYBE COMMENT
//        }
        startVideos()
    }
    
    func update() {
        let videoHeight = self.view.bounds.height*CGFloat(videoScale)
        if(leftVideoLayer != nil && !menuOn){
            leftVideoLayer.frame = CGRect(x: xVal-self.view.bounds.width/4*CGFloat(videoScale)-gyroX, y: -(videoHeight-self.view.bounds.height)/2+yVal-gyroY, width: self.view.bounds.width*CGFloat(videoScale), height: self.view.bounds.height*CGFloat(videoScale))
        }
        if(rightVideoLayer != nil && !menuOn){
            rightVideoLayer.frame = leftVideoLayer.frame
        }
        if(motionManager.accelerometerData != nil){
            if(!menuOn){
                yVal = CGFloat(CGFloat(motionManager.accelerometerData!.acceleration.z)-zeroY)*CGFloat(self.view.bounds.height)/2
            }
        }
        if(motionManager.gyroData != nil){
            let gXV = motionManager.gyroData!.rotationRate.x
            if(isPlaying && !menuOn){
                if(abs(gXV) > 0.2){
                    xVal+=CGFloat(10*CGFloat(gXV))
                }
                if(abs(gXV) > 0.5){
                    xVal+=CGFloat(20*CGFloat(gXV))
                }
            }
        }
    }
    
    func updateCursor(){
        if(menuOn){
            let defaultX = CGFloat(150)
            let defaultY = CGFloat(171)
            if(menuOn && motionManager.accelerometerData != nil){
                var newY = CGFloat(CGFloat(motionManager.accelerometerData!.acceleration.z)-zeroY)*CGFloat(self.view.bounds.height)/4
                if(defaultY-newY*2 > 0 && defaultY-newY*2 < self.view.frame.height-32){
                    prevCursorY.append(CGFloat(CGFloat(motionManager.accelerometerData!.acceleration.z)-zeroY)*CGFloat(self.view.bounds.height)/4)
                }
                if(prevCursorY.count > prevCount){
                    prevCursorY.remove(at: 0)
                }
                var ySum = CGFloat(0)
                for i in 0..<prevCursorY.count{
                    ySum+=prevCursorY[i]
                }
                var prevCursorYVal = cursorYVal
                if(prevCursorY.count != 0){
                    cursorYVal = ySum/CGFloat(prevCursorY.count)*CGFloat(1.35)
                }
                if(defaultY-cursorYVal*2 < 0 || defaultY-cursorYVal*2 > self.view.frame.height-32){
                    cursorYVal = prevCursorYVal
                }
            }
            if(menuOn && motionManager.gyroData != nil){
                let gXV = motionManager.gyroData!.rotationRate.x
                if(abs(gXV) > 0.3){
                    let prevCursorXVal = cursorXVal
                    cursorXVal += CGFloat(1*CGFloat(gXV))
                    if(defaultX-cursorXVal/2 < 0 || defaultX-cursorXVal/2+32 > self.view.frame.width/2){
                        cursorXVal = prevCursorXVal
                    }
                }
                if(abs(gXV) > 0.6){
                    let prevCursorXVal = cursorXVal
                    cursorXVal = cursorXVal+CGFloat(2*CGFloat(gXV))
                    if(defaultX-cursorXVal/2 < 0 || defaultX-cursorXVal/2+32 > self.view.frame.width/2){
                        cursorXVal = prevCursorXVal
                    }
                }
            }
            moveCursor()
            var cursorPoint = CGPoint(x: defaultX-cursorXVal/2+16, y: defaultY-cursorYVal*2+16)
            if(lBack.frame.contains(cursorPoint)){
                menuMode = 1
                lBack.image = #imageLiteral(resourceName: "BackButtonBlue")
            }
            else if(lPause.frame.contains(cursorPoint)){
                menuMode = 2
                lPause.image = #imageLiteral(resourceName: "PauseButtonBlue")
                if(isPaused){
                    lPause.image = #imageLiteral(resourceName: "PlayButtonBlue")
                }
            }
            else if(lRecenter.frame.contains(cursorPoint)){
                menuMode = 3
                lRecenter.image = #imageLiteral(resourceName: "RecenterButtonBlue")
            }
            else if(lReplay.frame.contains(cursorPoint)){
                menuMode = 4
                lReplay.image = #imageLiteral(resourceName: "ReplayButtonBlue")
            }
            else{
                menuMode = 0
            }
            if(menuMode != 1){
                lBack.image = #imageLiteral(resourceName: "BackButton")
            }
            if(menuMode != 2){
                lPause.image = #imageLiteral(resourceName: "PauseButton")
                if(isPaused){
                    lPause.image = #imageLiteral(resourceName: "PlayButton")
                }
            }
            if(menuMode != 3){
                lRecenter.image = #imageLiteral(resourceName: "RecenterButton")
            }
            if(menuMode != 4){
                lReplay.image = #imageLiteral(resourceName: "ReplayButtonWhite")
            }
            rBack.image = lBack.image
            rPause.image = lPause.image
            rRecenter.image = lRecenter.image
            rReplay.image = lReplay.image
        }
    }
    
    func updateGyro(){
        if(parseCount+4 < myStrings.count){
            var y = Int(myStrings[parseCount])
            parseCount+=1
            var trash = Int(myStrings[parseCount])
            parseCount+=1
            var x = Int(myStrings[parseCount])
            parseCount+=1
            var trash2 = Int(myStrings[parseCount])
            parseCount+=1
            gyroX = CGFloat(-7000-x!)/CGFloat(2000)*30
            gyroY = CGFloat(y!)/CGFloat(4000)*50
            print("GY: "+String(describing: gyroY)+" GX: "+String(describing: gyroX))
        }
    }
    
    func moveCursor(){
        print("ABOUT TO MOVE CURSOR")
        let defaultX = CGFloat(150)
        let defaultY = CGFloat(171)
        lCursor.frame = CGRect(x: defaultX-cursorXVal/2, y: defaultY-cursorYVal*2, width: CGFloat(32), height: CGFloat(32))
        rCursor.frame = CGRect(x: defaultX-cursorXVal/2, y: defaultY-cursorYVal*2, width: CGFloat(32), height: CGFloat(32))
        print("MOVED CURSOR")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startVideos(){
        isPlaying = true
        //let videoURL = NSURL(string: "aws-website-virtualmoccasinscom-4wh36.s3-website-us-east-1.amazonaws.com/uploads/HotelCalifornia.mp4")
        //let videoURL = NSURL(string: "http://45.79.86.157/uploads/2017_0218_035511_003.MP4")
        //let videoURL = NSURL(string: "http://virtualmoccasins.azurewebsites.net/uploads/HotelCalifornia.mp4")
        //let videoURL = NSURL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        //let videoURL = NSURL(string: "http://45.79.86.157/uploads/HotelCalifornia.mp4")
        player = AVPlayer(url: videoUrl! as URL)
        leftVideoLayer = AVPlayerLayer(player: player)
        leftVideoLayer.frame = CGRect(x: xVal, y: yVal, width: self.view.bounds.width*2, height: self.view.bounds.height*2)
        lView.layer.addSublayer(leftVideoLayer)
        rightVideoLayer = AVPlayerLayer(player: player)
        rightVideoLayer.frame = CGRect(x: xVal, y: yVal, width: self.view.bounds.width*2, height: self.view.bounds.height*2)
        rView.layer.addSublayer(rightVideoLayer)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil){_ in
            if(!self.switched){
                let t1 = CMTimeMake(5, 100);
                self.player.seek(to: t1)
                self.player.play()
            }
        }
        player.play()
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        if(menuMode == 0){
            toggleMenu()
        }
        if(menuMode == 1){
            switched = true
            player.pause()
            leftVideoLayer.removeFromSuperlayer()
            rightVideoLayer.removeFromSuperlayer()
            var mainMenuController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "MainMenuController") as! MainMenuController
            mainMenuController.yVal = menuOldYVal
            present(mainMenuController, animated: false, completion: nil)
        }
        if(menuMode == 2){
            togglePause()
        }
        if(menuMode == 3){
            recenter()
        }
        if(menuMode == 4){
            replay()
        }
        
    }
    
    func replay(){
        let t1 = CMTimeMake(5, 100);
        self.player.seek(to: t1)
    }
    
    func toggleMenu(){
        print("POOP")
        if(menuOn){
            menuMode = 0
            menuOn = false
            menuView.alpha = 0
        }
        else{
            cursorXVal = CGFloat(0)
            menuOn = true
            menuView.alpha = 1
        }
        
    }
    
    func togglePause(){
        if(player.rate != 0){
            isPaused = true
            player.rate = 0
        }
        else{
            isPaused = false
            player.rate = 1
        }
    }
    
    func recenter(){
        let videoHeight = self.view.bounds.height*CGFloat(videoScale)
        xVal = CGFloat(0)
        leftVideoLayer.frame = CGRect(x: xVal-self.view.bounds.width/4*CGFloat(videoScale), y: -(videoHeight-self.view.bounds.height)/2+yVal, width: self.view.bounds.width*CGFloat(videoScale), height: self.view.bounds.height*CGFloat(videoScale))
        rightVideoLayer.frame = CGRect(x: xVal-self.view.bounds.width/4*CGFloat(videoScale), y: -(videoHeight-self.view.bounds.height)/2+yVal, width: self.view.bounds.width*CGFloat(videoScale), height: self.view.bounds.height*CGFloat(videoScale))
        //zeroY = CGFloat(motionManager.accelerometerData!.acceleration.z)
        //yVal = CGFloat(0)
    }

}

