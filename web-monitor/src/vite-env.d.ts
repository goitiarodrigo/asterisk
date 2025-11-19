/// <reference types="vite/client" />

// Declaración de variables de entorno de Vite
interface ImportMetaEnv {
  readonly VITE_ASTERISK_SERVER: string
  readonly VITE_ASTERISK_PORT: string
  readonly VITE_SIP_USERNAME: string
  readonly VITE_SIP_PASSWORD: string
  readonly VITE_SIP_EXTENSION: string
  readonly VITE_STUN_SERVERS: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

// Declaración de window.ENV para configuración runtime de Docker
interface WindowEnv {
  VITE_ASTERISK_SERVER?: string
  VITE_ASTERISK_PORT?: string
  VITE_SIP_USERNAME?: string
  VITE_SIP_PASSWORD?: string
  VITE_SIP_EXTENSION?: string
  VITE_STUN_SERVERS?: string
}

interface Window {
  ENV?: WindowEnv
}
