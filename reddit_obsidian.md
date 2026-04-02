Guide: Obsidian with free, self-hosted, instant sync
Updated: 2026-02-10

    Plugin updated to 0.25.43 and caused my devices to go into an endless loop of trying to fix itself, so I decided to start from scratch and just use my backup .md files (this is why backups are important).

    Update compose.yaml volumes.

    Add note below .env on how to generate secure password for CouchDB.

    Add note regarding multi-user setup.

    Add instructions of onboarding other devices.

    Note: under Obsidian - Windows 11 Client, steps beyond 7 are outdated.

Updated: 2026-01-16

    Plugin recently had a major update to version 0.25.37. If updating, one piece of advice is disable LiveSync first and then make a backup of your vaults!. Afterwards, update all your devices at the same time, and only after all devices are on the new version, enable LiveSync one by one.

    Not sure if the guide below is still valid. Will have to test again when I have a chance.

Updated: 2026-01-10

    Add latest tag to image

    Remove unused environment variables

    Add healthcheck per u/SirSoggybottom recommendation

    Organize CouchDB config entries into a table

    Cleanup formating

TLDR: I've been using Obsidian with the LiveSync plugin by vrtmrz for over a month now and not counting the Arr stack, this plugin is without a doubt, the single-best self-hosted service that I run on my server. I use it multiple times a day and at this point I can't live without it. So I decided to contribute back to the community, which has taught me so much, by sharing my experience and also writing a detailed guide. I found that most guides gloss over crucial steps, but then again I rarely know what I'm doing, so take my guide with a pinch of salt.
Story time

I recently went on a journey of trying to find a replacement to Apple Notes which I documented here and I was looking for something that checked the following boxes:

    Able to self-host on my Unraid server.

    Must have an iOS app, not something accessed in a browser.

    Sync my notes between all my devices instantly and seamlessly.

On this wonderful sub-Reddit, Obsidian was constantly recommended. So I downloaded both the Windows 11 app on my desktop and the iOS app on my iPhone, and was extremely pleased how polished it was. It's not open source but I was willing to overlook that.

Then I ran into the roadblock of syncing my notes between devices, which Obsidian does offer a service called Obsidian Sync for $4 a month but I wanted to self-host this aspect, I didn't want to rely on someone else (personal preference). If you don't want to self-host the syncing I highly recommend you support the company by using their sync service.

I was recommended a plugin for Obsidian called LiveSync by vrtmrz which allows you to self-host the syncing process. Below is a detailed guide on how to set this up.
How it works

This "service" has 3 moving parts to it. The Obsidian app, the LiveSync plugin and the CouchDB database in a docker container. Here is a breakdown of each:

    Obsidian app: You install the app on each device. I use it on an iPhone, iPad, Windows 10 laptop, Windows 11 desktop and a web client (docker container from Linuxserver). Each device has a local copy of your notes so you can still use it offline.

    CouchDB: This is where a copy of your notes will be stored (encryption is an option and also recommended).

    LiveSync plugin: The plugin is what does all the heavy lifting of syncing all your devices. It accomplishes this by connecting to your self-hosted CouchDB docker container and storing an encrypted copy there. All your other devices will connect to the database to grab the updated notes allowing for an instant sync.

Docker Compose on Unraid

Below is the docker compose file just to get CouchDB up and running. I installed this on an Unraid server so you can edit the labels and environment variables for your specific OS. Secrets are placed in a separate .env file.
.env

COUCHDB_USER=obsidian_user # optionally change me
COUCHDB_PASSWORD=obsidian_password # definitly change me

Note: use: openssl rand -hex 32 in terminal to generate a secure password.
compose.yaml

services:
obsidian-livesync:
container_name: obsidian-livesync #shortened name
image: couchdb:latest
env_file: - .env
environment: - COUCHDB_USER=${COUCHDB_USER}
      - COUCHDB_PASSWORD=${COUCHDB_PASSWORD}
