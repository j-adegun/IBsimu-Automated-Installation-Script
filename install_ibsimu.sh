##### run with: bash install_ibsimu.sh or ./install_ibsimu.sh  after runing: chmod +x install_ibsimu.sh #####
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the log file
LOG_FILE="${HOME}/src/install_log.txt"

# Create src directory early to hold the log
mkdir -p "${HOME}/src"

# Start logging everything from this point forward
# This sends all output to both the terminal and the log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================================="
echo "IBsimu Installation Started: $(date)"
echo "Log file location: $LOG_FILE"
echo "=================================================="

# ==========================================
# 1. CREATE .PROFILE
# ==========================================
echo "Creating/Updating ~/.profile..."

cat << 'EOF' > ~/.profile
#!/bin/sh.exe
#
# Get the aliases and functions
#
if [ -f ${HOME}/.bashrc ]
then
  . ${HOME}/.bashrc
fi

export PATH="${HOME}/bin:${HOME}/lib:${PATH}"
export LDFLAGS="-L${HOME}/lib"
export CFLAGS="-I${HOME}/include -O2 -march=native"
export CXXFLAGS="${CFLAGS}"
export PKG_CONFIG_PATH="${HOME}/lib/pkgconfig"
export LD_LIBRARY_PATH="${HOME}/lib"
EOF

export PATH="${HOME}/bin:${HOME}/lib:${PATH}"
export LDFLAGS="-L${HOME}/lib"
export CFLAGS="-I${HOME}/include -O2 -march=native"
export CXXFLAGS="${CFLAGS}"
export PKG_CONFIG_PATH="${HOME}/lib/pkgconfig"
export LD_LIBRARY_PATH="${HOME}/lib:${LD_LIBRARY_PATH}"

# 2. INSTALL SYSTEM TOOLS 
if command -v apt-get &> /dev/null; then
    echo "Installing base system dependencies via apt..."
    sudo apt-get update
    sudo apt-get install -y \
    build-essential\
    libfontconfig1-dev \
    libfreetype6-dev \
    libcairo2-dev \
    libpng-dev \
    zlib1g-dev \
    libgsl-dev \
    libgtk-3-dev \
    libgtkglext1-dev \
    libsuitesparse-dev\
    wget
fi

cd "${HOME}/src"

# --- HELPER FUNCTION FOR HARD WAIT ---
# Arguments: $1=Filename, $2=URL
handle_download() {
    local FILE=$1
    local URL=$2
    
    # 1. Check if it's in HOME but not here
    if [[ -f "${HOME}/$FILE" && ! -f "${HOME}/src/$FILE" ]]; then
        cp "${HOME}/$FILE" "${HOME}/src/"
    fi

    # 2. If still missing, try download
    if [[ ! -f "$FILE" ]]; then
        set +e
        wget --timeout=15 --tries=2 -L -O "$FILE" "$URL"
        local STATUS=$?
        set -e
        
        if [ $STATUS -ne 0 ]; then
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            echo "ERROR: Could not download $FILE"
            echo "Please manually put the file in: $(pwd)"
            echo "URL: $URL"
            echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            until [[ -f "$FILE" ]]; do
                read -p "Press [Enter] after you have placed the file in /src..." < /dev/tty
            done
        fi
    fi
}

# ==========================================
# 3. INSTALL GSL
# ==========================================
GSL_FILE="gsl-latest.tar.gz"
handle_download "$GSL_FILE" "https://mirror.ibcp.fr/pub/gnu/gsl/$GSL_FILE"

echo "Extracting GSL..."
tar -zxvf "$GSL_FILE"
# Enter folder (GSL extracts to gsl-X.X, we find the name dynamically but safely)
cd gsl-*/ 

./configure --prefix="$HOME"
make -j$(nproc)
make check
make install
cd "${HOME}/src"

# ==========================================
# 4. INSTALL LIBCSG
# ==========================================
CSG_FILE="libcsg-0.0.2.tar.gz"
handle_download "$CSG_FILE" "https://downloads.sourceforge.net/project/ibsimu/csg/$CSG_FILE"

tar -zxvf "$CSG_FILE"
cd libcsg-0.0.2/
./configure --prefix="$HOME"
make -j$(nproc)
make check
make install
cd "${HOME}/src"

# ==========================================
# 5. INSTALL IBSIMU
# ==========================================
IBSIMU_FILE="libibsimu-1.0.6.tar.gz"
handle_download "$IBSIMU_FILE" "https://downloads.sourceforge.net/project/ibsimu/ibsimu/$IBSIMU_FILE"

tar -zxvf "$IBSIMU_FILE"
cd libibsimu-1.0.6/
./configure --prefix="$HOME"
make -j$(nproc)
make check
make install
cd "${HOME}/src"

# ==========================================
# 6. FINAL TEST (Vlasov2D)
# ==========================================
mkdir -p "${HOME}/src/simulations"
cd "${HOME}/src/simulations"
wget -O vlasov2d.cpp https://ibsimu.sourceforge.net/vlasov2d/vlasov2d.cpp || echo "Example source not found, skipping run."

if [ -f "vlasov2d.cpp" ]; then
cat << 'EOF' > Makefile
CC = g++
LDFLAGS = `pkg-config --libs ibsimu-1.0.6`
CXXFLAGS = -Wall -g `pkg-config --cflags ibsimu-1.0.6`

vlasov2d: vlasov2d.o
	$(CC) -o vlasov2d vlasov2d.o $(LDFLAGS)

vlasov2d.o: vlasov2d.cpp
	$(CC) -c -o vlasov2d.o vlasov2d.cpp $(CXXFLAGS)

clean:
	$(RM) *~ *.o vlasov2d
EOF
    make
    ./vlasov2d
fi

echo "=================================================="
echo "Installation Finished Successfully!"
echo "Log file: $LOG_FILE"
echo "=================================================="
