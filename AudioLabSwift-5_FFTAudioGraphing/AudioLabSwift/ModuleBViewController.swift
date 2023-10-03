//
//  ModuleBViewController.swift
//  AudioLabSwift
//
//  Created by Michael Deweese on 10/2/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ModuleBViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    //Variables for func calculateChangeInFrequency() //calculates doppler effect
        private var velocityOfObject = ""
        private var speedOfSound = ""
        private var frequencyOfSource = ""
        private var changeInFrequency = 0.0
    
    //function equation for calculating doppler effect
    //doppler equation finds f0 or the height of tallest wave. doppler shift needs to be set 5 or ten units from this
        func calculateChangeInFrequency() {
                if let velocity = Double(velocityOfObject),
                   let speed = Double(speedOfSound),
                   let sourceFrequency = Double(frequencyOfSource) {
                    
                    changeInFrequency = (velocity / speed) * sourceFrequency
                }
            ////                                     Examples of implementation for calculateChangeInFrequency()
            //    Text("Change in Frequency Calculator")
            //                    .font(.largeTitle)
            //
            //                TextField("Velocity of Object (m/s)", text: $velocityOfObject)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .padding()
            //
            //                TextField("Speed of Sound (m/s)", text: $speedOfSound)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .padding()
            //
            //                TextField("Frequency of Source (Hz)", text: $frequencyOfSource)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .padding()
            //
            //                Button(action: calculateChangeInFrequency) {
            //                    Text("Calculate")
            //                        .padding()
            //                }
            //
            //                Text("Change in Frequency: \(changeInFrequency) Hz")
            //                    .font(.title)
            //                    .padding()
            }
            }
//Variables for calculate doppler shift
private var observedFrequency = ""
private var sourceFrequency = ""
private var velocityOfObserver = ""
private var velocityOfSource = ""
private var dopplerShift = 0.0

//function for doppler shift
//doppler shift = k0 or the length of the sound wave. Set to 5 or 10
func calculateDopplerShift() {
    if let observedFreq = Double(observedFrequency),
       let sourceFreq = Double(sourceFrequency),
       let observerVelocity = Double(velocityOfObserver),
       let sourceVelocity = Double(velocityOfSource) {
        
        let numerator = observerVelocity + sourceVelocity
        let denominator = observerVelocity - sourceVelocity
        
        if denominator != 0 {
            //equation for doppler shift
            dopplerShift = sourceFreq * (numerator / denominator)
        } else {
            dopplerShift = Double.nan // Avoid division by zero
        }
        
    //implementation example for printing out doppler shift
//                            Text("Doppler Shift Calculator")
//                                .font(.largeTitle)
//
//                            TextField("Observed Frequency (Hz)", text: $observedFrequency)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding()
//
//                            TextField("Source Frequency (Hz)", text: $sourceFrequency)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding()
//
//                            TextField("Velocity of Observer (m/s)", text: $velocityOfObserver)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding()
//
//                            TextField("Velocity of Source (m/s)", text: $velocityOfSource)
//                                .textFieldStyle(RoundedBorderTextFieldStyle())
//                                .padding()
//
//                            Button(action: calculateDopplerShift) {
//                                Text("Calculate")
//                                    .padding()
//                            }
//
//                            Text("Doppler Shift: \(dopplerShift) Hz")
//                                .font(.title)
//                                .padding()
    }
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
