#Visualization
##Installation
1. Install Meteor Framework using `curl install.meteor.com | sh` or go and compile it yourself `https://github.com/meteor/meteor`.
2. Download NodeJS if you have not already.
3. run `sudo npm -g install meteorite`.
4. Clone or Download a copy of the source code.
5. Change to the downloaded source code and execute `mrt`.
6. Visit `http://localhost:3000` to get the website running.

##Generating data files
There are two ways that data have to be generated. Note that the example after you have clone should work correctly.
###First is the standard data
This is where you convert your data set into the standard data set by using the language of your choice. Please take a look at `public/sample-data.txt` and `public/all-pos.txt`
###Second part is automatic
If you want to add more visualization graph, please look at the client folder and `router.js` and `router.coffee`. The convertor is at `server/convertor_tools.coffee`. Please write everything into `public` folder because the web application can we access by the URL from the root. eg. `http://localhost:3000/my-img.png` will be put in `public/my-img.png`
##Notes
1. Even this application works looks like a normal web application but it works like a normal desktop application where not everything can be done in the browser and the browser is mostly used for displaying information only.
2. There is a mix of javascript and coffeescript as we prefer different language type. Which is not really a big problem into end.