volumes: - /mnt/user/appdata/couchdb-obsidian-livesync/data:/opt/couchdb/data - /mnt/user/appdata/couchdb-obsidian-livesync/etc:/opt/couchdb/etc/local.d
ports: - "5984:5984"
restart: unless-stopped
healthcheck:
test: curl --fail -s -u ${COUCHDB_USER}:${COUCHDB_PASSWORD} http://localhost:5984/\_up | grep -Eo '\"status\":\"ok\"' || exit 1
interval: 30s
timeout: 10s
retries: 3
labels: - "net.unraid.docker.webui=http://[IP]:[PORT:5984]/\_utils" # for some reason this does not work properly - "net.unraid.docker.icon=https://raw.githubusercontent.com/selfhst/icons/refs/heads/main/png/couchdb.png"

CouchDB - Initial Configuration

    Go to the CouchDB admin page by going here: http://192.168.1.0:5984/_utils make sure to use your server's IP address.

    Login using the credentials you set in the .env file.

    Click on the hamburger ☰ icon on the top left, it will expand the menu from simple icons to icons with text which will make following this guide easier.

    Click on Setup on the left menu.

    Click on Configure as Single Node and enter the same admin credentials from the .env file into the Specify your Admin credentials fields.

    Leave everything else the same and click Configure Node.

    A notification on the top right should pop-up with a green checkmark and the message: Single node setup successful.

CouchDB - Verify Installation

    Let's verify the CouchDB installation by clicking Verify from the side menu.

    Click Verify Installation and if everything is good, a popup banner should popup saying Success! Your CouchDB installation is working. Time to Relax. along with 6 check marks next to each item in the table.

CouchDB - Create Database

    Click on the Databases from the side menu.

    Click on Create Database on the top right.

    Under Database Name enter obsidian, or whatever you like. Advice: if you intend to use this setup for multiple users, each user will need their own database, so I recommend naming the database to include the user's first name like: obsidian_john or obsidian_jane just to make it easier in the future. (Read warning below about multi-user setups.)

    Under Partitioning select Non-partitioned - recommended for most workloads. Once the database is created, you should be redirected to the new database's config page. You don't have to do anything here.

Warning: though you can have multiple users with their own database, this plugin is not intended for multi-user setups. The plugin uses the admin password for the CouchDB admin panel to connect regardless of which database it is accessing. Users can see the admin password via the Obsidian plugin and can potentially switch databases, therefore if security/trust is a concern it is better to simply spin up a separate instance of CouchDB for each user.
CouchDB - Configuration

    Click on Configuration from the side menu. The following 9 config entries are what the shell script was intended to do automatically but I wanted to do it manually. Click on + Add Option on the top right for each entry:

Section Name Value
chttpd require_valid_user true
chttpd_auth require_valid_user true
httpd WWW-Authenticate Basic realm="couchdb"
httpd enable_cors true
chttpd enable_cors true
chttpd max_http_request_size 4294967296
couchdb max_document_size 50000000
cors credentials true
cors origins app://obsidian.md, capacitor://localhost, http://localhost
Obsidian - Windows 11 Client

    Download and install the Windows 11 Obsidian client from here.

    Once installed, open Obsidian.

    Next to Create new vault click the Create button next.

    In the Vault name field, name your Vault whatever you like, I simply named mine Vault. You can think of a vault as a "master folder" that contains all your folders and notes. Some users have different vaults for different aspects of their lives, such as Work or Personal but I keep everything under one vault for ease of use.

    Next setting is Location, click Browse. This is where your vault will be locally saved. I created an Obsidian folder in the Documents folder but you can put it anywhere you like.

    Click Create and Obsidian should open up to your newly created vault with 3 window panes. Next step is to setup the LiveSync plugin.

