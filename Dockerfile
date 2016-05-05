FROM        perl:latest
MAINTAINER  Fernando Correa de Oliveira <fco@cpan.org>

RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm Carton

COPY . /workdir
WORKDIR /workdir
RUN carton

ENV MOJO_SLACKRTM_DEBUG 1

CMD ["carton", "exec", "hypnotoad", "app.pl", "daemon"]
