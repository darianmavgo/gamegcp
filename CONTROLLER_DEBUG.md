# VM Creation and Troubleshooting Instructions

This document outlines the steps to create a Google Cloud VM for gaming and troubleshoot Xbox controller streaming issues between macOS (Parsec Client) and Windows Server 2022 (Host).

## 1. Create the Gaming VM

We have updated the creation process. Run the following script from your local machine (where `gcloud` is authenticated) to provision the VM.

```bash
./create-gaming-vm.sh
```

*Note: This script assumes you have `gcloud` installed and configured with the correct project ID.*

## 2. Connect and Setup

1.  Wait for the instance to start.
2.  Reset the password:
    ```bash
    ./reset-debug-password.sh
    ```
3.  Connect via Microsoft Remote Desktop using the external IP and the new password.

## 3. Apply Controller Fixes (Automated)

The troubleshooting suite is now configured to run **automatically** when you create the VM using `create-gaming-vm.sh`. It runs as a Windows Startup Script.

1.  **Wait for Boot**: After running the creation script, wait about 5-10 minutes for Windows to initialize and the script to finish.
2.  **Connect**: Log in via RDP.
3.  **Check Logs**: Open `C:\Temp\ControllerFix.log` to see the results of the 10 automated fixes.

### What does the script do?
It attempts 10 different fixes to resolve the controller streaming issue:

1.  **ViGEmBus Installation**: Checks if the Virtual Gamepad Emulation Bus is installed. If not, attempts to install via `winget`.
2.  **Device Association Service**: Ensures this service is running. It is critical for PnP device detection.
3.  **Windows Audio Service**: Starts `Audiosrv`. Surprisingly, some streaming inputs depend on the audio subsystem timing.
4.  **Xbox 360 Drivers**: Checks for `xusb22.sys`. If missing, you must manually install the "Xbox 360 Controller for Windows" driver for any "Unknown Device" in Device Manager.
5.  **Parsec Service**: Verifies the Parsec background service is running (required for virtual input injection).
6.  **GameInput Service**: Checks and starts the Microsoft GameInput service if present.
7.  **Power Settings**: Disables "USB Selective Suspend" to prevent the virtual bus from sleeping.
8.  **Unknown Devices Check**: Scans for devices in an error state (often the virtual controller waiting for a driver).
9.  **XboxGipSvc**: Checks the Xbox Accessory Management Service.
10. **DirectX / XInput**: Verifies `xinput1_3.dll` exists. If not, you must install the DirectX End-User Runtime.

## 4. Verification

After running the script:
1.  **Reboot the VM.**
2.  Connect via Parsec (Client on macOS).
3.  On the VM, open `joy.cpl` (Game Controllers).
4.  You should see "Controller (Xbox 360 For Windows)".
5.  If you see it, press buttons on your physical controller. The bars should move.

### Common Failure: "Unknown Device"
If the script reports "Unknown Devices" or `joy.cpl` is empty:
1.  Open **Device Manager** on the VM.
2.  Look for "Unknown Device" or "Virtual Gamepad" with a yellow warning.
3.  Right-click -> **Update Driver**.
4.  **Browse my computer for drivers** -> **Let me pick from a list...**
5.  Scroll down to **Xbox 360 Peripherals** (or similar).
6.  Select **Xbox 360 Controller for Windows**.
7.  Confirm the installation.

This manual step is often required on Windows Server 2022 because it does not automatically map the Virtual ID to the generic X360 driver.
