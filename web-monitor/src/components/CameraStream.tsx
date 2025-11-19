import { useEffect, useRef, useState } from 'react';

interface CameraStreamProps {
  extension: string;
  label: string;
  onCall: (extension: string) => Promise<HTMLVideoElement | null>;
  onHangup: (extension: string) => void;
  isActive: boolean;
}

export const CameraStream: React.FC<CameraStreamProps> = ({
  extension,
  label,
  onCall,
  onHangup,
  isActive,
}) => {
  const videoRef = useRef<HTMLDivElement>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleConnect = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const videoElement = await onCall(extension);
      if (videoElement && videoRef.current) {
        // Limpiar video anterior si existe
        videoRef.current.innerHTML = '';
        videoRef.current.appendChild(videoElement);
        videoElement.style.width = '100%';
        videoElement.style.height = '100%';
        videoElement.style.objectFit = 'cover';
      }
    } catch (err) {
      setError(`Error al conectar: ${err}`);
      console.error('Error connecting to camera:', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDisconnect = () => {
    onHangup(extension);
    if (videoRef.current) {
      videoRef.current.innerHTML = '';
    }
  };

  return (
    <div
      style={{
        border: isActive ? '3px solid #4ade80' : '2px solid #4b5563',
        borderRadius: '8px',
        padding: '16px',
        backgroundColor: '#1f2937',
        display: 'flex',
        flexDirection: 'column',
        gap: '12px',
      }}
    >
      <div
        style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <h3 style={{ margin: 0, fontSize: '18px', color: '#f3f4f6' }}>
          {label}
        </h3>
        <span
          style={{
            padding: '4px 12px',
            borderRadius: '12px',
            fontSize: '12px',
            fontWeight: 'bold',
            backgroundColor: isActive ? '#4ade80' : '#6b7280',
            color: isActive ? '#000' : '#fff',
          }}
        >
          {isActive ? 'CONECTADO' : 'DESCONECTADO'}
        </span>
      </div>

      <div
        ref={videoRef}
        style={{
          width: '100%',
          height: '300px',
          backgroundColor: '#000',
          borderRadius: '4px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: '#9ca3af',
          fontSize: '14px',
          overflow: 'hidden',
        }}
      >
        {!isActive && !isLoading && 'Sin señal'}
        {isLoading && 'Conectando...'}
      </div>

      {error && (
        <div
          style={{
            padding: '8px',
            backgroundColor: '#dc2626',
            color: '#fff',
            borderRadius: '4px',
            fontSize: '12px',
          }}
        >
          {error}
        </div>
      )}

      <div style={{ display: 'flex', gap: '8px' }}>
        <button
          onClick={handleConnect}
          disabled={isActive || isLoading}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: isActive ? '#6b7280' : '#3b82f6',
            color: '#fff',
            border: 'none',
            borderRadius: '6px',
            cursor: isActive || isLoading ? 'not-allowed' : 'pointer',
            fontWeight: 'bold',
            fontSize: '14px',
            opacity: isActive || isLoading ? 0.5 : 1,
          }}
        >
          {isLoading ? 'Conectando...' : 'Conectar'}
        </button>
        <button
          onClick={handleDisconnect}
          disabled={!isActive}
          style={{
            flex: 1,
            padding: '10px',
            backgroundColor: isActive ? '#dc2626' : '#6b7280',
            color: '#fff',
            border: 'none',
            borderRadius: '6px',
            cursor: isActive ? 'pointer' : 'not-allowed',
            fontWeight: 'bold',
            fontSize: '14px',
            opacity: isActive ? 1 : 0.5,
          }}
        >
          Desconectar
        </button>
      </div>

      <div style={{ fontSize: '12px', color: '#9ca3af' }}>
        Extensión: {extension}
      </div>
    </div>
  );
};
