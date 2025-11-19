import { useRef, useState, useEffect } from 'react';

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
  const videoContainerRef = useRef<HTMLDivElement>(null);
  const videoElementRef = useRef<HTMLVideoElement | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleConnect = async () => {
    setIsLoading(true);
    setError(null);

    try {
      const videoElement = await onCall(extension);
      if (videoElement && videoContainerRef.current) {
        // Guardar referencia al elemento de video
        videoElementRef.current = videoElement;

        // Limpiar contenedor
        while (videoContainerRef.current.firstChild) {
          videoContainerRef.current.removeChild(videoContainerRef.current.firstChild);
        }

        // Agregar nuevo elemento de video
        videoContainerRef.current.appendChild(videoElement);
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
    // Limpiar el elemento de video
    if (videoElementRef.current && videoContainerRef.current) {
      videoContainerRef.current.removeChild(videoElementRef.current);
      videoElementRef.current = null;
    }
  };

  // Cleanup cuando el componente se desmonta
  useEffect(() => {
    return () => {
      if (videoElementRef.current && videoContainerRef.current) {
        videoContainerRef.current.removeChild(videoElementRef.current);
        videoElementRef.current = null;
      }
    };
  }, []);

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
        style={{
          width: '100%',
          height: '300px',
          backgroundColor: '#000',
          borderRadius: '4px',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        {/* Contenedor de video - manipulado directamente */}
        <div
          ref={videoContainerRef}
          style={{
            width: '100%',
            height: '100%',
          }}
        />

        {/* Mensajes de estado - solo cuando no hay video */}
        {!isActive && !isLoading && (
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#9ca3af',
              fontSize: '14px',
              pointerEvents: 'none',
            }}
          >
            Sin señal
          </div>
        )}
        {isLoading && (
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: '100%',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#9ca3af',
              fontSize: '14px',
              pointerEvents: 'none',
            }}
          >
            Conectando...
          </div>
        )}
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
