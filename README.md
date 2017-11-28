# Train

This is the control program for the Shop and Christmas train. The train is an
LGB trolley at this point.

Control of the train is through the Pi Phone or through the website generated
by this application. This app also provides status to Tack Status.

## To Do

  - Page should have current train status.
  - Page should have a speed selector from 00 - 100 by 10s.

## Generating Raspberry Pi OS

Note that I could not get Brunch working. Elixir programs running here should be built so they do not need brunch.

Load Raspbian version of 'jessie' at: http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-07-05/

Following instructions on the Elixir site for loading Elixir and of course Erlang. Note that this also loaded WiringPi.

Load the erlang tools with ....
sudo apt-get update
sudo apt-get install esl-erlang

DONE!

See following ...

You need to install the esl-erlang package which comes with all the tools.

My Phoenix installation procedure for Ubuntu is this:

# Ubuntu 15.10 (wily)
sudo apt-get install inotify-tools
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir
mix local.hex
mix archive.install https://github.com/phoenixframework/phoenix/releases/download/v1.1.0/phoenix_new-1.1.0.ez

### Oops

Note the following did not work when trying to load Elang/Elixir on 'stretch',
the Debian version of Raspbian for the Pi.

The latest version of the Raspbian operating system can be found at:

    https://www.raspberrypi.org/downloads/Raspbian

For this installation, the Raspbian Stretch Lite OS from September 2017 was
used. The release date is 07-Sep-2017 and is based on the 4.7 Linux kernel.

1 - Download the Zip file for the OS described above.
2 - Download and install the latest version of Etcher.
3 - Place an new SD card in the SD slot on the Mac.
4 - Run Etcher, select the Raspbian zip file and proper SD card and hit Flash. This process takes 5-6 minutes and includes a verification step.
5 - Create an empty file on the desktop with filename ssh ... no extension. Move this file to the 'boot' volume created by Etcher. You may have to eject/remove the SD card and plug it back in. This step from https://hackernoon.com/raspberry-pi-headless-install-462ccabd75d0
6 - Eject the 'boot' volume and remove from the laptop.
7 - Install the new SD card into the train controller and turn on the power.
8 - The train controller should be on the same IP address since it is mac assigned. For this install it was 10.0.1.211.
9 - SSH into the train controller from another computer. You may need to delete the ssh keys associated with the train controller to allow for the ssh to be authorized.

----- Installing Java
0 - See this ... http://blog.livthomas.net/installing-java-8-on-raspberry-pi-3/
1 - From the Oracle website, download the lastest version of the Linux ARM 32 Hard Float ABI.
2 - If you downloaded this to your mac, then copy it using:
scp /Users/bengm0ra/Downloads/jdk-8u151-linux-arm32-vfp-hflt.tar.gz pi@10.0.1.211:/home/pi
3 - Make directory 'sudo mkdir /usr/java'
4 - Move to directory 'cd /usr/java'
5 - Extract the tar file using:
6 - sudo tar xf /home/pi/jdk-8u151-linux-arm32-vfp-hflt.tar.gz
7 - sudo update-alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_151/bin/java 1000
8 - sudo update-alternatives --install /usr/bin/javac javac /usr/java/jdk1.8.0_151/bin/javac 1000
9 - Check install with java -version

----- Installing WiringPi
0 - From ... http://wiringpi.com/download-and-install/
1 - Make sure 'gpio' is not installed. Run gpio -v.
2 - run ... sudo apt-get purge wiringpi
3 - run ... hash -r
4 - run ... sudo apt-get update
5 - run ... sudo apt-get upgrade
6 - If git is not installed, run ... sudo apt-get install git-core
7 - run ... cd
8 - run ... git clone git://git.drogon.net/wiringPi
9 - run ... cd ~/wiringPi
10 - run ... git pull origin
11 - run ... cd ~/wiringPi
12 - run ... ./build
13 - Test by running ... gpio -v and also gpio readall

---- Installing Erlang / Elixir
0 - From ...
