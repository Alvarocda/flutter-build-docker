FROM ubuntu
# https://developer.android.com/studio?hl=pt-br#command-tools
ENV ANDROID_SDK_TOOLS=11076708
RUN apt-get update
RUN apt-get install wget gnupg gnupg1 gnupg2 -y
# Add dart sdk to source list and install it
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update
# RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get install --no-install-recommends -y openjdk-17-jdk \
    openjdk-17-jre \
    git \
    lcov \
    unzip \
    curl \
    sed \
    apt-transport-https \
    libapparmor1 \
    sshpass \
    pkg-config \
    clang \
    cmake \
    ninja-build \
    libgtk-3-dev

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV JAVA_HOME=/usr
ENV PATH=$PATH:$ANDROID_HOME/platform-tools/
ENV PATH=$PATH:$JAVA_HOME/bin
ENV SDK_MANAGER_PATH=$ANDROID_HOME/cmdline-tools/bin/sdkmanager
ENV PATH=$PATH:$SDK_MANAGER_PATH
RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/

RUN echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "emulator" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platforms;android-30" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platforms;android-31" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platforms;android-32" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platforms;android-33" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platforms;android-34" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "platform-tools" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "build-tools;30.0.3" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "build-tools;31.0.0" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "build-tools;32.0.0" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "build-tools;33.0.0" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "build-tools;34.0.0" && \
    echo "y" | ${SDK_MANAGER_PATH} --sdk_root=${ANDROID_HOME} "cmdline-tools;latest"


# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;android;m2repository"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;google_play_services"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;m2repository"
RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses || echo "Failed" \
    && rm android-sdk.zip

RUN wget -O /opt/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip \
    && unzip /opt/sonar-scanner.zip -d /opt/sonar-scanner/

ENV PATH="$PATH:/opt/sonar-scanner/sonar-scanner-cli-5.0.1.3006-linux/bin"
ENV PATH="$PATH:/usr/lib/dart/bin"

RUN mkdir /opt/firebase-cli
RUN wget https://firebase.tools/bin/linux/latest -O /opt/firebase-cli/firebase
RUN chmod +x /opt/firebase-cli/firebase

ENV PATH="$PATH:/opt/firebase-cli"

ADD "https://github.com/flutter/flutter.git" skipcache
RUN cd /opt && \
    git clone https://github.com/flutter/flutter.git -b stable 

ENV PATH=$PATH:/opt/flutter/bin

# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "emulator"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-18;google_apis;x86"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-27;google_apis_playstore;x86"
RUN flutter config  --no-analytics && \
    flutter precache
RUN yes "y" | flutter doctor --android-licenses
RUN flutter doctor -v
RUN apt-get clean
RUN apt-get autoremove

RUN cd /opt/flutter/examples/hello_world && \ 
    flutter build apk --split-per-abi && \
    flutter build appbundle


# RUN flutter --version
#
# /opt/android-sdk-linux/tools/bin/avdmanager create avd -k 'system-images;android-18;google_apis;x86' --abi google_apis/x86 -n 'test' -d 'Nexus 4'
# emulator -avd test -no-skin -no-audio -no-window
