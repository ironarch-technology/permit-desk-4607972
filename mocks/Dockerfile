FROM node:22-alpine

WORKDIR /srv/services

COPY package.json ./
COPY . .

RUN addgroup -S city && adduser -S city -G city \
 && chown -R city:city /srv/services
USER city

CMD ["node", "zoning/index.js"]
