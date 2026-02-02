FROM node:18-bookworm-slim AS build
WORKDIR /app

# Instalar herramientas de 	compilación necesarias para dependencias nativas
RUN apt-get update && apt-get install -y --no-install-recommends \
	build-essential python3 ca-certificates && rm -rf /var/lib/apt/lists/*

# Instalar dependencias
COPY package*.json ./
# Intentar instalar con `npm ci` (reproducible). Si falla por peer deps, usar `npm install` como fallback.
# También pasar `--legacy-peer-deps` para evitar errores con peer dependencies en npm v7+.
RUN npm ci --legacy-peer-deps --silent || npm install --legacy-peer-deps --silent

# Copiar el resto y construir la app
COPY . .
RUN npm run build

FROM nginx:alpine

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar los archivos compilados al directorio servido por nginx
COPY --from=build /app/build /usr/share/nginx/html

# Exponer el puerto 9001
EXPOSE 9001

# Ejecutar nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]