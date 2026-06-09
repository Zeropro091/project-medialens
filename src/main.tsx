/**
 * main.tsx — legacy SPA entry (used by `npm run dev` without SSR).
 * For SSR mode, the server uses entry-server.tsx and the client uses entry-client.tsx.
 */
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App.tsx';
import './index.css';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
