#Visualization
##Installation
1. Install Meteor Framework using `curl install.meteor.com | sh` or go and compile it yourself `https://github.com/meteor/meteor`.
2. Download NodeJS if you have not already. Make sure it at least version 0.8.x
3. run `sudo npm -g install meteorite`.
4. Clone or Download a copy of the source code.
5. Change to the downloaded source code and execute `mrt`.
6. Visit `http://localhost:3000` to get the website running.

##Generating data files
There are two ways that data have to be generated. Note that the example after you have clone should work correctly.
###First is the standard data
This is where you convert your data set into the standard data set by using the language of your choice. Please take a look sample data at `public/sample-data.txt` and sample position at `public/sample-pos.txt`
###Second part is automatic
If you want to add more visualization graph, please look at the client folder and `router.js`. The convertor is at `server/convertor_tools.coffee`. Please write everything into `public` folder because the web application can we access by the URL from the root. eg. `http://localhost:3000/my-img.png` will be put in `public/my-img.png`

##Code documentation
You can find the documentation of the source code at `http://athiwatc.github.io/sh/readme.html`. Please click on the `Table of Content` at the top right to navigate between files.

##Notes
1. Even this application works looks like a normal web application but it works like a normal desktop application where not everything can be done in the browser and the browser is mostly used for displaying information only.
2. There is a mix of javascript and coffeescript as we prefer different language type. Which is not really a big problem in the end. You can use many free tools to convert between them easily.

##File Format

Data Information File
(Sample file: public/sample-data.txt)

- Format: 

Date Time Sensor_Name Status

or

Date Time Activity_Name Status

Example

2008-02-27    12:45:14.498824	M13	OFF

2008-02-27	12:49:15 asterisk END

Each data are separated line by line


=======================================

Position Information File
(Sample file: public/sample-pos.txt)

- Format: 

Position_name xpos ypos

Example

M01 23 102

J21 24 44

M_J 211 234

Each data are separated line by line