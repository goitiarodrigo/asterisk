import { useState } from 'react';
import { useSipClient, SipConfig } from './hooks/useSipClient';
import { CameraStream } from './components/CameraStream';
import './App.css';

// Función helper para obtener variables de entorno
// Prioridad: window.ENV (Docker runtime) > import.meta.env (dev) > defaults
const getEnvVar = (key: string, defaultValue: string): string => {
  // @ts-ignore - window.ENV se inyecta en runtime por Docker
  if (typeof window !== 'undefined' && window.ENV && window.ENV[key]) {
    // @ts-ignore
    return window.ENV[key];
  }
  return import.meta.env[key] || defaultValue;
};

// CONFIGURACIÓN - Valores desde variables de entorno
const DEFAULT_CONFIG: SipConfig = {
  server: getEnvVar('VITE_ASTERISK_SERVER', 'asterisk'),
  port: getEnvVar('VITE_ASTERISK_PORT', '8089'),
  username: getEnvVar('VITE_SIP_USERNAME', 'webuser3001'),
  password: getEnvVar('VITE_SIP_PASSWORD', 'WebUser3001!'),
  extension: getEnvVar('VITE_SIP_EXTENSION', '3001'),
};

// Lista de cámaras disponibles
const CAMERAS = [
  { extension: '1001', label: 'Notebook 1 - Cámara Frontal' },
  { extension: '1002', label: 'Notebook 2 - Cámara Pasajeros' },
  { extension: '1003', label: 'Notebook 3 - Cámara Trasera' },
];

function App() {
  const [config, setConfig] = useState<SipConfig>(DEFAULT_CONFIG);
  const [isConfigMode, setIsConfigMode] = useState(true);

  const {
    isRegistered,
    isRegistering,
    error,
    activeSessions,
    register,
    unregister,
    callExtension,
    hangup,
    hangupAll,
  } = useSipClient(config);

  const handleConnect = () => {
    register();
    setIsConfigMode(false);
  };

  const handleDisconnect = async () => {
    await hangupAll();
    await unregister();
    setIsConfigMode(true);
  };

  if (isConfigMode) {
    return (
      <div className="config-container">
        <div className="config-card">
          <h1>🎥 Monitor de Cámaras - Asterisk WebRTC</h1>
          <p style={{ color: '#9ca3af', marginBottom: '24px' }}>
            Configuración de conexión a Asterisk
          </p>

          <div className="config-form">
            <div className="form-group">
              <label>Servidor Asterisk (IP)</label>
              <input
                type="text"
                value={config.server}
                onChange={(e) => setConfig({ ...config, server: e.target.value })}
                placeholder="192.168.1.100"
              />
            </div>

            <div className="form-group">
              <label>Puerto WebSocket</label>
              <input
                type="text"
                value={config.port}
                onChange={(e) => setConfig({ ...config, port: e.target.value })}
                placeholder="8089"
              />
            </div>

            <div className="form-group">
              <label>Usuario</label>
              <input
                type="text"
                value={config.username}
                onChange={(e) => setConfig({ ...config, username: e.target.value })}
                placeholder="webuser3001"
              />
            </div>

            <div className="form-group">
              <label>Contraseña</label>
              <input
                type="password"
                value={config.password}
                onChange={(e) => setConfig({ ...config, password: e.target.value })}
                placeholder="WebUser3001!"
              />
            </div>

            <div className="form-group">
              <label>Extensión</label>
              <input
                type="text"
                value={config.extension}
                onChange={(e) => setConfig({ ...config, extension: e.target.value })}
                placeholder="3001"
              />
            </div>

            {error && (
              <div className="error-message">
                ⚠️ {error}
              </div>
            )}

            <button
              onClick={handleConnect}
              disabled={isRegistering}
              className="connect-button"
            >
              {isRegistering ? 'Conectando...' : 'Conectar a Asterisk'}
            </button>
          </div>

          <div className="help-text">
            <h3>ℹ️ Ayuda</h3>
            <ul>
              <li>Asegúrate de que Asterisk esté corriendo</li>
              <li>Verifica que el puerto 8089 esté abierto</li>
              <li>Si usas certificados autofirmados, acepta el warning del navegador</li>
              <li>
                Para aceptar certificados: visita{' '}
                <code>https://{config.server}:{config.port}</code> primero
              </li>
            </ul>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>🎥 Monitor de Cámaras en Tiempo Real</h1>
        <div className="header-info">
          <span className={`status-badge ${isRegistered ? 'connected' : 'disconnected'}`}>
            {isRegistered ? '✓ Conectado' : '✗ Desconectado'}
          </span>
          <span className="extension-info">Ext: {config.extension}</span>
          <button onClick={handleDisconnect} className="disconnect-button">
            Desconectar
          </button>
        </div>
      </header>

      <div className="cameras-grid">
        {CAMERAS.map((camera) => (
          <CameraStream
            key={camera.extension}
            extension={camera.extension}
            label={camera.label}
            onCall={callExtension}
            onHangup={hangup}
            isActive={activeSessions.has(camera.extension)}
          />
        ))}
      </div>

      <div className="footer-info">
        <p>
          Cámaras activas: {activeSessions.size} / {CAMERAS.length}
        </p>
        {activeSessions.size > 0 && (
          <button onClick={hangupAll} className="hangup-all-button">
            Desconectar Todas
          </button>
        )}
      </div>
    </div>
  );
}

export default App;
