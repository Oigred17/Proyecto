# Usar una imagen base de Node.js
FROM node:16-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar los archivos de definición de paquetes e instalar dependencias
# Esto aprovecha el cache de capas de Docker
COPY package*.json ./
RUN npm install

# Copiar el resto de los archivos de la aplicación
COPY . .

# El puerto por defecto de create-react-app
EXPOSE 3000




# Comando para iniciar la aplicación en modo de desarrollo
CMD ["npm", "start"]
