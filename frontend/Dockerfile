# Usar nginx para servir archivos estáticos
FROM nginx:alpine

# Copiar archivos estáticos del frontend
COPY . /usr/share/nginx/html

# Exponer el puerto 3000
EXPOSE 3000

# Configurar nginx para escuchar en el puerto 3000
RUN echo 'server { listen 3000; location / { root /usr/share/nginx/html; index index.html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf

# Comando para iniciar nginx
CMD ["nginx", "-g", "daemon off;"]