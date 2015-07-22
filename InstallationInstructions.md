# Setting Up the Environment #
The following steps will prepare your environment to run _Agjudge tayon_.
  1. Download and install the _Ruby 1.8.6 One-Click Installer_ available from http://www.ruby-lang.org/en/downloads/.  During the installation, be sure to check the "Enable RubyGems" option.
  1. Install _Rails_ using RubyGems by issuing the following command at the DOS command prompt:
> > `>> gems install rails --version=2.3.2`
  1. Install _Prawn_ (which is used for report generation) by issuing the following command at the DOS command prompt:
> > `>> gems install prawn`
  1. Install the _SQLite3 Ruby library_ by issuing the following command at the DOS command prompt:
> > `>> gems install sqlite3-ruby --version=1.2.3`
  1. Install _SQLite3 for Windows_ by downloading the following two zip files and unzipping them into /WINDOWS/system32
    * http://www.sqlite.org/sqlite-3_6_16.zip
    * http://www.sqlite.org/sqlitedll-3_6_16.zip
  1. Download and unzip http://agjudgetayon.googlecode.com/files/agjudgetayon.zip to the `c:` drive.

# Running _Agjudge tayon!_ #
  1. From the command prompt, issue the following commands:
```
C:\>cd agjudgetayon
C:\agjudgetayon>ruby agjudgetayon.rb
=> Booting WEBrick
=> Rails 2.3.2 application starting on http://0.0.0.0:3000
=> Call with -d to detach
=> Ctrl-C to shutdown server
[2009-07-21 22:13:09] INFO  WEBrick 1.3.1
[2009-07-21 22:13:09] INFO  ruby 1.8.6 (2008-08-11) [i386-mswin32]
[2009-07-21 22:13:09] INFO  WEBrick::HTTPServer#start: pid=4040 port=3000
```
  1. From a web browser (Firefox, Internet Explorer, etc.) visit the URL http://localhost:3000

# Running for First Time #
The first time that you access _Agjudge tayon!_ you will be greeted with the screen below.  This is your opportunity to set the administrator password.  Do not forget the password!  If you do, it is impossible to retrieve and you will need to delete the "agjudgetayon" directory and repeat Step 6 under _Setting up the Environment_ above.  This will result in the loss of any pageant data that has already been saved.

[images/FirstRun.png]