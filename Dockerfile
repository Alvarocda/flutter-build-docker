FROM ubuntu

ENV ANDROID_SDK_TOOLS=8512546

RUN apt-get update
# RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y default-jdk
RUN apt-get install --no-install-recommends -y git
RUN apt-get install --no-install-recommends -y lcov
RUN apt-get install --no-install-recommends -y wget
RUN apt-get install -y unzip
RUN apt-get install --no-install-recommends -y curl
RUN apt-get install sed
RUN apt-get install gnupg -y
RUN apt-get install gnupg1 -y
RUN apt-get install gnupg2 -y
RUN apt-get install apt-transport-https
RUN apt-get install -y libapparmor1
RUN apt-get install -y sshpass
RUN apt-get install -y pkg-config
RUN apt-get install -y clang
RUN apt-get install -y cmake
RUN apt-get install -y ninja-build
RUN apt-get install -y libgtk-3-dev

# Add dart sdk to source list and install it
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
RUN apt-get update
RUN apt-get install dart

ENV ANDROID_HOME=/opt/android-sdk-linux
ENV JAVA_HOME=/usr
ENV PATH=$PATH:$ANDROID_HOME/platform-tools/
ENV PATH=$PATH:$JAVA_HOME/bin
ENV SDK_MANAGER_PATH=$ANDROID_HOME/cmdline-tools/bin/sdkmanager
ENV PATH=$PATH:$SDK_MANAGER_PATH
RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "platforms;android-30"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "platforms;android-32"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "platforms;android-33"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "platform-tools"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;29.0.3"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;30.0.0"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;30.0.2"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;30.0.3"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;31.0.0"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;32.0.0"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "build-tools;33.0.0"
RUN echo "y" | $SDK_MANAGER_PATH --sdk_root=$ANDROID_HOME "cmdline-tools;latest"

# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;android;m2repository"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;google_play_services"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;m2repository"
RUN yes | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses || echo "Failed" \
    && rm android-sdk.zip

RUN wget -O /opt/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip /opt/sonar-scanner.zip -d /opt/sonar-scanner/

ENV PATH="$PATH:/opt/sonar-scanner/sonar-scanner-4.6.2.2472-linux/bin"
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
RUN flutter config  --no-analytics
RUN flutter precache
RUN yes "y" | flutter doctor --android-licenses
RUN flutter doctor -v
RUN apt-get clean
RUN apt-get autoremove

RUN cd /opt/flutter/examples/hello_world && \ 
    flutter build apk --split-per-abi && \
    flutter build appbundle

#
# /opt/android-sdk-linux/tools/bin/avdmanager create avd -k 'system-images;android-18;google_apis;x86' --abi google_apis/x86 -n 'test' -d 'Nexus 4'
# emulator -avd test -no-skin -no-audio -no-window
