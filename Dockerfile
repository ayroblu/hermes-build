FROM ubuntu
WORKDIR /ws
ENV HERMES_WS_DIR=/ws
RUN apt update -y && apt install build-essential ninja-build git-all cmake python3 libicu-dev -y
RUN git clone https://github.com/facebook/hermes.git
# RUN cmake -S hermes -B build -G Ninja
# RUN cmake --build ./build
# RUN cmake -S hermes -B build_release -G Ninja -DCMAKE_BUILD_TYPE=Release
# RUN cmake --build ./build_release

RUN cmake -S hermes -B ./build
RUN cmake --build ./build --target hermesc

# Install required packages
RUN apt-get install -y --no-install-recommends \
    wget unzip openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Set the version and URL for CMake
ENV CMAKE_VERSION=3.22.1
ENV CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz

# Download and install CMake
RUN wget -qO- ${CMAKE_URL} | tar --strip-components=1 -xz -C /usr/local

# Set environment variables for the Android SDK
ENV ANDROID_SDK_ROOT=/sdk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
ENV PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH

# Download and install the Android SDK Command-line Tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

# Accept the Android SDK licenses
RUN yes | sdkmanager --licenses

# Install essential Android SDK components (platform-tools, build-tools, etc.)
RUN sdkmanager "platform-tools" "build-tools;34.0.0" "platforms;android-34"
#ENV ANDROID_HOME "/sdk"
#ENV PATH "$PATH:${ANDROID_HOME}/tools"

# RUN apt install openjdk-17-jdk -y
RUN cd hermes/android && ./gradlew build
CMD ["bash"]
