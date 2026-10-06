# Optional: run MyEV in a container (for hosting). Needs no npm packages.
# .dockerignore keeps .env and data/ out of the image: set keys in the host's environment settings.
FROM node:22-slim
WORKDIR /app
COPY . .
RUN mkdir -p /app/data && chown node:node /app/data
USER node
ENV HOST=0.0.0.0 PORT=8080
EXPOSE 8080
VOLUME ["/app/data"]
CMD ["node", "--disable-warning=ExperimentalWarning", "server/index.js"]
