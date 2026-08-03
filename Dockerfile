# --- desenvolvimento: código por bind mount, ng serve com hot reload ---
FROM node:24-alpine AS dev

# Chromium para rodar os specs em modo headless dentro do container.
RUN apk add --no-cache chromium
ENV CHROME_BIN=/usr/bin/chromium-browser

# Usuário com o UID do host. Sem isso, dist/ e .angular/ nascem como root
# na pasta do host e o editor não consegue mais alterá-los. A imagem node já
# traz o usuário "node" com UID 1000.
ARG UID=1000
ARG GID=1000
# node_modules precisa existir na imagem com o owner correto: o Docker herda
# o ownership do ponto de montagem ao criar o volume nomeado. Sem isso, o
# volume nasce como root e o npm install falha com EACCES.
RUN mkdir -p /app/node_modules /home/node/.npm-global \
    && chown -R "$UID:$GID" /app /home/node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
USER $UID:$GID
WORKDIR /app

# --poll é necessário: a notificação de mudança de arquivo do inotify não
# atravessa de forma confiável o limite entre WSL e container, e sem polling
# o hot reload não dispara.
# node_modules é volume nomeado e nasce vazio - daí a guarda no install.
CMD ["sh", "-c", "[ -d node_modules/@angular ] || npm install; npm start -- --host 0.0.0.0 --port 4200 --poll 1000"]

# --- build de produção ---
FROM node:24-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# --- produção: estático servido por nginx ---
FROM nginx:alpine AS prod
COPY --from=build /app/dist/tcc-frontend/browser /usr/share/nginx/html
EXPOSE 80
