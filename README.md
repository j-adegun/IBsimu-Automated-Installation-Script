# IBsimu Automated Installation Script

This repository contains `install_ibsimu.sh`, a bash script designed to automate the installation of **IBSimu (libibsimu-1.0.6)** on Linux systems (Ubuntu/Debian/WSL).

## Features
* **Seamless Installation:** Automates the step-by-step process from the [official IBSimu documentation](https://ibsimu.sourceforge.net/installation.html).
* **Dependency Management:** Automatically installs compilers, graphics libraries (GTK+ 3.0, Cairo), and solvers (SuiteSparse/UMFPACK).
* **Robust Networking:** Includes download fallback logic and manual file detection for GSL, LIBCSG, and IBSimu.
* **Environment Configuration:** Automatically updates your `~/.profile` with the necessary `PATH` and `LD_LIBRARY_PATH`.
* **Verification:** Compiles and runs the `vlasov2d.cpp` example immediately after installation to ensure everything is working.

## Prerequisites
* A Debian-based Linux distribution (Ubuntu, Mint, Debian, or WSL).
* Sudo privileges (to install system-level dependencies).

## Quick Start
1. **Download the script** to your machine. Recommended location --> /home directory
2. **Make it executable**:
   ```bash
   chmod +x install_ibsimu.sh
   ./install_ibsimu.sh
 
## ⚠️ Troubleshooting: The GSL Mirror Issue
* The GNU Scientific Library (GSL) mirrors can occasionally be unreachable. If the script fails to download:
* Manual Download: Obtain gsl-latest.tar.gz from an alternative mirror.
* Placement: Save the file in your /home directory, same location as `install_ibsimu.sh`
* Restart: Relaunch the script. It will detect the local file, copy it to the build directory, and proceed automatically.
# Disclaimer
* Note: This script is provided "as is," without warranty of any kind. While it has been thoroughly tested on standard Debian/Ubuntu environments, use it at your own risk. The author is not responsible for any system instability or data loss.
