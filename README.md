# JPL-Small-Body-Database-SBDB-ephemerides-downloader

## This Matlab program allows you to download ephemerides data from JPL Horizon system through the telnet interface. This is particularly useful when you need to download ephemerides for many NEOs. This program automatically down load, pack and store ephemerides into SPK files, and you can use it to download all asteroid ephmerides in the Horizon system.

Currently, you will need a computer than runs Matlab, the internet connecting the Horizon system and a list of asteroids that needs to be dealt with. An example list has been given. you can always download another list of your ineterest from JPL small body database. Just make sure the columns of your list matches mine. Good luck. For any questions, email me: ruida.space@gmail.com

## How to read those SPK files and generate the epeherides data for a particular asteroid at a particular time point?
You can download the SPICE toolkit for read and process SPK formatted files. You can find how to use it in another repository.