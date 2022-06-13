## Flutter specialized image (Tested with GitLab)
This is the first image i've created with Docker  
This image is specialized in testing and building Android Flutter apps

### Docker Hub
Image url: https://hub.docker.com/r/alvarocda/flutter  

docker pull alvarocda/flutter:latest


### This image contains
- Android SDK 32
- Build Tools 29.0.3
- Build Tools 30.0.2
- Build Tools 30.0.3
- Build Tools 31.0.0
- Build Tools 32.0.0
- LCOV
- sed
- Flutter Latest Stable version (/opt/flutter/bin)
- Dart SDK installed separately for more reliability in a CI/CD environment (/usr/lib/dart/bin)
- Sonar Scanner (/opt/sonar-scanner/sonar-scanner-4.6.2.2472-linux/bin)
- Firebase CLI (/opt/firebase-cli) 



If you are using this image with GitLab pipeline, you can generate an code coverage report  
Make your .gitlab-ci.yml looks like the example bellow

```yaml
tests:
  image: alvarocda/flutter
  stage: test
  script:
  - flutter analyze
  - flutter test --coverage  # Test app and generate the coverage file
  - lcov --list coverage/lcov.info # Parse the file to genhtml
  - genhtml coverage/lcov.info --output=coverage # Generate detailed report
  artifacts:
    paths:
    - coverage # Upload the report so you can download and view
```

To show the percentage of covered code in GitLab
- Go to project settings
- Open CI / CD option
- General Pipelines
- In Test coverage parsing put the following regex: 
```
\s*lines\.*:\s*([\d\.]+%)
```


