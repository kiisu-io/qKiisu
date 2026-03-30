pragma Singleton

import QtQuick 2.15
import QKiisu 1.0

QtObject {
    readonly property string errorStyle:
"<style type='text/css'>p { margin-top: 0px; margin-bottom: 5px; } a { color: #00d96a; } </style>"

    readonly property string errorInvalidDevice:
"<p>Device cannot be recognized.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Disconnect all other similar devices from this computer.</p>
<p>2. Reconnect your Kiisu.</p>
<p>3. If the problem persists, reboot Kiisu into RECOVERY MODE and click REPAIR to perform a clean installation.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorInvalidDeviceLinux:
"<p>Device cannot be recognized.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Disconnect all other similar devices from this computer.</p>
<p>2. Grant user permissions to access Serial devices.</p>
<p>Run \"./qKiisu-x86_64-%1.AppImage rules install\" to do so automatically.</p>
<p>3. If the problem persists, reboot Kiisu into RECOVERY MODE and click REPAIR to perform a clean installation.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>".arg(App.version)

    readonly property string errorSerial:
"<p>Cannot connect to Kiisu. Device is busy.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Ensure that Kiisu is not connected via Bluetooth or Terminal session.</p>
<p>2. Reconnect your Kiisu.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorSerialLinux:
"<p>Cannot connect to Kiisu. Device is busy.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Ensure that Kiisu is not connected via Bluetooth or Terminal session.</p>
<p>2. Grant user permissions to access Serial devices.</p>
<p>Run \"./qKiisu-x86_64-%1.AppImage rules install\" to do so automatically.</p>
<p>3. Reconnect your Kiisu.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>".arg(App.version)

    readonly property string errorRecovery:
"<p>Cannot connect to Kiisu in Update & Recovery mode. Device not found.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Check that Kiisu is in Update & Recovery mode.</p>
<p>2. Reconnect your Kiisu.</p>
<p>3. Reboot Kiisu to Kiisu OS and try again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorRecoveryWindows:
"<p>Cannot connect to Kiisu in Update & Recovery mode. Device not found.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Check that Kiisu is in Update & Recovery mode.</p>
<p>2. Reconnect your Kiisu.</p>
<p>3. Reinstall qKiisu to update DFU device driver.</p>
<p>4. Reboot Kiisu to Kiisu OS and try again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorRecoveryLinux:
"<p>Cannot connect to Kiisu in Update & Recovery mode. Device not found.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Check that Kiisu is in Update & Recovery mode.</p>
<p>2. Reconnect your Kiisu.</p>
<p>3. Grant user permissions to access DFU devices.</p>
<p>Run \"./qKiisu-x86_64-%1.AppImage rules install\" to do so automatically.</p>
<p>4. Reboot Kiisu to Kiisu OS and try again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>".arg(App.version)

    readonly property string errorInternet:
"<p>Cannot connect to update server.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Check your internet connection.</p>
<p>2. Ensure that the update server is not down.</p>
<p>3. Try updating again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorDisk:
"<p>Can’t save or read files to/from the local filesystem.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Make sure that you have free space on your local drive.</p>
<p>2. Check that qKiisu has permissions to write on disk.</p>
<p>3. When applicable, make sure to point qKiisu to the right files/directores.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorBackup:
"<p>Can’t get data from Kiisu. This may be caused by an internal error.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Close all other applications that may use Kiisu.</p>
<p>2. Reboot your Kiisu and reconnect via USB.</p>
<p>3. Run the operation again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorData:
"<p>Necessary data seems to be damaged.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. If applicable, make sure to point qKiisu to the right input file(s).</p>
<p>2. Reboot your Kiisu and reconnect via USB.</p>
<p>3. Run the operation again.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorOperation:
"<p>Current operation was interrupted. Connection to device is lost.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. Check USB connection.</p>
<p>2. Ensure that Kiisu is not locked with PIN code.</p>
<p>3. Connect your Kiisu in Update & Recovery mode and start repair.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorUpdater:
"<p>Firmware update could not be started.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. See details in the logs below.</p>
<p>2. Resolve the problem if possible.</p>
<p>3. Try again.</p>
<p>4. If the error persists, file a bug report.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"

    readonly property string errorUnknown:
"<p>An unknown error has occurred.</p>
<p>=========== HOW TO FIX ============</p>
<p>1. See details in the logs below.</p>
<p>2. Resolve the problem if possible.</p>
<p>3. Try again.</p>
<p>4. If the error persists, file a bug report.</p>
<p>-----------------------------------</p>
<center><a href='https://docs.kiisu.io/'>READ MORE</a></center>"
}
