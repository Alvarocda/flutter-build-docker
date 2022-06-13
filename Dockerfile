FROM ubuntu

ENV ANDROID_SDK_TOOLS=7583922


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
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-14-jdk



ENV ANDROID_HOME=/opt/android-sdk-linux
ENV JAVA_HOME=/usr
ENV PATH=$PATH:$ANDROID_HOME/platform-tools/
ENV PATH=$PATH:$JAVA_HOME/bin


RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip \
    && unzip android-sdk.zip -d /opt/android-sdk-linux/
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platforms;android-32"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "platform-tools"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;29.0.3"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;30.0.2"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;30.0.3"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;31.0.0"
RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "build-tools;32.0.0"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;android;m2repository"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;google_play_services"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "extras;google;m2repository"
RUN yes | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses || echo "Failed" \
    && rm android-sdk.zip

RUN wget -O /opt/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip \
    && unzip /opt/sonar-scanner.zip -d /opt/sonar-scanner/

ENV PATH="$PATH:/opt/sonar-scanner/sonar-scanner-4.6.2.2472-linux/bin"

RUN apt-get update
RUN apt-get install apt-transport-https
RUN sh -c 'wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -'
RUN sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'

RUN apt-get update
RUN apt-get install dart
RUN apt-get install -y libapparmor1

ENV PATH="$PATH:/usr/lib/dart/bin"

RUN mkdir /opt/firebase-cli
RUN wget https://firebase.tools/bin/linux/latest -O /opt/firebase-cli/firebase
RUN chmod +x /opt/firebase-cli/firebase

ENV PATH="$PATH:/opt/firebase-cli"

RUN apt-get install -y sshpass


ADD "https://github.com/flutter/flutter.git" skipcache
RUN cd /opt && \
    git clone https://github.com/flutter/flutter.git -b stable 

ENV PATH=$PATH:/opt/flutter/bin

# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "emulator"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-18;google_apis;x86"
# RUN echo "y" | /opt/android-sdk-linux/cmdline-tools/bin/sdkmanager --sdk_root=$ANDROID_HOME "system-images;android-27;google_apis_playstore;x86"

RUN flutter precache
RUN flutter doctor
RUN apt-get clean
RUN apt-get autoremove

RUN cd /opt/flutter/examples/hello_world && \ 
    flutter build apk --split-per-abi && \
    flutter build appbundle

#
# /opt/android-sdk-linux/tools/bin/avdmanager create avd -k 'system-images;android-18;google_apis;x86' --abi google_apis/x86 -n 'test' -d 'Nexus 4'
# emulator -avd test -no-skin -no-audio -no-window
