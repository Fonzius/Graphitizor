# Graphitizor

Graphitizor is the final project for the Computer Music: Languages and Systems course held by Professor Fabio Antonacci at Politecnico di Milano developed by:
- Marco Bernasconi: marco7.bernasconi@mail.polimi.it
- Marco Cristofalo: marco.cristofalo@mail.polimi.it
- Francesco Barraco: francesco.barraco@mail.polimi.it

The project required the realization of an interactive musical instrument that could be controlled both via a physical interface and a GUI using a combination of 
[Arduino](https://www.arduino.cc/) or [Bela](https://bela.io/) boards to create the physical interface, [Supercollider](https://supercollider.github.io/) or other audio synthesis engines
and [Processing](https://processing.org/) for sound synthesis and for the digital interface.

The [Presentation Video](https://youtu.be/mCSJnVS-YNI) for Graphitizor was awarded full grades and is featured in the [Official Instagram page](https://www.instagram.com/p/Cu-NXHsIpJ6/)
for the Music and Acoustic Engineering course.

## Concept
In the first brainstorming session we came up with the idea of creating an instrument that would play music that reflects what the user writes on a sheet of paper. 
Following this idea in the following days we refined the idea keeping in mind the strict time and resoruces constraints in place which can be summarized in two main concepts:
- The instrument should use an interface that is created only using a pencil and paper
- The user should be free to design its own interface freely

We achieved this using three elements that work together to achieve the vision that we set.

## Arduino
The physical interface is implemented using an [Arduino UNO](https://store.arduino.cc/products/arduino-uno-rev3) board that reads tension across graphite traces left on the sheet of paper.
The user can draw its own interface to be as creative as they want, in the presentation video we show different interfaces that we drew to test the functionality of the project.
This interface allows control over the following parameters:
- Scale 
- Scale degrees that will be played (1-12)
- Tempo
- Volume for three synths and drums

The way in which these parameters are controlled is through the electrical resistance created by the graphite traces that are then interpreted by the arduino and sent via MIDI messages to
Supercollider.
This is implemented electronically using a simple pull-up circuit for each of the input which allows for greater stability in the measurements. Another factor is using a battery
power source for the arduino that significantly lowers the noise in the measurements in our testing experience.
Connecting the Arduino's ground and 5V to the drawing we can create thicker/shorter traces for a higher tension at the analogue input or a thinner/longer
trace for a lower tension reading. By dinamically changing the drawing we allow control on the music that is produced, this can be achieved by drawing, erasing or even using the hands
to create temporary paths through our skin to change the total resistance of the trace.

## Processing
The digital interface is implemented using Processing, an open source Java-based language that is primarily used for creative coding applications. 
To obtain a coherent style the interface uses the [Handy](https://www.gicentre.net/handy) library for Processing which allows to draw using a hand-drawn style.
This interface is separated into two views:
- A sequencer view that acts as a drum machine
- An assignment view to assign the sound for each range

The sequencer view controls the total length of the sequence that will be played so that it can be 1 to 8 notes long.
A corresponding number of white pads are available to "draw" the drums. Each pad represents a note of the sequence and can be drawn using the colors that are assigned to each individual drum hit.
For example a fully pink pad means that at that step the kick will be played at the maximum volume, the mix of colors will result in different realtive volumes for the drums at each step.
The assignment view has three empty pads for the high, medium and low instrument and six choices of pre-made synths that can be assinget to each pad freely determining the range in which they will play.
The interface communicates each change to the supercollider sound engine via OSC messages.

## Supercollider
Supercollider acts as the central piece of our project by receiving inputs from both Arduino and Processing in order to synthesize sound. 
It features six synths sounds:
- Saw Bass
- Violin
- Rhodes
- Pad
- Pluck
- Sine

The main objective of the Supercollider server is to interpret the information coming from the Arduino and the Processing GUI to produce a musical sequence that is played using PBinds.
