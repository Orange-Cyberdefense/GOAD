# Frequent asked questions


!!! question "How can i change the default keyboard layout ?"
    edit globalsettings.ini files and change the variable `keyboard_layouts`

!!! question "How can i change the folder where vagrant download the boxes ?"
    vagrant download the boxes by default on ~/.vagrant.d/ folder. Set up the VAGRANT_HOME environment variable to change this location.

!!! question "How can i change the folder where virtualbox create the box ?"
    Go to virtualbox preferences and change the virtualbox vm location folder.

!!! question "I already got a lab installed with v2, is v3 will use it ?"
    Sorry no, the v3 of GOAD doesn't look for already installed lab. Best way to migrate is trash your old lab and build a new one.

!!! question "Can i use goad to create a course for my student ?"
    Sure GOAD is a GPL project. Feel free to reuse it to give course. Just don't forget to give credits to the project ;)