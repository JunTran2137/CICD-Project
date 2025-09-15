import axios from 'axios';

const { APP_API_HOST, APP_API_PORT } = window.__ENV__ || {};

function getBaseURL() {
  if (APP_API_HOST) {
    const port = APP_API_PORT ? `:${APP_API_PORT}` : ''
    return `http://${APP_API_HOST}${port}/api`;
  }
  // Kubernetes Ingress sẽ route /api → backend
  return '/api';
}

export default axios.create({
  baseURL: getBaseURL(),
  headers: { 'Content-Type': 'application/json' }
});
