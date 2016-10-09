//
//  ViewController.swift
//  CafTrac
//
//  Created by Steve Lee on 10/9/16.
//  Copyright © 2016 Steve Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    //Global variable
    var amtOfCaffiene:Double = 0.0 //mg //Set it when the user inputs caffinee
    var halfLife = 0.0
    var avgHalfLife = 5.7
    var timeWhenUserFeltTired = 0.0 //seconds
    
    let coffeeView:UIView = UIView()
    let textfield = UITextField()
    let timeTextField = UILabel()
    let remainingCafLabel = UILabel()
    
    
    var timeSet:Bool = false
    var setStartingTime = 0.0//seconds
    
    //Graph
    let arcLayer = CAShapeLayer()
    
    //SYSTEM TIME
    var hour:Int = 0
    var minute:Int = 0
    var second:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createGraph()
        addCoffeeButton()
        recordAndStopTimerButton()
        createCafAmtLabel()
        
        createTimeLabel()
        
        let defaults = UserDefaults.standard
        
        if ((defaults.object(forKey: "halfLife")) != nil){
           
            //Load Halflife
            
            halfLife = defaults.object(forKey: "halfLife") as! Double
            let count = defaults.object(forKey: "count") as! Double
                
            avgHalfLife = halfLife / count
            
        }else {
            halfLife = 5.7 //Initial
            defaults.set(0, forKey: "sumOfDelta")
            defaults.set(1, forKey: "count")
        }
        
        //Don't start until the user inputs caffiene
        //put up a banner or something saying that to start caffiene has to be added for it to start 
        //or put up the caffiene view to start the program
        
        _ = Timer.scheduledTimer(timeInterval: 0.03, target: self, selector: #selector(animatingGraph(timer:)), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(systemTime(timer:)), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Create Circle Graph
    func createGraph(){
        var animationCenter:CGPoint = self.view.center
        animationCenter.y = animationCenter.y - 100
        let animationRadius:CGFloat = 130.0
        let animationLineWidth:CGFloat = 12.0
        let arcPath = UIBezierPath(arcCenter: animationCenter, radius: animationRadius, startAngle: CGFloat(2 * M_PI * 0.75), endAngle: CGFloat(2 * M_PI * 0.74999999999999), clockwise: true)
        
        //Maybe this should be able to be accessed by other functions to change the color of the arc over time
        arcLayer.path = arcPath.cgPath
        arcLayer.fillColor = UIColor.clear.cgColor
        arcLayer.strokeColor = UIColor.green.cgColor
        arcLayer.lineWidth = animationLineWidth
        
        //So the arc isn't drawn right away
        arcLayer.strokeEnd = 0.0
        
        self.view.layer.addSublayer(arcLayer)
    }
    
    func animatingGraph(timer: TimeInterval){
        
        //Figure out how to speed up and slow down the animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = 1
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        arcLayer.strokeEnd = 1
        
        // Do the actual animation
        arcLayer.add(animation, forKey: "animateCircle")
        
    }
    
    //SYSTEM TIME
    func systemTime(timer: TimeInterval){
        
        if (amtOfCaffiene > 0){//This cannot run before the caffeine screen is showed and the user inputs
            
            if (timeSet == false){
                //createGraph()
                //introLable.removefromparentview
            }
            
            let timeAvail = calculateTimeAvailable()
            
            let timeElaps = ((convertTimeToSeconds(hours: Double(self.hour), minutes: Double(self.minute), seconds: Double(self.second)) - setStartingTime))
            
             arcLayer.strokeEnd = CGFloat((timeAvail - timeElaps) / timeAvail)
            
            print(CGFloat(timeAvail-(convertTimeToSeconds(hours: Double(self.hour), minutes: Double(self.minute), seconds: Double(self.second)) - setStartingTime) / timeAvail))
            
            print(timeAvail)
            print(setStartingTime)
            print(convertTimeToSeconds(hours: Double(self.hour), minutes: Double(self.minute), seconds: Double(self.second)))
            
            //Updating label
            
            let secondsLeft:Int = Int(timeAvail - timeElaps)
            

            let hours = secondsLeft / 60 / 60
            let minutes = secondsLeft / 60 - hours * 60
            let seconds = secondsLeft % 60
            
            timeTextField.text = "Time left"+": "+"\(hours)" + ":" + "\(minutes)" + ":" + "\(seconds)"
            
            
            //Calculating remaining caf and setting the text 
            let cafRemainCurrent:Int = Int(((timeAvail - timeElaps) / timeAvail) * amtOfCaffiene)
            remainingCafLabel.text = "Caf remaining: " + "\(cafRemainCurrent)" + "mg"
 
            
        }
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date as Date)
        hour = components.hour!
        minute = components.minute!
        second = components.second!
        
        print("\(hour)" + "\n" + "\(minute)" + "\n" + "\(second)" + "\n")
        
    }

    
    //Add Coffee Button
    func addCoffeeButton(){
        
        let button:UIButton = UIButton()
        button.setImage(UIImage(named: "addCoffeeButton.png"), for: .normal)
        button.frame.size = CGSize(width: self.view.frame.size.width * 0.16 , height: self.view.frame.size.width * 0.16)
        button.layer.position = CGPoint(x: self.view.frame.size.width * 0.9, y: self.view.frame.size.height * 0.08)
        button.addTarget(self, action: #selector(ViewController.showAddCoffeeView), for: .touchUpInside)
        self.view.addSubview(button)
        
    }
    //When the coffee button is pressed
    //Keep the program going
    //But add concentration of coffee
    
    //Dismissing keyboard
    func dismissKeyboard(gestureRecognizer: UITapGestureRecognizer){
        textfield.resignFirstResponder()
        
    }
    func showAddCoffeeView(){
        
        //Once the coffeeview is dismissed, then the counter starts
        coffeeView.backgroundColor = UIColor.white
        coffeeView.frame.size = self.view.frame.size
        
        let onScreentap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(gestureRecognizer:)))
        view.addGestureRecognizer(onScreentap)
        
        self.view.addSubview(coffeeView)
        
        let enterCafButton:UIButton = UIButton()
        enterCafButton.setImage(UIImage(named: "addCoffeeButton.png"), for: .normal)
        enterCafButton.frame.size = CGSize(width: self.view.frame.size.width * 0.16 , height: self.view.frame.size.width * 0.16)
        enterCafButton.layer.position = CGPoint(x: self.view.center.x, y: self.view.frame.size.height * 0.8)
        enterCafButton.addTarget(self, action: #selector(ViewController.settingTheTime), for: .touchUpInside)
        coffeeView.addSubview(enterCafButton)
        
        //Textfield view
        textfield.frame.size = CGSize(width: self.view.frame.size.width * 0.8, height: self.view.frame.size.height * 0.1)
        textfield.layer.position = self.view.center
        textfield.text = "Enter caffiene in mg"
        textfield.textAlignment = .center
        
        coffeeView.addSubview(textfield)
        
    
    }
    //Coffee view has a button that is Add
    //Then this function runs setting the time 
    func settingTheTime(){
        //Where the time is set permanantly
        if (timeSet == false){
            timeSet = true
            setStartingTime = convertTimeToSeconds(hours: Double(self.hour), minutes: Double(self.minute), seconds: Double(self.second))
        }
        
        amtOfCaffiene += Double(textfield.text!)!
        coffeeView.removeFromSuperview()
        
    }
    
    //Add button for hte user 
    func recordAndStopTimerButton(){
        
        let button_:UIButton = UIButton()
        button_.setImage(UIImage(named: "tiredButton.png"), for: .normal)
        button_.frame.size = CGSize(width: self.view.frame.size.width * 0.8 , height: self.view.frame.size.width * 0.55)
        button_.layer.position = CGPoint(x: self.view.center.x, y: self.view.frame.size.height * 0.8)
        button_.addTarget(self, action: #selector(ViewController.recordAndStop), for: .touchUpInside)
        self.view.addSubview(button_)
        
    }
    //When the recordAndStopTimerButton is pressed
    //Do calculate and Save and end the program
    //And say something like thanks for using!
    
    //Session/studying finished function
    //This function calculates new halflife for the next time 
    //using the delta t that was given by the user's determination of tiredness
    //initial is the amount of caffeine
    func recordAndStop(){
        
        //Present Thank you screen and run the save function
        
        calculateAndSave()
        
        let ac = UIAlertController(title: "Thanks for using this App", message: "Now get some sleep!", preferredStyle: .alert)
        present(ac, animated:  true)
        
    }
    
    func calculateAndSave(){
        
        let defaults = UserDefaults.standard
        var sumOfDeltaT = 0.0
        var count = 1
        let newDeltaT = (amtOfCaffiene / timeWhenUserFeltTired) //mg/sec
        
        //Load sum of all delta t
        if (defaults.object(forKey: "sumOfDelta") != nil){
            sumOfDeltaT = defaults.object(forKey: "sumOfDelta") as! Double
            sumOfDeltaT += (amtOfCaffiene / timeWhenUserFeltTired) //mg/sec
        }else {
            sumOfDeltaT += (amtOfCaffiene / timeWhenUserFeltTired) //mg/sec
        }
        
        //Load count
        if (defaults.object(forKey: "count") != nil){
            count = defaults.object(forKey: "count") as! Int
            count += 1
        }else {
            count += 1
        }
    
        
        //Save how much coffee was consumed during the session or I think it's part of the delta t
        
        //Save halflife that's calculated with syd's equaiton
        let a = 100.0/amtOfCaffiene
        let b = 1.0/2.0
        halfLife = newDeltaT / ((log(a) / log(b)))//Syd's Theorem of Caffeine //Halflife based on this session
        
        //Save sum of half lives
        
        
        defaults.set(halfLife, forKey: "halfLife")
        
        //Save count
        defaults.set(count, forKey: "count")
        
    }
    
    //Gives the time the person can live basically
    //After caffiene added run it
    func calculateTimeAvailable() -> Double{
        
        return -log(100.0/amtOfCaffiene)/log(2.0) * avgHalfLife * 60 * 60
        
    }
    
    
    func convertTimeToSeconds(hours:Double, minutes:Double, seconds:Double) -> Double{
        
        return (hours * 60 * 60) + (minutes * 60) + (seconds)
    }
    

    func createTimeLabel(){
        
        timeTextField.text = "Input Caffeine"
        
        timeTextField.frame.size = CGSize(width: self.view.frame.size.width * 0.7, height: self.view.frame.size.height * 0.1)
        timeTextField.layer.position = self.view.center
        timeTextField.layer.position.y = timeTextField.layer.position.y - 120
        timeTextField.textAlignment = .center
        
        self.view.addSubview(timeTextField)
    }
    
    func createCafAmtLabel(){
        
        remainingCafLabel.text = "to Start"
        
        remainingCafLabel.frame.size = CGSize(width: self.view.frame.size.width * 0.7, height: self.view.frame.size.height * 0.1)
        remainingCafLabel.layer.position = self.view.center
        remainingCafLabel.layer.position.y = remainingCafLabel.layer.position.y - 95
        remainingCafLabel.textAlignment = .center
        
        self.view.addSubview(remainingCafLabel)
    }
    
   

}

