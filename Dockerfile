FROM debian

RUN apt-get update && apt-get install -y wget zip git make
RUN wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update && apt-get install -y erlang

COPY ./sse-broadcast-benchmark /eventsource
#VOLUME ./eventsource /eventsource

WORKDIR /eventsource

RUN make

EXPOSE 1942

CMD ["/eventsource/_rel/eventsource_release/bin/eventsource_release", "foreground"]
