FROM alpine AS build
RUN apk add g++ make expat expat-dev zlib-dev lz4-dev bash
COPY build.sh ./build.sh
COPY dispatcher_client.cc .
COPY dispatcher.cc .
COPY dispatcher_server.cc .
RUN ./build.sh

FROM alpine
RUN apk add libstdc++ expat lz4-dev bash
COPY run.sh ./run.sh
COPY --from=build /overpass /overpass
CMD ["./run.sh"]
