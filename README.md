![Build](https://github.com/syphr42/webtts/workflows/build-images/badge.svg)

# Supported tags and respective `Dockerfile` links

- [`dev` (*Dockerfile*)](https://github.com/syphr42/webtts/blob/master/Dockerfile)
- [`1.1.0`, `latest` (*Dockerfile*)](https://github.com/syphr42/webtts/blob/v1.1.0/Dockerfile)

# What is WebTTS?
WebTTS is an Apache-based webserver running a small PHP script to access the Pico Text-To-Speech (TTS) engine for generating sound files from text. It can be useful for home automation systems or any application where speech feedback is required via a local web service.

After starting the container based on this image, access the TTS engine with the following web request:
http://localhost/tts.php?lng=en-US&msg=Hello%20World

The configuration is based on the guide found here: https://github.com/openhab/openhab/wiki/Use-local-TTS-with-squeezebox

The Docker image can be found here: https://hub.docker.com/r/syphr/webtts/