Obsidian - LiveSync Plugin

    Open Obsidian and click ⚙️ icon on the bottom left of the side menu.

    Under Options, click Community plugins, click Turn on community plugins.

    Next to Community plugins click on the Browse button.

    Search for Self-hosted LiveSync and click on the plugin by vorotamoroz.

    Only 1 plugin should show up and that's the one by voratamoroz, click on it.

    Click Install.

    Click Enable

    Click Open setting dialog button.

    Click Options button.

    Under Settings for Self-hosted LiveSync. you should see a row of 8 buttons, click on the 4th button with the 🛰️ satellite icon.

    This is where we will enter the self-hosted CouchDB details. Next to Remote Type make sure CouchDB is selected from the drop down menu.

    In the URI field type http://192.168.1.0:5984 make sure to change to your server IP and port.

    In the Username field type osidian_user or whatever you used in the docker compose's .env file.

    Same for Password field.

    In the Database name field type obsidiandb or whatever you named your database earlier in CouchDB.

    Click the Test button to test the connection to the CouchDB database. Assuming everything is working properly a text popup should say Connected to obsidiandb successfully.

    Click the Check button to confirm the database was configured properly, there should be a purple checkmark next to each line item. If not, there should be a Fix button next to the item that you can click for it to either create or correct for you, but I prefer to manually do it myself.

    Assuming everything is good up to this point, click the Apply button next to Apply Settings.

    Optional but recommended: scroll down to the End-to-end encryption and toggle it on and set a passphrase. Please remember this passphrase as all your other devices must have matching passphrases for it to be able to decrypt your notes. Click the red button Just apply.

    On the top menu, under Settings for Self-hosted LiveSync. you should see a row of 7 buttons, click on the 5th button with the 🔄 refresh icon.

    Next to Sync mode select LiveSync from the drop down menu.

    You can close the settings windows out, on the top right of the notes you should see Sync: zZz which means everything is working properly and the sync is in standby mode until you start typing something.

Onboard other devices

Luckily, the developer of the plugin created Setup URI which allows you to easily copy settings to other devices without having to do the above manually. Instructions below are destructive and only intended for setting up NEW devices with EMPTY vaults.

    Open Obsidian on your primary device.

    Go to Settings by clicking on the ⚙️ icon located on the bottom of the side menu.

    Under Community Plugins, click Self-hosted LiveSync.

    Under To setup other devices, select one of the 2 methods. Copy the current settings to a Setup URI assumes you can copy a string of text to your other device (e.g. via Remote Desktop) or use Show QR Code if your other device has a camera (e.g. iPhone or iPad). The following instructions will use the Copy the current settings to a Setup URI method.

    Click Copy button.

    Enter a password to encrypt, make sure to write this down. I went with something easy to remember.

    Click the 📋 icon to copy it into your clipboard then click OK button.

    Go to your other device, the following instructions will be for another Windows 11 device but should be similar for every other device. Follow the steps from above, under the headers Obsidian - Windows 11 Client and Obsidian - LiveSync Plugin steps 1 through 7.

    A popup should appear titled: Welcome to Self-hosted LiveSync, select the option I am adding a device to an existing synchronization setup and click Yes, I want to add this device to my existing synchronization.

    Select **Use a Setup URI (Recommended) and click Proceed with Setup URI.

    Copy the URI and Passphrase into their respective fields. Then click Test Settings and Continue.

    Select My remote server is already set up. I want to join this device. and click Proceed to the next step.

    Read the warning, if you accept, click Restart and Fetch Data.

    Some devices show a warning popup title Reset Synchronization of This Device, if so, select This Vault is empty, or contains only new files that are not on the server. then select I have created a backup of my Vault. Then click Reset and Resume Synchronization.

    Obsidian should restart and start fetching all your notes from CouchDB.

    A popup titled All optional features are disabled click OK.

    A popup titled Setting up database size notifications should appear, select 2GB (Standard).

    After the plugin finishes fetching all the notes, you will have to manually enable LiveSync. Go to Settings by clicking on the ⚙️ icon located on the bottom of the side menu.

    Under Community Plugins, click Self-hosted LiveSync.

    Click 🔁 icon.

    Under Synchronization Method, next to Sync Mode, change from On events to LiveSync from the drop down menu. Click the X icon on the top left to close the settings window. The status icon on the top should change from ⏹️ to 💤.

Reverse Proxy

I highly recommend putting this behind at least a reverse proxy, I use Traefik in conjunction with Cloudflare Tunnels. You will definitely need to if you plan on using mobile devices as they require HTTPS.
Conclusion

Hope this gets you up and running. As you get more familiar with the app, you will unlock just how great Obsidian is. Happy to answer any questions.
