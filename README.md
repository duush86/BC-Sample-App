# BC-Sample-App
Antonio Orozco experiment to create BC Sample App 

The purpose of this project is to gather as many Brightcove Sample Apps as possible under one project to rule them all...and to make life easier for demos and stuff. 

To setup this project locally: 

*If already installed, move straight to step 2*

1. install cocoapods

```sudo gem install cocoapods```

2. Move to this project's directory and create the pod file 

```init pod```

3. Add the following content to the pod file 
```
Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'
source 'https://github.com/brightcove/BrightcoveSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'


target 'BC Sample App' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BC Sample App

	pod 'Brightcove-Player-IMA'
	pod 'GoogleAds-IMA-iOS-SDK'

end
```
4. install pods

```pod install```

5. If ```pod install``` returns a successful message, open the *BC Sample App.xcworkspace* project 

6. Open *controller/ViewController.swift* in there, you'll find a function called *setValuesForDemos*. This function sets an array
of *Demo* objects. Add your Demo objects as requiered with the following structure: 
```Demo(withName: "Simple Demo", withContent_id: "6054855884001", withActivity: "VideoViewController"```

Where:

* withName will be the name for this particular object
* withContent_id video content id that you want to play 
* withActivity class that will be used to play the video. At this point, just 2 classes are supported: 

1. VideoViewController - Basic Brightcove Player example
2. AdvertisingViewController - Google IMA + Brightcove Implementation
