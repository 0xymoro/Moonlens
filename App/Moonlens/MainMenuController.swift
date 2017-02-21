import UIKit
import AVKit
import AVFoundation
import CoreMotion

class MainMenuController: UIViewController {
    let motionManager = CMMotionManager()
    var timer: Timer!
    var timer2: Timer!
    var yVal = CGFloat(0)
    var cursorXVal = CGFloat(0)
    var cursorYVal = CGFloat(0)
    var prevCursorY = [CGFloat]()
    var prevCount = 20
    var zeroY = CGFloat(0)
    let screenTotalHeight = CGFloat(1198)
    @IBOutlet weak var leftScreen: UIView!
    @IBOutlet weak var rightScreen: UIView!
    @IBOutlet weak var lCursor: UIImageView!
    @IBOutlet weak var rCursor: UIImageView!
    var lVideoDescs = [UIView!]()
    var rVideoDescs = [UIView!]()
    var titleArray:[String] = ["TreeHacks", "Gyrocam", "Biking Adventure", "Big Buck Bunny", "Stanford", "Rollercoaster"]
    var durationArray:[String] = ["1:10", "0:40", "4:30", "0:50", "1:40", "3:50"]
    var urlArray:[String] = ["http://45.79.86.157/uploads/2017_0219_084236_035.MP4",  "http://45.79.86.157/uploads/2017_0219_084442_036.MP4", "http://45.79.86.157/uploads/GoPro%20%20Stevey%20Storeys%20Winning%20Line%20-%202016%20GoPro%20of%20the%20World%20powered%20by%20Pinkbike.mp4", "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", "http://45.79.86.157/uploads/stanford.mp4", "http://45.79.86.157/uploads/White%20Cyclone%20Wooden%20Roller%20Coaster%20Front%20Seat%20POV%20Nagashima%20Spaland%20Japan%2060FPS.mp4"]
    var imageUrlArray:[String] = ["Treehacks", "Gyroscope", "Biking", "Bunny", "Stanford", "Rollercoaster"]
    var videoDescCount = 6
    var hoverIndex = -1
    var maxEndY: CGFloat!
    var startVideoDescs = CGFloat(254)
    override func viewDidLoad() {
        super.viewDidLoad()
        maxEndY = CGFloat(startVideoDescs+CGFloat(100*videoDescCount))
        leftScreen.frame = CGRect(x: 0, y: -yVal, width: CGFloat(335), height: maxEndY)
        rightScreen.frame = leftScreen.frame
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainMenuController.update), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainMenuController.updateCursor), userInfo: nil, repeats: true)
        for i in 0..<videoDescCount{
            for j in 0..<2{
                let videoDesc = UIView(frame: CGRect(x: 0, y: startVideoDescs+CGFloat(100*i), width: 335, height: 94))
                let videoImage = UIImageView(image: UIImage(named: imageUrlArray[i]))
                videoImage.frame = CGRect(x: 39, y: 5, width: 83, height: 83)
                videoImage.layer.cornerRadius = videoImage.frame.size.width/2
                videoImage.clipsToBounds = true
                videoImage.tag = 1
                videoDesc.addSubview(videoImage)
                let videoTitle = UILabel(frame: CGRect(x: 134, y: 17, width: 193, height: 28))
                
                videoTitle.font = UIFont(name: "Lato-Bold", size: 22)
                videoTitle.text = titleArray[i]
                videoTitle.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                videoTitle.shadowOffset = CGSize(width: 2, height: 2)
                videoTitle.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
                videoTitle.tag = 2
                videoDesc.addSubview(videoTitle)
                let videoDuration = UILabel(frame: CGRect(x: 134, y: 41, width: 128, height: 28))
                videoDuration.font = UIFont(name: "Lato-Regular", size: 20)
                videoDuration.text = durationArray[i]
                videoDuration.textColor = videoTitle.textColor
                videoDuration.shadowOffset = videoTitle.shadowOffset
                videoDuration.shadowColor = videoTitle.shadowColor
                videoDuration.tag = 3
                videoDesc.addSubview(videoDuration)
                if(j == 0){
                    lVideoDescs.append(videoDesc)
                    leftScreen.addSubview(videoDesc)
                }
                if(j == 1){
                    rVideoDescs.append(videoDesc)
                    rightScreen.addSubview(videoDesc)
                }
            }
        }
    }
    
    func updateCursor(){
        let defaultY = self.view.frame.height/2
        let defaultX = self.view.frame.width/4
        if(motionManager.accelerometerData != nil){
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
        if(motionManager.gyroData != nil){
            let gXV = motionManager.gyroData!.rotationRate.x
            if(abs(gXV) > 0.3){
                let prevCursorXVal = cursorXVal
                cursorXVal += CGFloat(1*CGFloat(gXV))
                if(defaultX-cursorXVal/2+16 < 0 || defaultX-cursorXVal/2+48 > self.view.frame.width/2){
                    cursorXVal = prevCursorXVal
                }
            }
            if(abs(gXV) > 0.6){
                let prevCursorXVal = cursorXVal
                cursorXVal = cursorXVal+CGFloat(2*CGFloat(gXV))
                if(defaultX-cursorXVal/2+16 < 0 || defaultX-cursorXVal/2+48 > self.view.frame.width/2){
                    cursorXVal = prevCursorXVal
                }
            }
        }
        if(motionManager.accelerometerData != nil){
            //print("CURSORXVALIS "+String(cursorXVal));
            //print
            //cursorYVal = CGFloat(CGFloat(motionManager.accelerometerData!.acceleration.z))*CGFloat(self.view.bounds.height)/4
            lCursor.frame = CGRect(x: defaultX-cursorXVal/2+16, y: defaultY-cursorYVal*2, width: CGFloat(32), height: CGFloat(32))
            rCursor.frame = lCursor.frame
        }
        hoverIndex = -1
        for i in 0..<videoDescCount{
            if(lVideoDescs[i].frame.contains(CGPoint(x: defaultX-cursorXVal/2+32, y: defaultY-cursorYVal*2+yVal+16))){
                hoverIndex = i
                let title = lVideoDescs[i].viewWithTag(2) as! UILabel
                title.textColor = UIColor(red: CGFloat(134)/CGFloat(255), green: CGFloat(185)/CGFloat(255), blue: CGFloat(255)/CGFloat(255), alpha: 1)
                let duration = lVideoDescs[i].viewWithTag(3) as! UILabel
                duration.textColor = title.textColor
                let title2 = rVideoDescs[i].viewWithTag(2) as! UILabel
                title2.textColor = title.textColor
                let duration2 = rVideoDescs[i].viewWithTag(3) as! UILabel
                duration2.textColor = title.textColor
            }
            else{
                let title = lVideoDescs[i].viewWithTag(2) as! UILabel
                title.textColor = UIColor(white: 1, alpha: 1)
                let duration = lVideoDescs[i].viewWithTag(3) as! UILabel
                duration.textColor = title.textColor
                let title2 = rVideoDescs[i].viewWithTag(2) as! UILabel
                title2.textColor = title.textColor
                let duration2 = rVideoDescs[i].viewWithTag(3) as! UILabel
                duration2.textColor = title.textColor
            }
        }
    }
    
    func update(){
        let defaultY = self.view.frame.height/2
        if(defaultY-cursorYVal*2 > self.view.frame.height*14/20){
            yVal+=2
        }
        if(defaultY-cursorYVal*2 < self.view.frame.height*6/20){
            yVal-=2
        }
        if(yVal < 0){
            yVal = 0
        }
        if(yVal > maxEndY-self.view.frame.height){
            yVal = maxEndY-self.view.frame.height
        }
        leftScreen.frame = CGRect(x: 0, y: -yVal, width: CGFloat(335), height: screenTotalHeight)
        rightScreen.frame = leftScreen.frame
    }
    
    @IBAction func screenTapped(_ sender: Any) {
        if(hoverIndex != -1){
            var newVideoController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "VideoController") as! VideoController
            newVideoController.videoUrl = NSURL(string: urlArray[hoverIndex])
            newVideoController.menuOldYVal = yVal
            if(urlArray[hoverIndex] == "http://45.79.86.157/uploads/2017_0219_084442_036.MP4"){
                newVideoController.isGyro = true
            }
            present(newVideoController, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
