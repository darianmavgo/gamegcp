# Cloud Gaming on GCP

This repository contains a collection of scripts to provision, manage, and configure a Cloud Gaming PC on Google Cloud Platform (GCP), optimized for low-latency gaming using Parsec.

## Prerequisites

*   **Google Cloud Platform Account**: You need a project with billing enabled.
*   **Google Cloud SDK (`gcloud`)**: Installed and authenticated on your local machine.
*   **Parsec**: Installed on your local machine for streaming.
*   **Microsoft Remote Desktop** (or another RDP client): For initial setup and maintenance.

## Getting Started

### 1. Create the Instance

Several scripts are available to provision a new VM. These scripts create a Windows Server instance (optimized for gaming) with an NVIDIA Tesla T4 GPU using Spot provisioning (Preemptible) to minimize costs.

**Choose a creation script based on your preferred region:**

*   `create-windows11v2.sh`: Creates instance `win11-gpu-east` in `us-east1-d`.
*   `create-windows11.sh`: Creates instance `win11-gpu-budget` in `us-central1-a`.

**Example:**
```bash
./create-windows11v2.sh
```

**Note:** Since these are Spot instances, they may be preempted (stopped) by Google at any time, and they will receive a new external IP address upon every restart.

### 2. Initial Configuration (Inside the VM)

After creating the instance, you need to configure it.

1.  **Get Credentials**:
    Use the password reset script to generate/reset the Windows password for RDP access.
    ```bash
    ./reset-user-password.sh
    ```
    *Note: You may need to edit this script to match your specific instance name and zone.*

2.  **Connect via RDP**: Use the External IP provided by the GCP console or CLI.

3.  **Install Software**:
    Once logged in via RDP, copy the helper scripts to the VM or download them to set up the environment.

    *   **Install WinGet**:
        ```powershell
        ./install-winget.ps1
        ```
    *   **Install ViGEmBus**: Required for Parsec to emulate a game controller.
        ```batch
        ./install-game-controller.bat
        ```
    *   **Install NVIDIA Drivers**: Download and install the [latest NVIDIA drivers](https://www.nvidia.com/en-us/software/nvidia-app/) for the Tesla T4.
    *   **Install Parsec**: Download, install, and log in to Parsec. Enable "Hosting" in the settings.

4.  **Configure Network**:
    Ensure the firewall allows Parsec traffic.
    ```bash
    ./allow-parsec.sh
    ```

## Daily Usage

### Starting the Instance
Use the start script corresponding to your instance name and zone.
*   `start-rocket-leaguev5.sh`: Starts `rocket-league-gaming` in `us-east4-c`.
*   `start-rocket-league.sh`: Starts `rocket-league`.

*Note: The repository contains scripts for various instance names (`win11-gpu-east`, `rocket-league-gaming`, etc.). You may need to update the scripts or rename your instance to match.*

### Stopping the Instance
Always stop the instance when not in use to avoid unnecessary charges.
```bash
./stop-rocket-league.sh
```

## Utilities & Troubleshooting

### Updating RDP IP on macOS
Because the IP address changes on every restart, updating your RDP client can be tedious. The `update_ip.sql` file contains a snippet to update the Microsoft Remote Desktop database on macOS.

1.  Find your new IP address.
2.  Update the IP in `update_ip.sql`.
3.  Run the SQLite update command (see `README.md` history or script comments for the specific path to your RDP database).

### GPU Management
*   `check-gpu.ps1`: Checks the status of the GPU inside Windows.
*   `deallocate-gpu.sh`: Detaches the GPU from the instance.

### Diagnostics
*   `diagnose-slowness.ps1`: Script to help identify performance bottlenecks.
*   `show-cpu-hogs.ps1`: Identifies processes consuming high CPU.

## File List
*   `create-windows11*.sh`: Provisioning scripts.
*   `start-rocket-league*.sh`: Startup scripts for different zones/instances.
*   `install-winget.ps1`: Installs Windows Package Manager.
*   `install-game-controller.bat`: Installs ViGEmBus driver.
*   `reset-user-password.sh`: Resets Windows user password.
*   `allow-parsec.sh`: GCP Firewall rule creation for Parsec.

## Progress 
* Failed: Never got streaming of game controller from macos to gce windows vm working.
* Success: Audio streaming in Parsec and Windows App
* Success: Video streaming at 1440x900
* If I get that xbox game controller working this would have been a fantastic solution to enjoy heavy gpu games that don't run on mac. Far better than running window on Paralell.
