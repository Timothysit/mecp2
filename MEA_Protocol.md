---
title: Microelectrode Array (MEA) Recording Protocol 
date: \today
toc: true
---

This protocol descrbe the procedures for taking electrode recordings using Microelectrode Array (MEA) from tissue cultures (TC). If you also wish to take photos of your tissue culure whilst recording, see the `Taking photos` section. 

# Computer set up

Do not remove cultures before computer set up, try to minimize the time cultures spend outside of the incubator. 

![Software for MEA recording](http://i.imgur.com/MEx8vj1.jpg?1)


Turning on computer and opening required software:

1. Log in to the computer. Username is `paul`, password is `Charlesworth123`
2. On the desktop, open program `2012...Rack` and `MEA Select` 
3. In `MEA Select`, click "change MEA" 

![MEA select software](http://i.imgur.com/LC5wx6J.jpg?2)


# Mounting

Before performing the following steps, make sure to spray ethanol on your gloves

4. Open the amplifier, making sure that: 

- pins are straight 
- there may be pins missing, this is okay 
- pull out the pins if they need to be straightened 
- if this fails, put new pins in

5. Clean pins with ethanol sponge (tissue wet with ethanol)
6. Clean new MEA contact with ethanol sponge
8. Check that the cable at the back is securely attached (ground fit perfectly)
9. Unclick "change MEA"

# Software set up

![Rack Program](http://i.imgur.com/4fHu8Hf.jpg){width=75%}

10. Go to `MEA Select`, under the "stimulation" panel, click ground. From here, select the broken pins (their numbers should dissapear from display). They are 15, 28, 74, 75, 85 
11. Click Download, it should read 'Download okay' in the dialog box 
12. Go to the `Rack` program, you should see a stack of windows. Including raw data and signals processed with a highpass filter
13. Click play (triangle button)
14. Go to the recorder tab, and click browse to select file or create file name to save data for this recording. The file name should include: 

- lab / experiment code 
- date 
- DIV (date since this tissue was first recorded)

Once the file name is created / a file is selected, click save 

![Spike sorter](http://i.imgur.com/PWT8G7A.jpg?1)


14. Still in the `Rack` program, go to spike sorter. Under the detection tab, under "automatic", click refresh 

If at this stage, one or more of the 'boxes' showing the MEA recordings is abnormal (eg. completely filled with blue), it is likely that there is significant noise in that electrode. Proceed to *troubleshooting*, otherwise, continue to *recording and saving*

# Troubleshooting noise on electode: 

- stop the recording (square button)
- click play again (triangle button)
- refresh the spike threshold (see step 14)

If there is still noise, go to `MEA select`, and 

- select electrodes (numbers) in which there are significant noise 
- you should see that the recorded trace on those electrodes should appear 'normal' now 
    + it is sometimes the case that one electrode is causing significant noise in neighbouring electrodes. Therefore, select noisy electrodes one by one and observe change in recording
- once all of the electrodes with significant noise are selected, and the overall recording is satisfactory, click download 
- continue to *recording and saving*

# Recording and saving: 

15. Go back to the Recorder tab and click the stop icon to stop recording 
16. Click on the recording button (red dot), then press play (triangle) to start recording and saving data to your file. The recording will stop automatically after 12 minutes (at the end of the recording, you will see the counter stop at 719 seconds), after which the data is saved.

# Switching cultures 

- click "change MEA" on the `MEA select` panel
- return the MEA to the culture dish and put on the cover 
- clean the outside of the culture dish with ethanol: spray ethanol onto tissue paper, then wipe the culture dish 
- return the culture dish to the incubator 

if another culture needs to be recorded, obtain the new culture from the incubator and proceed back to step 4. Remember to change the file name for each new recording. 



# Taking photos 

## Switching monitor input

![Switching monitor input](http://i.imgur.com/LJ8duhu.jpg)

- The monitor is connected to two computers. One containing the sofware for MEA recording and one containing the `Wasabi` software for taking photos. 
- To switch to another computer, locate the buttons on the monitor, then: 
    + press menu 
    + press select 
    + use the up/down arrow buttons on the monitor to navigate to the input section
    + press the left/right arrow buttons to switch to another computer

## Taking photos with `Wasabi`

![Live image display using `Wasabi`](http://i.imgur.com/EeiZeWP.jpg)

- In `Wasabi`, go to the 'Image' panel, under it click 'Live', or simply press `Ctrl + L`. Live recording from your tissue culture will appear 
- To take a photo, go to the 'Image' panel again and click 'Snap', or simply press `Ctrl + A`
- please note to close the `Wasabi` software before switching the camera off, otherwise, you may experiencec multiple error messages from your software





