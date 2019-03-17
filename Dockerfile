# npm install stage

FROM node:8 as build-deps

COPY ./package.json /workspace/
COPY ./package-lock.json /workspace/

WORKDIR /workspace
RUN npm install

# sass build stage

FROM jbergknoff/sass as build-sass
COPY --from=build-deps /workspace /workspace

COPY ./src /workspace/src

WORKDIR /workspace/src/
RUN sass main.scss main.css

# elm build stage

FROM node:8 as build-elm
RUN npm install -g elm-github-install create-elm-app@3.0.3 --unsafe-perm=true

COPY ./public /workspace/public
COPY ./elm.json /workspace/

COPY --from=build-sass /workspace /workspace
WORKDIR /workspace
RUN elm-app install elm/browser
RUN elm-app build

# final server stage

FROM httpd:2.4 as final
COPY --from=build-elm /workspace/build/ /usr/local/apache2/htdocs/
RUN chmod -R a+r /usr/local/apache2/htdocs