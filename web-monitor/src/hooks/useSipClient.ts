import { useState, useEffect, useCallback } from 'react';
import {
  UserAgent,
  Registerer,
  Inviter,
  Session,
  SessionState,
  RegistererState,
} from 'sip.js';
import { SessionDescriptionHandler } from 'sip.js/lib/platform/web';

export interface SipConfig {
  server: string;        // Ejemplo: "192.168.1.100"
  port: string;          // Ejemplo: "8089"
  username: string;      // Ejemplo: "3001"
  password: string;      // Ejemplo: "WebUser3001!"
  extension: string;     // Ejemplo: "3001"
}

export interface SipClientState {
  isRegistered: boolean;
  isRegistering: boolean;
  error: string | null;
  activeSessions: Map<string, Session>;
}

export const useSipClient = (config: SipConfig) => {
  const [userAgent, setUserAgent] = useState<UserAgent | null>(null);
  const [registerer, setRegisterer] = useState<Registerer | null>(null);
  const [state, setState] = useState<SipClientState>({
    isRegistered: false,
    isRegistering: false,
    error: null,
    activeSessions: new Map(),
  });

  // Inicializar User Agent
  useEffect(() => {
    const uri = `sip:${config.username}@${config.server}`;
    const transportOptions = {
      server: `wss://${config.server}:${config.port}/ws`,
      // IMPORTANTE: Para desarrollo con certificados autofirmados
      // En producción, remover esto y usar certificados válidos
      connectionTimeout: 10,
    };

    // STUN servers desde variables de entorno o defaults
    // @ts-ignore - window.ENV se inyecta en runtime por Docker
    const stunServersEnv = (typeof window !== 'undefined' && window.ENV?.VITE_STUN_SERVERS)
      ? window.ENV.VITE_STUN_SERVERS
      : (import.meta.env.VITE_STUN_SERVERS || 'stun:stun.l.google.com:19302,stun:stun1.l.google.com:19302');
    const stunServers = stunServersEnv.split(',').map((url: string) => ({ urls: url.trim() }));

    const ua = new UserAgent({
      uri: UserAgent.makeURI(uri)!,
      transportOptions,
      authorizationUsername: config.username,
      authorizationPassword: config.password,
      sessionDescriptionHandlerFactoryOptions: {
        peerConnectionConfiguration: {
          iceServers: stunServers,
        },
      },
      displayName: `Operador ${config.extension}`,
      logLevel: import.meta.env.PROD ? 'warn' : 'debug',
    });

    setUserAgent(ua);

    return () => {
      ua.stop();
    };
  }, [config]);

  // Registrar en Asterisk
  const register = useCallback(async () => {
    if (!userAgent) {
      setState((prev) => ({ ...prev, error: 'User Agent no inicializado' }));
      return;
    }

    setState((prev) => ({ ...prev, isRegistering: true, error: null }));

    try {
      await userAgent.start();

      const registerer = new Registerer(userAgent);
      setRegisterer(registerer);

      // Listener de cambios de estado
      registerer.stateChange.addListener((state) => {
        console.log(`Registerer state: ${state}`);
        setState((prev) => ({
          ...prev,
          isRegistered: state === RegistererState.Registered,
          isRegistering: state === RegistererState.Initial || state === RegistererState.Unregistered,
        }));
      });

      await registerer.register();
      console.log('Registrado en Asterisk');
    } catch (error) {
      console.error('Error al registrar:', error);
      setState((prev) => ({
        ...prev,
        error: `Error de registro: ${error}`,
        isRegistering: false,
      }));
    }
  }, [userAgent]);

  // Desregistrar
  const unregister = useCallback(async () => {
    if (registerer) {
      await registerer.unregister();
      setState((prev) => ({ ...prev, isRegistered: false }));
    }
  }, [registerer]);

  // Llamar a una extensión (cámara)
  const callExtension = useCallback(
    (targetExtension: string): Promise<HTMLVideoElement | null> => {
      return new Promise(async (resolve, reject) => {
        if (!userAgent || !state.isRegistered) {
          reject(new Error('No registrado'));
          return;
        }

        const target = UserAgent.makeURI(`sip:${targetExtension}@${config.server}`);
        if (!target) {
          reject(new Error('URI inválido'));
          return;
        }

        // Crear un stream de audio silencioso (dummy) para receive-only
        // Esto es necesario para que el SDP sea válido sin capturar el micrófono
        const audioContext = new AudioContext();
        const destination = audioContext.createMediaStreamDestination();
        const dummyStream = destination.stream;

        const inviter = new Inviter(userAgent, target, {
          sessionDescriptionHandlerOptions: {
            constraints: {
              audio: true,
              video: false,
            },
          },
        });

        // Reemplazar el stream local con nuestro stream dummy
        const sessionDescriptionHandler = inviter.sessionDescriptionHandler;
        if (sessionDescriptionHandler && 'localMediaStream' in sessionDescriptionHandler) {
          // @ts-ignore - acceso a propiedad interna
          sessionDescriptionHandler.localMediaStream = dummyStream;
        }

        // Configurar video element
        const videoElement = document.createElement('video');
        videoElement.autoplay = true;
        videoElement.playsInline = true;

        // Setup remote media
        inviter.stateChange.addListener((newState) => {
          console.log(`Session ${targetExtension} state: ${newState}`);

          switch (newState) {
            case SessionState.Established: {
              const sessionDescriptionHandler = inviter.sessionDescriptionHandler;
              if (sessionDescriptionHandler instanceof SessionDescriptionHandler) {
                const remoteStream = sessionDescriptionHandler.remoteMediaStream;
                if (remoteStream) {
                  videoElement.srcObject = remoteStream;

                  // Actualizar sesiones activas
                  setState((prev) => {
                    const newSessions = new Map(prev.activeSessions);
                    newSessions.set(targetExtension, inviter);
                    return { ...prev, activeSessions: newSessions };
                  });

                  resolve(videoElement);
                }
              }
              break;
            }
            case SessionState.Terminated:
              // Remover de sesiones activas
              setState((prev) => {
                const newSessions = new Map(prev.activeSessions);
                newSessions.delete(targetExtension);
                return { ...prev, activeSessions: newSessions };
              });
              break;
          }
        });

        // Realizar la llamada
        inviter
          .invite()
          .then(() => {
            console.log(`Llamando a extensión ${targetExtension}...`);
          })
          .catch((error) => {
            console.error('Error al llamar:', error);
            reject(error);
          });
      });
    },
    [userAgent, state.isRegistered, config.server]
  );

  // Colgar llamada
  const hangup = useCallback(
    async (targetExtension: string) => {
      const session = state.activeSessions.get(targetExtension);
      if (session) {
        await session.bye();
        setState((prev) => {
          const newSessions = new Map(prev.activeSessions);
          newSessions.delete(targetExtension);
          return { ...prev, activeSessions: newSessions };
        });
      }
    },
    [state.activeSessions]
  );

  // Colgar todas las llamadas
  const hangupAll = useCallback(async () => {
    const promises = Array.from(state.activeSessions.keys()).map((ext) => hangup(ext));
    await Promise.all(promises);
  }, [state.activeSessions, hangup]);

  return {
    ...state,
    register,
    unregister,
    callExtension,
    hangup,
    hangupAll,
  };
};
