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
RUN apt install openjdk-21-jdk -y
RUN cd hermes/android && ./gradlew build
CMD ["bash"]
